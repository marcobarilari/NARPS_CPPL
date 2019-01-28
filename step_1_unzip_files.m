% script to unzip the fmriprep data

% example of docker command to run it
% docker run -it --rm \
% -v /c/Users/Remi/Documents/NARPS/:/data \
% -v /c/Users/Remi/Documents/NARPS/code/:/code/ \
% -v /c/Users/Remi/Documents/NARPS/derivatives/:/output \
% spmcentral/spm:octave-latest script '/code/step_1_unzip_files.m'


machine_id = 0;% 0: container ;  1: Remi ;  2: Marco
filter =  'sub-.*space-MNI152.*.nii.gz$'; % to unzip only the files in MNI space

% setting up
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

% unzipping
unzip_fmriprep(fMRIprep_DIR, filter)

