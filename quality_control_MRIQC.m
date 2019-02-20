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

% CJV = coefficient of joint variation ; Lower values are better.
% CNR = contrast-to-noise ratio ; Higher values indicate better quality.
% SNR = signal-to-noise ratio ; Higher values indicate better quality ; calculated within the tissue mask.
% SNRd = Dietrich’s SNR ; Higher values indicate better quality ; using the air background as reference.
% EFC =  Entropy-focus criterion ; Lower values are better.
% FBER = Foreground-Background energy ratio ;  Higher values are better.
% inu_* (nipype interface to N4ITK): summary statistics (max, min and median)
%   of the INU field as extracted by the N4ITK algorithm [Tustison2010]. 
%   Values closer to 1.0 are better.
% art_qi1(): Detect artifacts in the image using the method described 
%   in [Mortamet2009]. The QI1 is the proportion of voxels with intensity 
%   corrupted by artifacts normalized by the number of voxels in the 
%   background. Lower values are better.
% wm2max(): The white-matter to maximum intensity ratio is the median 
%   intensity within the WM mask over the 95% percentile of the full
%   intensity distribution, that captures the existence of long tails 
%   due to hyper-intensity of the carotid vessels and fat. Values should 
%   be around the interval [0.6, 0.8].

clear field_names

field_names(1).name = 'cjv';
field_names(1).flip = false;
field_names(1).unilateral = true;

field_names(end+1).name = 'cnr';
field_names(end).flip = true;
field_names(end).unilateral = true;

field_names(end+1).name = 'snr_gm';
field_names(end).flip = true;
field_names(end).unilateral = true;

field_names(end+1).name = 'snr_wm';
field_names(end).flip = true;
field_names(end).unilateral = true;

field_names(end+1).name = 'snrd_gm';
field_names(end).flip = true;
field_names(end).unilateral = true;

field_names(end+1).name = 'snrd_wm';
field_names(end).flip = true;
field_names(end).unilateral = true;

field_names(end+1).name = 'efc';
field_names(end).flip = false;
field_names(end).unilateral = true;

field_names(end+1).name = 'fber';
field_names(end).flip = true;
field_names(end).unilateral = true;

field_names(end+1).name = 'qi_1';
field_names(end).flip = false;
field_names(end).unilateral = true;

field_names(end+1).name = 'inu_med';
field_names(end).flip = false;
field_names(end).unilateral = false;

field_names(end+1).name = 'wm2max';
field_names(end).flip = false;
field_names(end).unilateral = false;

% check robust outliers for each MRIQC metric
for i_field = 1:numel(field_names)
    
    tmp = getfield(T1w, field_names(i_field).name);
    
    if field_names(i_field).flip
        tmp = tmp * -1;
    end
    if field_names(i_field).unilateral
        unilat = 1;
    else
        unilat = 2;
    end
    
    [outliers_T1w(:,i_field)] = iqr_method(tmp, unilat); %#ok<SAGROW>
end

% print subjects' names that are outlier for at least 1 metric
T1w.bids_name(sum(outliers_T1w, 2)>0)

%% BOLD

% efc =  Entropy-focus criterion ; Lower values are better.
% fber = Foreground-Background energy ratio ;  Higher values are better.
% DVARS
%   dvars_nstd
%   dvars_std
%   dvars_vstd
% fd_perc
% fd_mean
% gsr = Ghost to Signal Ratio 
% aor = AFNI’s outlier ratio - Mean fraction of outliers per fMRI 
%   volume as given by AFNI’s 3dToutcount.
% snr = SNR
% tsnr = Temporal SNR

clear field_names

field_names(1).name = 'aor';
field_names(end).flip = false;
field_names(end).unilateral = true;

field_names(end+1).name = 'dvars_nstd';
field_names(end).flip = false;
field_names(end).unilateral = true;

field_names(end+1).name = 'dvars_std';
field_names(end).flip = false;
field_names(end).unilateral = true;

field_names(end+1).name = 'dvars_vstd';
field_names(end).flip = false;
field_names(end).unilateral = true;

field_names(end+1).name = 'efc';
field_names(end).flip = false;
field_names(end).unilateral = true;

field_names(end+1).name = 'fber';
field_names(end).flip = true;
field_names(end).unilateral = true;

field_names(end+1).name = 'fd_mean';
field_names(end).flip = false;
field_names(end).unilateral = true;

field_names(end+1).name = 'fd_perc';
field_names(end).flip = false;
field_names(end).unilateral = true;

field_names(end+1).name = 'gsr_x';
field_names(end).flip = true;
field_names(end).unilateral = true;

field_names(end+1).name = 'gsr_y';
field_names(end).flip = true;
field_names(end).unilateral = true;

field_names(end+1).name = 'snr';
field_names(end).flip = true;
field_names(end).unilateral = true;

field_names(end+1).name = 'tsnr';
field_names(end).flip = true;
field_names(end).unilateral = true;


% check robust outliers for each MRIQC metric
for i_field = 1:numel(field_names)
    
    tmp = getfield(BOLD, field_names(i_field).name);
    
    if field_names(i_field).flip
        tmp = tmp * -1;
    end
    if field_names(i_field).unilateral
        unilat = 1;
    else
        unilat = 2;
    end
    
    [outliers_BOLD(:,i_field)] = iqr_method(tmp, unilat); 
end

% print subjects' names that are outlier for at least 1 metric
BOLD.bids_name(sum(outliers_BOLD, 2)>0)


