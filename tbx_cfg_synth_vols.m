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

function tbx_config = tbx_cfg_synthetic_volumes
% Configuration file for toolbox 'Synthetic Volumes'
%__________________________________________________________________________

tbx_dir = fileparts(mfilename('fullpath'));

[spm_version, spm_release] = spm('Ver');

if ~strcmp(spm_version, 'SPM12')
    msg = [newline, ...
           newline '_________________________________________________', ...
           '_______________________' newline, ...
           'The synthetic volumes toolbox could not be loaded as the ', ...
           'current version ' newline, ...
           'is only compatible with SPM12.', ...
           newline '_________________________________________________', ...
           '_______________________' newline];
    disp(msg);
    error(msg);
end

if ~strcmp(spm_release, '7771')
    msg = [newline, ...
           newline '_________________________________________________', ...
           '_______________________' newline, ...
           'The synthetic volumes toolbox could not be loaded as the ', ...
           'current version ' newline, ...
           'is only compatible with version 7771 of SPM ', ...
           'released on 13 January 2020.', ...
           newline '_________________________________________________', ...
           '_______________________' newline];
    disp(msg);
    error(msg);
end

patch_version = '7771';

if ~isdeployed
    addpath(tbx_dir);
    addpath(fullfile(tbx_dir, 'patches', patch_version));
end

tbx_config      = cfg_const;
tbx_config.tag  = 'synth';
tbx_config.name = 'Synthetic Volumes Toolbox';
tbx_config.help = {
    'The synthetic volumes toolbox is an SPM extension that allows ', ...
    'image data to be generated on the fly based on a file''s name ', ...
    'and directory. For more information, please consult the ', ...
    'README.txt file.'
    };
