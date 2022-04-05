% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                                                                         %
%  This source file is part of the Synthetic Volumes Toolbox,             %
%  an SPM12 extension:                                                    %
%  https://github.com/high-dimensional/synthetic_volumes_toolbox          %
%                                                                         %
%  Copyright (C) 2019,                                                    %
%  High-Dimensional Neurology Group, University College London            %
%                                                                         %
%  See synthetic_volumes_toolbox/LICENSE.txt for license details.         %
%  See synthetic_volumes_toolbox/AUTHORS.txt for the list of authors.     %
%                                                                         %
%  SPDX-License-Identifier: GPL-3.0-only                                  %
%                                                                         %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

classdef SyntheticVolumeGenerator < handle
% SyntheticVolumeGenerator Creates volumes from a textual specifier.
%__________________________________________________________________________

    
    properties (SetAccess=immutable)
        session_key
    end
    
    properties (Constant)
        REGISTRY_GET = 1
        REGISTRY_ADD = 2
        REGISTRY_REMOVE = 3
    end
    
    methods
        
        function obj = SyntheticVolumeGenerator(session_key)
            obj.session_key = session_key;
        end
        
        function S = volume_size(obj, specifier) %#ok<STOUT>
            error(['SyntheticVolumeGenerator.volume_size() must be ', ...
                   'implemented by a subclass [session_key="%s", ', ...
                   'specifier="%s"].'
                   ], obj.session_key, specifier);
        end
        
        function V = synthesize(obj, specifier) %#ok<STOUT>
            error(['SyntheticVolumeGenerator.synthesize() must be ', ...
                   'implemented by a subclass [session_key="%s", ', ...
                   'specifier="%s"].'
                   ], obj.session_key, specifier);
        end
    end
    
    methods (Static)

        function result = registry(session_key, action, varargin)
            
            result = [];
            
            persistent registry_map;
            
            if isempty(registry_map)
                registry_map = containers.Map('KeyType', 'char', ...
                                              'ValueType', 'any');
            end
            
            switch action
                
                case SyntheticVolumeGenerator.REGISTRY_GET

                    if ~isKey(registry_map, session_key)
                        error(['SyntheticVolumeGenerator.registry(GET): ', ...
                               'Couldn''t locate SyntheticVolumeGenerator ', ...
                               'for session_key="%s".'], session_key);
                    end
                    
                    result = registry_map(session_key);
                    
                case SyntheticVolumeGenerator.REGISTRY_ADD
                    
                    strict = varargin{2};
                    
                    if strict && isKey(registry_map, session_key)
                        error(['SyntheticVolumeGenerator.registy(ADD): '
                               'Session key "%s" already in use.'], ...
                               session_key);
                    end
                    
                    registry_map(session_key) = varargin{1};
                
                case SyntheticVolumeGenerator.REGISTRY_REMOVE
                    
                    if isKey(registry_map, session_key)
                        result = registry_map(session_key);
                        remove(registry_map, session_key);
                    end
                    
            end
        end
        
        function S = volume_size_for_session(session_key, specifier)
            % Retrieve the size of the volume for the session + specifier.
            generator = SyntheticVolumeGenerator.registry(session_key, ...
                            SyntheticVolumeGenerator.REGISTRY_GET);
            S = generator.volume_size(specifier);
        end
        
        function V = synthesize_for_session(session_key, specifier)
            % Generate the data of the volume for the session + specifier.
            generator = SyntheticVolumeGenerator.registry(session_key, ...
                            SyntheticVolumeGenerator.REGISTRY_GET);
            V = generator.synthesize(specifier);
        end
        
        function add(generator, session_key, strict)
            % Register the generator under the given session key.
            %   If strict is false, an error will be thrown if the session
            %   key is already in use.
            
            if ~exist('strict', 'var')
                strict = true;
            end
            
            SyntheticVolumeGenerator.registry(session_key, ...
                SyntheticVolumeGenerator.REGISTRY_ADD, generator, strict);
        end
        
        function generator = remove(session_key)
            % Deregister any generator associated with the session key.
            
            generator = SyntheticVolumeGenerator.registry(session_key, ...
                SyntheticVolumeGenerator.REGISTRY_REMOVE);
        end
    end
end
