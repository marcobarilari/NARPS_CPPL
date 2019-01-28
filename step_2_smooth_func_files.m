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
filter =  'sub-.*space-MNI152NLin2009cAsym_preproc.nii'; % to smooth only the preprocessed files

% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

% creating output folders in derivatives/spm12
mkdir(output_dir)
folder_subj = get_subj_list(fMRIprep_DIR);
folder_subj = cellstr(char({folder_subj.name}')); % turn subject folders into a cellstr
spm_mkdir(output_dir, folder_subj, {'anat','func'});

% smooth
% INSERT CALL TO SMOOTHING FUNCTION

% move smoothed file to output dir
for i_subj = 1:size(folder_subj, 1)
    
    files_to_move = spm_select('FPList', ...
        fullfile(fMRIprep_DIR, folder_subj{i_subj}, 'func'), ...
        ['^' prefix '.*' filter '$'] ); 
    
    for i_file = 1:size(files_to_move,1)
        movefile(files_to_move(i_file,:), ...
            fullfile(output_dir), folder_subj{i_subj}, 'func')
    end
    
end
