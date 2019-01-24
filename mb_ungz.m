function mb_ungz(folder_path)

% Function to unzip '.gz' files, octave environment
% written by mb, 23/01/2019

%folder_path = '~/data/narps_workingfolder'

% Get a list of all files and folders in this folder.
folder_main = dir(folder_path);
% Remove . and ..
folder_main(ismember( {folder_main.name}, {'.', '..'})) = [];
% Get a logical vector that tells which is a directory.
dirFlags = [folder_main.isdir];
% Extract only those that are directories.
folder_subj = folder_main(dirFlags);
% Extract only those that are subj folders.
folder_subj(~strncmp( {folder_subj.name}, {'sub'}, 3)) = [];
% Loop across floder and unpack .gz files
for k = 1 : length(folder_subj)
	fprintf('\nSub folder #%d = %s\n', k, folder_subj(k).name);
	% Anatomical data
	fprintf('\n Unpacoctaveking anat\n');
	% Build subj folder path
	temp = fullfile(folder_path, folder_subj(k).name, '/anat');
	% Check if there are .gz file, then unpack them
	if size(dir(fullfile(temp,'*.gz')),1)
		% Make a list of the file in it with '.gz' extension
		files = ls(fullfile(temp, '*.gz'));
		% Unzip the '.gz' files
		for ifile = 1:size(files,1)
			fprintf('\n  Unpacking file #%d of %d\n', ifile, size(files,1));
			% Print the file name
			fName = strsplit(files(ifile,:), filesep);
			fprintf('  %s\n', cell2mat(fName(size(fName,2))));
			gunzip(files(ifile,:));
		end
	else disp('no files to unpack') end
	% Functional data
	fprintf('\n Unpacking func\n');
	% Build subj folder path
	temp = fullfile(folder_path, folder_subj(k).name, '/func');
	% Check if there are .gz file, then unpack them
	if size(dir(fullfile(temp,'*.gz')),1)
		% Make a list of the file in it with '.gz' extension
		files = ls(fullfile(temp, '*.gz'));
		for ifile = 1:size(files,1)
			fprintf('\n  Unpacking file #%d of %d\n', ifile, size(files,1));
			% Print the file name
			fName = strsplit(files(ifile,:), filesep);
			fprintf('  %s\n', cell2mat(fName(size(fName,2))));
			% Unzip the '.gz' files
			gunzip(files(ifile,:));
		end
	else disp('no files to unpack') end
end

end
