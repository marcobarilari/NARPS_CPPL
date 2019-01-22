% runs subject level on the NARPS data: trying to set different possible
% options

% Then get the t-contrasts for all the needed condition for the group level

% possible options of subject level GLM
%  - different high pass filter (HPF): none, 100, 200
%  - design: events or blocks
%  - correction for reaction time (RT): yes, no
%  - time derivative: yes, no
%  - dispersion derivatives: yes, no
%  - include mvt noise regressors: yes, no

% other options:
% - scrubbing
% - criterion to remove subjects (for 2nd level)

%  fit GLM for all runs and only exclude when creating contrasts or
%  already exclude runs ?

% extract onsets, and data for parametric regressors

clear
clc


%% Set options, matlab path
opt.task = 'MGT';
% manually specify prefix of the images to use
opt.prefix = 's';
opt.suffix = '_bold_space-MNI152NLin2009cAsym_preproc';

% windows matlab
DATA_DIR = 'D:\Dropbox\BIDS\NARPS';
CODE_DIR = 'D:\github\NARPS_CPPL\';

% containers
% DATA_DIR = '/data';
% CODE_DIR = '/code/mcgurk';
% addpath(fullfile('/opt/spm12'));

% add subfunctions to path
addpath(fullfile(CODE_DIR,'subfun'));

% define output dir
OUTPUT_DIR = fullfile(DATA_DIR, 'derivatives', 'spm12');
[~, ~, ~] = mkdir(OUTPUT_DIR);

% set defaults for memory usage fot make GLM run faster using subfun/spm_defaults.m
% defaults = spm_get_defaults;


%% get data set and analysis info
% data set (won't work until we have a minimal BIDS data set downloaded)
BIDS_DIR = fullfile(DATA_DIR, 'rawdata');
subj_ls = spm_BIDS(BIDS, 'subjects');
nb_subj = numel(subj_ls);

% get additional data from metadata (TR, resolution, slice timing
% parameters)
[opt] = get_metadata(BIDS, subjects, opt.task);

% set up all the possible of combinations of GLM possible given the
% different options we have
[opt, all_GLMs] = set_all_GLMS(opt);

%% for each subject
for isubj = 1%:nb_subj
    
    
    %% get runs info
    run_ls = spm_BIDS(BIDS, 'data', 'sub', subj_ls{isubj}, ...
        'type', 'bold');
    nb_runs = numel(subjects{isubj}.func);
    
    %  fit GLM for all runs and only exclude when creating contrasts or
    %  already exclude runs ?
    
    
    %%  get data, onsets and extra regressors for each run 
%     cdt = [];
%     blocks = [];
%     
    for iRun = 1:nb_runs
        
        
        % get onsets for all the conditions and blocks as well as each trial caracteristics
        tsv_file = strrep(run_ls{iRun}, 'bold.nii.gz', 'events.tsv');
        onsets{iRun} = spm_load(tsv_file); %#ok<*SAGROW>
        
        [cdt, blocks] = get_cdt_onsets(cdt, blocks, onsets, iRun);
        
        
        % list functional data for each run
        [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{iRun});
        
        data{iRun,1} = spm_select('FPList', filepath, ...
            ['^' func_file_prefix name ext '$']);
        
        
        % list realignement parameters and other fMRIprep data for each run
        rp_mvt_files{iRun,1} = ...
            spm_select('FPList', filepath, ['^rp_.*' name '.*.txt$']);
        
    end
    
    %% some sanity check to make sure we have everything
    % to make sure that we got the data and the RP files
    if any(cellfun('isempty', data))
        error('Some data is missing: sub-%s - file prefix: %s', ...
            subj_ls{isubj}, func_file_prefix)
    end
    if any(cellfun('isempty', rp_mvt_files))
        error('Some realignement parameter is missing: sub-%s', ...
            subj_ls{isubj})
    end
    
    %% now we run all the possible GLMs 
    % or just some ; see set_all_GLMS.m for more info
    for iGLM = 1:size(all_GLMs)
        
        % get configuration for this GLM
        cfg = get_configuration(all_GLMs, opt, iGLM);
        
        % to know on which data to run this GLM
        func_file_prefix = set_file_prefix(cfg);

        
        analysis_dir = name_analysis_dir(cfg);
        analysis_dir = fullfile ( ...
            OUTPUT_DIR, ...
            ['sub-' subj_ls{isubj}], analysis_dir );
        mkdir(analysis_dir)
        
        delete(fullfile(analysis_dir,'SPM.mat'))
        
        if cfg.RT_correction
            % specify a dummy GLM to get one regressor for all the RTs
            RT_regressors_col = get_RT_regressor(analysis_dir, data, cdt, opt, cfg);
        else
            RT_regressors_col = {};
        end
        
        matlabbatch = [];
        
        % set the basic batch for this GLM
        matlabbatch = ...
            subject_level_GLM_batch(matlabbatch, 1, analysis_dir, opt, cfg);
        
        for iRun = 1:nb_runs
            
            % adds session specific parameters
            matlabbatch = ...
                set_session_GLM_batch(matlabbatch, 1, data, iRun, cfg, rp_mvt_files);
            
            % adds condition specific parameters for this session
            for iCdt = 1:size(cdt,2)
                matlabbatch = ...
                    set_cdt_GLM_batch(matlabbatch, 1, iRun, cdt(iRun,iCdt), cfg);
            end
            
            % adds extra regressors (blocks, RT param mod, ...) for this session
            matlabbatch = ...
                set_extra_regress_batch(matlabbatch, 1, iRun, opt, cfg, blocks, RT_regressors_col);
        end
        
        % specify design
        spm_jobman('run', matlabbatch)
        
        
        % estimate design
        matlabbatch = [];
        matlabbatch{1}.spm.stats.fmri_est.spmmat{1,1} = fullfile(analysis_dir, 'SPM.mat');
        matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
        spm_jobman('run', matlabbatch)
        
        % estimate contrasts
        %         matlabbatch = [];
        %         matlabbatch = set_t_contrasts(analysis_dir);
        %         spm_jobman('run', matlabbatch)
        
    end
    
    
end