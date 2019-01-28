% script to smooth the functional fmriprep preprocessed data

% example of docker command to run it
% docker run -it --rm \
% -v /c/Users/Remi/Documents/NARPS/:/data \
% -v /c/Users/Remi/Documents/NARPS/code/:/code/ \
% -v /c/Users/Remi/Documents/NARPS/derivatives/:/output \
% spmcentral/spm:octave-latest script '/code/step_2_smooth_func_files.m'

FWHM = 6;
prefix = 's';
machine_id = 1;% 0: container ;  1: Remi ;  2: Marco
filter =  'sub-.*space-MNI152.*.nii.gz$'; % to unzip only the files in MNI space

% setting up
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

% creating output folders
mkdir(output_dir)
folder_subj = get_subj_list(fMRIprep_DIR);
folder_subj = cellstr(char({folder_subj.name}')); % turn subject folders into a cellstr
spm_mkdir(output_dir, folder_subj, {'anat','func'});

% smooth
% 

