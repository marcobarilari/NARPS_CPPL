function mb_smooth(FWHM, prefix, folder_path)

spm fmri

tic

% Check about 'FWHM' var input
if ~exist('FWHM', 'var')
    FWHM = [8 8 8];
    fprintf('\n- FWHM set to 8 mm as default\n')
else
    fprintf('\n- FWHM set to %d mm\n', FWHM)
end
% Check about 'prefix' var input
if ~exist('prefix', 'var')
    fprintf('\n- "prefix" not provided, set to "s" as default\n')
    prefix = 's';
else fprintf('\n- "prefix" of the smoothed data is %s\n', prefix);
end
% Check about 'folder_path' var input
if ~exist('folder_path', 'var')
    folder_path = pwd;
    fprintf('\n- Folder path not provided, I assume we are in the data folder\n')
elseif ~exist(folder_path, 'dir')
    error('-The path is not a folder, please insert a valid folder path')
else fprintf('\n- I will look for data to smooth here %s\n', folder_path);
end

% Get a list of all files and folders in this folder.
folder_main = dir(folder_path);
% Remove . and ..
folder_main(ismember( {folder_main.name}, {'.', '..'})) = [];
% Get a logical vector that tells which is a directory.
dir_flags = [folder_main.isdir];
% Extract only those that are directories.
folder_subj = folder_main(dir_flags);
% Extract only those that are subj folders.
folder_subj(~strncmp( {folder_subj.name}, {'sub'}, 3)) = [];

% Filter only the func data to smooth
filter =  'sub-.*space-MNI152.*preproc.nii$';

% Loop across folder and unpack .gz files
parfor isubj = 1 : length(folder_subj)
    
    matlabbatch = [];
    
    fprintf('\nProcessing Subject n. %d of %d\n\n',isubj, size(folder_subj,1))
    % Build subj folder path
    folder_files = fullfile(folder_path, folder_subj(isubj).name, 'func');
    % Make a list of the file in it with '.gz' extension
    file_list = cellstr(spm_select('ExtFPList', folder_files, filter, Inf));
    
    % Create the batch
    matlabbatch{1}.spm.spatial.smooth.data   = cellstr(file_list);
    matlabbatch{1}.spm.spatial.smooth.fwhm   = [ FWHM FWHM FWHM ];
    matlabbatch{1}.spm.spatial.smooth.dtype  = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = prefix;
    
    save_the_job(matlabbatch, folder_subj);
    
    spm_jobman('run',matlabbatch);
    
end

toc

end


function save_the_job
job_name = fullfile(folder_files,['job_' folder_subj(isubj).name '_smoothing.mat' ]);
save(job_name, 'matlabbatch')
end