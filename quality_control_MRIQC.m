%% Load MRIQC reports
clear 
clc

machine_id = 1;
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

MRIQC_T1w_file = fullfile(code_dir, 'inputs', 'mriqc','group_T1w.tsv');
MRIQC_BOLD_file = fullfile(code_dir, 'inputs', 'mriqc','group_BOLD.tsv');

T1w = spm_load(MRIQC_T1w_file);
BOLD = spm_load(MRIQC_BOLD_file);

%% T1
field_names = fieldnames(T1w);

% check robust outliers for each MRIQC metric
for i_field_name = 2:numel(field_names)
    tmp = getfield(T1w, field_names{i_field_name});
    [outliers_T1w(:,i_field_name-1)] = iqr_method(tmp);
end

% print subjects' names that are outlier for at least 2 metric
T1w.bids_name(sum(outliers_T1w, 2)>2)

%% BOLD
field_names = fieldnames(BOLD);

% check robust outliers for each MRIQC metric
for i_field_name = 2:numel(field_names)
    tmp = getfield(BOLD, field_names{i_field_name});
    [outliers_BOLD(:,i_field_name-1)] = iqr_method(tmp);
end

% print subjects' names that are outlier for at least 2 metric
BOLD.bids_name(sum(outliers_BOLD, 2)>1)


