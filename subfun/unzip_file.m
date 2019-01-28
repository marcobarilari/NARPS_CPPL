function filename = unzip_file(filename)

[filepath, name, ext] = spm_fileparts(filename);
if strcmp(ext, '.gz')
    gunzip(filename)
    filename = fullfile(filepath, name);
end
end