# Synthetic Volumes Toolbox

## Introduction

The synthetic volumes toolbox is an [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) extension that allows image data to be generated on demand based on a file's name and directory.

## Method

The toolbox introduces a new file type using the `.synth` extension. In order to be able to use file names ending in `.synth` in a model estimation a small number of core SPM files have to be adjusted:

1. `spm_select.m`

     Adds `.synth` to the regular expressions for filtering image-based
     files.

2. `spm_existfile.m`

     Always returns true if a file name ends with `.synth`

3. `spm_data_hdr_read.m`

     Handles `.synth` extensions to return volume header structures as defined by the toolbox function `spm_synth_vol()`.

     `spm_synth_vol()` splits the `fname` volume header struct field into its directory (the session key) and file name (specifier) parts. The session key and specifier are used to retrieve the image dimension from the SyntheticVolumeGenerator registered for the session. An additional field `is_synthetic` is defined in the volume header struct and set to `true`.

4. `spm_data_read.m`

     Checks for the `is_synthetic` field in the volume header struct to detect a synthetic image.

     If there are no additional parameters, the volume header is passed to the toolbox function `spm_synth_vol_read()`.

     `spm_synth_vol_read()` again splits the `fname` volume header struct field into its directory (the session key) and file name (specifier) parts. Using the session key and specifier `spm_synth_vol_read()` then calls `SyntheticVolumeGenerator.synthesize_for_session()` to produce the volume data using the volume generator registered for the session.

5. `spm_read_vols.m`

     Check for the `is_synthetic` field in the volume header struct to
     detect a synthetic image. For each synthetic image call
     `spm_synth_vol_read()` instead of the default `spm_slice_vol()`,
     which does not support synthetic images.

## Implementing a Volume Generator

Applications interested in using the synthetic volume mechanism simply subclass `SyntheticVolumeGenerator` to provide their own implementation of two methods:

1. `volume_size(obj, specifier)`

     Retrieve the size of the volume with the given specifier.

2. `synthesize(obj, specifier)`

     Generate the data of the volume with the given specifier.

## Using a Volume Generator

In order to use an instance of `SyntheticVolumeGenerator` it has to be registered, otherwise the `.synth` files defined for it will not be resolved. This can be achieved by calling the static method `SyntheticVolumeGenerator.add(generator, session_key)`. Once a session is no longer active, an application should de-register it by calling the static method `SyntheticVolumeGenerator.remove(session_key)`.

## Current Limitations:
Synthetic volumes are currently not supported by `spm_slice_vol()`, and all code that depends on it, except for `spm_read_vols()`.

## Demonstration:

At the Matlab prompt, type:
```
spm_jobman('initcfg');
```
The command initialises SPM and ensures that all toolboxes are loaded. Then run:
```
spm_synth_vol_demo
```

This will create a directory with a timestamp in the current MATLAB directory. See [`spm_synth_vol_demo.m`](https://github.com/high-dimensional/synthetic_volumes_toolbox/blob/main/spm_synth_vol_demo.m) for more details.
