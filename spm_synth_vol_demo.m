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


% spm_synth_vol_demo.m
%
% This code fragment shows how synthetic volumes and volume generators
% are used.
%


% Get current timestamp

timestamp = datetime('now', 'TimeZone', 'local', ...
                    'Format', 'yyyy_MM_dd_HH_mm_ss');

% We create a directory based on the timestamp in the current working
% directory. Note that this is not necessary for the volume generator
% to work, but we want to save the file it generates in memory to disk. 
                
directory = fullfile(pwd, ['synthetic_volumes_demo_' char(timestamp)]);
[dirstatus, dirmsg] = mkdir(directory);
if dirstatus ~= 1; error(dirmsg); end

% Initialise a volume generator instance of the desired class,
% specify a directory path to be used as session key.

volume_generator = DemoVolumeGenerator( ...
                    directory, ...
                    [64, 64, 64], ...
                    'single', ...
                    true );

% Register the newly created volume generator
                
SyntheticVolumeGenerator.add(volume_generator, ...
                             volume_generator.session_key);

% We want to make sure that the volume generator is de-registered if
% an unexpected error occurs while using it. For this reason, all 
% computations that rely on a particular volume generator instance
% should be wrapped in a try block, so that the volume generator can 
% always be safely de-registered.
                   
try
    
    % Create a file path that specifies what image we want to generate.
    % This is purely a convenience method that allows to specify the 
    % image parameters understood by this particular type of volume 
    % generator easily.
    
    % In this instance, the demonstration volume generator expects
    % an object type and the coordinates of the object centre.
    
    % We specify a volumetric sphere at the centre of the volume.
    % This volume generator creates volumes that all have the same
    % size, which was specified when it was created above.
    
    file_path = volume_generator.format_synthetic_volume_path(...
        'sphere', 1, 1, 32);
    
    % We can initialise a volume with the file path we just created
    % and read from it. However, no file exists at the path on disk.
    % Instead, the volume generator is asked to provide the data of
    % the volume. Because this is the first time we access a volume,
    % the volume generator has to build its internal cache, which
    % might take some time. Subsequent accesses will be nearly
    % instantaneous.
    
    fprintf(['Accessing a demo volume for the first time. ' newline, ...
             'Because we are rendering distance fields, this can take ', ...
             'a few minutes...' newline]);
             
    V = spm_vol(file_path);
    tic; data = spm_read_vols(V); toc;
    
    % For the purposes of this demonstration, we save the generated
    % data back into a file.
    
    output_path = fullfile(directory, 'example1.nii');
    volume_generator.save_volume(output_path, data);
    
    % Demonstration of a subsequent access. Notice that the shape and
    % location are different.
    
    file_path = volume_generator.format_synthetic_volume_path(...
        'torus', 32, 32, 32);
    
    fprintf(['Accessing a demo volume for the second time. ' newline, ...
             'The volume generator now relies on its ' newline, ....
             'internal cache, which is much faster:' newline]);
    
    V = spm_vol(file_path);
    tic; data = spm_read_vols(V); toc;
    
    output_path = fullfile(directory, 'example2.nii');
    volume_generator.save_volume(output_path, data);
    
catch exception

    SyntheticVolumeGenerator.remove(volume_generator.session_key);
    rethrow(exception);
end

SyntheticVolumeGenerator.remove(volume_generator.session_key);
