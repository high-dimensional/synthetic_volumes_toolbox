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

function V = spm_synth_vol_read(V)
% Generate the data for the specified volume.
%__________________________________________________________________________


    for i=1:numel(V)
        [session_key, specifier, ~] = fileparts(V(i).fname);
        V_data = SyntheticVolumeGenerator.synthesize_for_session(...
                    session_key, specifier);
        V(i).data = V_data;
    end
end
