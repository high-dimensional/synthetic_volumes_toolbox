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

function varargout = spm_synth_vol_get(action, varargin)
% Access toolbox configuration.
%__________________________________________________________________________


switch lower(action)
    
    case 'ver'
        
        where = mfilename('fullpath');
        [dir, ~, ~] = fileparts(where);
                
        path = fullfile(dir, 'SyntheticVolumesContents.m');
        handle = fopen(path, 'rt');
        
        if handle == -1
            error('Can''t open %s.', handle);
        end
        
        lines = { fgetl(handle);  fgetl(handle) };
        
        fclose(handle);
        
        lines{1} = strtrim(lines{1}(2:end)); 
        lines{2} = strtrim(lines{2}(2:end));
        
        result = struct();
        
        token = textscan(lines{2}, '%s', 'delimiter', ' ');
        token = token{1};
        
        result.Name = lines{1};
        result.Date = token{4};
        
        result.Version = token{2};
        result.Release = token{3}(2:end-1);
        
        varargout = { result };
        
    otherwise
        error('Unknown action %s', action);
end
