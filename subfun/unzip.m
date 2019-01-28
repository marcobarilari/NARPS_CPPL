function unzip(folder_path)

% Function to unzip '.gz' files, tested on octave
% written by mb, 23/01/2019
%
% histroy:
% 25/01/2019 - mb, add a sub function to unpack the files
% 27/01/2019 - mb, check if a path is provided and if exists

tic

% Check if a path is provided and if exists
if nargin == 0
    error('Please provide a folder path')
elseif ~exist(folder_path, 'dir')
    error('The path is not a folder, please insert a valid folder path')
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

% Loop across folder and unpack .gz files
parfor k = 1 : length(folder_subj)
    fprintf('\nSub folder #%d = %s\n', k, folder_subj(k).name);
    % Anatomical data
    fprintf('\n Unpacking anat\n');
    % Build subj folder path
    folder_files = fullfile(folder_path, folder_subj(k).name, 'anat');
    % Check if there are .gz file, then unpack them
    unpack_gz(folder_files)
    % Functional data
    fprintf('\n Unpacking func\n');
    % Build subj folder path
    folder_files = fullfile(folder_path, folder_subj(k).name, 'func');
    % Check if there are .gz file, then unpack them
    unpack_gz(folder_files)
end

toc

end


function unpack_gz(folder_files)
if size(dir(fullfile(folder_files,'*.gz')),1)
    % Make a list of the file in it with '.gz' extension
    file_list = ls(fullfile(folder_files, '*.gz'));
    % Unzip the '.gz' files
    parfor ifile = 1:size(file_list,1)
        fprintf('\n  Unpacking file #%d of %d\n', ifile, size(file_list,1));
        % Print the file name
        file_name = strsplit(file_list(ifile,:), filesep);
        fprintf('  %s\n', cell2mat(file_name(size(file_name,2))));
        gunzip(file_list(ifile,:));
    end
else
    fprintf('\nno ".gz" files to unpack\n')
end
end