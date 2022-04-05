% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                                                                         %
%  This source file is part of the Synthetic Volumes Toolbox,             %
%  an SPM12 extension:                                                    %
%  https://github.com/high-dimensional/synthetic_volumes_toolbox          %
%                                                                         %
%  Copyright (C) 2021,                                                    %
%  High-Dimensional Neurology Group, University College London            %
%                                                                         %
%  See synthetic_volumes_toolbox/LICENSE.txt for license details.         %
%  See synthetic_volumes_toolbox/AUTHORS.txt for the list of authors.     %
%                                                                         %
%  SPDX-License-Identifier: GPL-3.0-only                                  %
%                                                                         %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

classdef DemoVolumeGenerator < SyntheticVolumeGenerator
% DemoVolumeGenerator An example of a SyntheticVolumeGenerator
%   Image contents are specified using the following format:
%   <identifier>;<x>;<y>;<z>
%   where identifier defines the shape
%         and x, y, z are coordinates.
%__________________________________________________________________________
    
    properties
    end
    
    properties (GetAccess=public, SetAccess=private)
        
        window_resolution
        precision
        use_cache
        debug
    end
        
    properties (Transient, Dependent)
        spm_precision
        session_volume_directory
    end
    
    properties (GetAccess=private, SetAccess=private)
        cache
    end
    
    methods
        
        function obj = DemoVolumeGenerator(...
                          session_volume_directory, ...
                          window_resolution, ...
                          precision, ...
                          use_cache)
            
            if ~exist('precision', 'var')
                precision = 'single';
            end
            
            if ~exist('use_cache', 'var')
                use_cache = true;
            end
                      
            obj = obj@SyntheticVolumeGenerator(session_volume_directory);
            
            obj.window_resolution = window_resolution;
            obj.precision = precision;
            obj.debug = false;
            obj.use_cache = use_cache;
            obj.cache = [];
        end
        
        function result = get.spm_precision(obj)
            
            if strcmp(obj.precision, 'single')
                result = 'float32';
            elseif strcmp(obj.precision, 'double')
                result = 'float64';
            else
                error(['DemoVolumeGenerator.get.spm_precision(): ', ...
                       'Unsupported precision ''' obj.precision '''.']);
            end
        end
        
        function result = get.session_volume_directory(obj)
            result = obj.session_key;
        end
        
        function result = volume_size(obj, ~)
            
            result = cast(obj.window_resolution, 'double');
        end
        
        function [location, identifier] = parse_specifier(~, specifier)
            
            [~, id, ~] = fileparts(specifier);
            
            index_xyz = split(id, ';');
            
            if numel(index_xyz) == 1
                identifier = id;
                location = [];
            else
                identifier = index_xyz{1};
                location = [str2double(index_xyz{2}), ...
                            str2double(index_xyz{3}), ...
                            str2double(index_xyz{4})];
            end
        end
        
        function result = format_synthetic_volume_id(~, id, x, y, z)
            
            result = [id ...
                      ';' num2str(x, '%06d') ...
                      ';' num2str(y, '%06d') ...
                      ';' num2str(z, '%06d')];
        end
        
        function result = format_synthetic_volume_path(obj, id, x, y, z)
            
            id = obj.format_synthetic_volume_id(id, x, y, z);
            result = fullfile(obj.session_volume_directory, [id '.synth']);
        end
        
        function V_data = synthesize(obj, specifier)
            
            [sample_location, identifier] = obj.parse_specifier(specifier);
            
            if isempty(sample_location)
                error(['DemoVolumeGenerator.synthesize(): Undefined ', ...
                      'volume ''%s''.'], identifier);
            end
            
            if ~obj.use_cache
                V_data = obj.generate(identifier, sample_location, ...
                                      obj.window_resolution);
            else
                if isempty(obj.cache)
                    obj.update_cache();
                end
                
                cached_map = obj.cache.(identifier);
                
                %If sample_location is (1, 1), then range_start is 
                %window_resolution
                %
                %If sample_location is window_resolution, 
                %then range_start is 1
                
                range_start = obj.window_resolution - sample_location + 1;
                range_end = range_start + obj.window_resolution - 1;
                
                V_data = cached_map(range_start(1):range_end(1), ...
                                    range_start(2):range_end(2), ...
                                    range_start(3):range_end(3));
                
            end
            
            if obj.debug
                
                [~, id, ~] = fileparts(specifier);
                index_xyz = split(id, ';');
                
                file_path = fullfile(obj.session_volume_directory, ...
                                     'debug', [index_xyz{1} '.nii']);
                
                obj.save_volume(file_path, V_data);
            end
        end
        
        function save_volume(obj, file_path, data)
            
            V = obj.blank_spm_volume();
            V.fname = file_path;

            dim = ones(1, 3);
            unsafe_size = size(data);
            dim(1:numel(unsafe_size)) = unsafe_size;
            V.dim = dim;
            spm_write_vol(V, data);
        end
    end
    
    methods (Access=protected)
        
        function result = render_cache(obj)
            
            cache_size = obj.window_resolution * 2 - 1;
            cache_location = obj.window_resolution;
            
            shapes = { 'sphere', 'torus' };
            result = struct();
            
            for i=1:numel(shapes)
                shape = shapes{i};
                result.(shape) = obj.generate(shape, ...
                                              cache_location, ...
                                              cache_size, ...
                                              0.5);
            end
        end
        
        function update_cache(obj)
            
            warning(['DemoVolumeGenerator: Rebuilding volume cache, ', ...
                     'this might take a few minutes depending on ', ...
                     'your machine.']);
            
            obj.cache = obj.render_cache();
        end
        
        function result = blank_spm_volume(obj)
            
            result = struct();
            
            result.dt = [spm_type(obj.spm_precision) 0];
            result.mat = eye(4);
            result.pinfo = [1 0 0]';
        end
        
        function V_data = generate(~, identifier, location, ...
                                   render_size, scale)
            
            if ~exist('scale', 'var')
                scale = 1.0;
            end
                               
            V_data = zeros(render_size);
            
            params = struct();
            params.max_iterations = 20;
            
            %{
            try
                parpool(4);
            catch
                warning(['Parallel Computing Toolbox not available. ', ...
                         'Computation of demo volumes will be slower.']);
            end
            %}
            
            for i=1:prod(render_size)
                
                [x, y, z] = ind2sub(render_size, i);
                pos = ([x, y, z] - location) ./ (0.5 * scale .* render_size);
                
                [result, value] = DemoVolumeGenerator.distance(...
                                    identifier, pos, params);
                
                if result >= 0.0
                    V_data(i) = NaN;
                else
                    V_data(i) = value;
                end
            end
        end
        
    end
    
    methods (Static)
        
        function [result, value] = distance(identifier, pos, params)
            
            if ~exist('params', 'var')
                params = struct();
            end
            
            switch identifier
                case 'sphere'
                    [result, value] = ...
                        DemoVolumeGenerator.sphere(pos, params);
                 
                case 'torus'
                    [result, value] = ...
                        DemoVolumeGenerator.torus(pos, params);
                    
                otherwise
                    result = 0.0;
                    value = 0.0;
            end
        end
        
        function [result, value] = sphere(pos, params)
            
            if ~exist('params', 'var')
                params = struct();
            end
            
            if ~isfield(params, 'radius')
                params.radius = 1.0;
            end
            
            result = norm(pos) - params.radius;
            value = -result;
        end
        
        function [result, value] = torus(pos, params)
            
            
            if ~exist('params', 'var')
                params = struct();
            end
            
            if ~isfield(params, 'radius')
                params.radius = 0.5;
            end
            
            if ~isfield(params, 'thickness')
                params.thickness = 0.2;
            end
            
            q = [norm(pos([1, 3])) - params.radius, pos(2)];
            
            result = norm(q) - params.thickness;
            value = -result;
        end
        
    end
end
