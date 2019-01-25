% runs subject level on the NARPS data: 
% This pipeline should allow to run all the possible combinations of options 
% for the GLM: this is currentlyy defined in the set_all_GLMS.m subfunction
% but should eventually be partly moved out of it.

% possible options of subject level GLM
%  - different high pass filter (HPF): 128
%  - design: events or blocks
%  - correction for reaction time (RT): yes, no
%  - time derivative: yes, no
%  - dispersion derivatives: yes, no
%  - include mvt noise regressors: yes, no

% TO DO:
% - scrubbing
% - make more verbose
% - send email in case of crash or when finished
% - do time estimation
% - how to deal with unresponded trials?
% - criterion to remove subjects (move to 2nd level script)
% - fit GLM for all runs and only exclude when creating contrasts or
%  already exclude runs ? At the moment it fits all runs
% - run t-contrasts for all the needed condition for the group level
% - subfunction to create an RT regressor and add it to the design if
% needed
% - change inclusive masking 
% - add parfor loop over subjects (??): remember that parfor over GLM
% estimation lead to problems. Makes me think this whole thing could be
% split up in 3 scripts which would make parfor looping easier: 
%  - one to specify models
%  - one to estimate them
%  - one to estimate contrasts
% 

clear
clc


%% Set options, matlab path
opt.task = 'MGT';
opt.nb_slices = 64;
opt.TR = 1;
opt.TA = 0.9844;
opt.slice_reference =32;

% manually specify prefix of the images to use
opt.prefix = 's';
opt.suffix = '_bold_space-MNI152NLin2009cAsym_preproc';

% windows matlab
data_dir = 'D:\Dropbox\BIDS\NARPS';
code_dir = 'D:\github\NARPS_CPPL\';

% containers
% data_dir = '/data';
% code_dir = '/code/mcgurk';
% addpath(fullfile('/opt/spm12'));

% add subfunctions to path
addpath(fullfile(code_dir,'subfun'));

% define derivatives fMRIprep dir 
fMRIprep_DIR = fullfile(data_dir, 'derivatives', 'fmriprep');

% define output dir
output_dir = fullfile(data_dir, 'derivatives', 'spm12');
[~, ~, ~] = mkdir(output_dir);

% set defaults for memory usage fot make GLM run faster using subfun/spm_defaults.m
defaults = spm_get_defaults;


%% get data set and analysis info
% data set (won't work until we have a minimal BIDS data set downloaded)
bids_dir = fullfile(data_dir, 'rawdata');
bids_struct = spm_BIDS(bids_dir);
subj_ls = spm_BIDS(bids_struct, 'subjects');
nb_subj = numel(subj_ls);

% get additional data from metadata (TR, resolution, slice timing
% parameters)
[opt] = get_metadata(bids_struct, opt);

% set up all the possible of combinations of GLM possible given the
% different analytical options we have
[opt, all_GLMs] = set_all_GLMS(opt);


%% for each subject
for isubj = 1%:nb_subj
    
    fprintf('running sub-%s\n', subj_ls{isubj})
    
    subj_dir = fullfile(fMRIprep_DIR, ['sub-' subj_ls{isubj}], 'func');

    
    %% get runs info
    run_ls = spm_BIDS(bids_struct, 'runs', 'sub', subj_ls{isubj}, ...
        'type', 'bold');
    nb_runs = numel(run_ls);
        
    
    %%  get data, onsets and extra regressors for each run  
    fprintf(' getting onsets and data\n')
    for iRun = 1:nb_runs
        
        run_data = spm_BIDS(bids_struct, 'data', 'sub', subj_ls{isubj}, ...
        'type', 'bold', 'run', run_ls{iRun});
    
        %in case there is nii.gz and a .nii file for the same run we only
        %take the .nii.gz
        if numel(run_data)>1 
            run_data = {run_data{2}};
        end
        
        % get onsets for all the conditions and blocks as well as each trial caracteristics
        events_file = strrep(run_data{1}, 'bold.nii.gz', 'events.tsv');
        onsets{iRun} = spm_load(events_file); %#ok<*SAGROW>
        onsets{iRun}.name = 'gamble_trial';
        onsets{iRun}.param = {'gain' 'loss'}; %name of the fields to use as parametric factors

        
        
        
        % identify missed responses
            % this will need some reworking to 
        onsets = get_cdt_onsets(onsets, iRun);

        
        
        
        % list realignement parameters and other fMRIprep data for each run
        confounds_file = spm_select('FPList', subj_dir, ...
            ['^.*run-' run_ls{iRun} '_bold_confounds\.tsv$']);
        confounds{iRun} = spm_load(confounds_file); %#ok<*SAGROW>

        data{iRun,1} = spm_select('FPList', subj_dir, ...
            ['^.*run-' run_ls{iRun} '.*' opt.suffix '\.nii$']);
        
    end
    
    
    %% some sanity check to make sure we have everything
    % to make sure that we got the data and the RP files
%     if any(cellfun('isempty', data))
%         error('Some data is missing: sub-%s - file prefix: %s', ...
%             subj_ls{isubj}, func_file_prefix)
%     end
%     if any(cellfun('isempty', confounds_files))
%         error('Some realignement parameter is missing: sub-%s', ...
%             subj_ls{isubj})
%     end
    
    
    %% now we specify the batch and run the GLMs 
    % or just a subset of GLMs ; see set_all_GLMS.m for more info
    fprintf(' running GLMs\n')
    for iGLM = 1:size(all_GLMs)
        
        tic
        
        % get configuration for this GLM
        cfg = get_configuration(all_GLMs, opt, iGLM);
        
        analysis_dir = name_analysis_dir(cfg);
        analysis_dir = fullfile ( ...
            output_dir, ...
            ['sub-' subj_ls{isubj}], analysis_dir );
        [~, ~, ~] = mkdir(analysis_dir);
        
        delete(fullfile(analysis_dir,'SPM.mat'))
        
        
        
        % TO DO
        if cfg.RT_correction
            % specify a dummy GLM to get one regressor for all the RTs
            RT_regressors_col = get_RT_regressor(analysis_dir, data, onsets, opt, cfg);
            error('adding RT regressors not fully implemented yet')
        else
            RT_regressors_col = {};
        end
        
        
        
        
        matlabbatch = [];
        
        % set the basic batch for this GLM
        matlabbatch = ...
            subject_level_GLM_batch(matlabbatch, 1, analysis_dir, opt, cfg);
        
        for iRun = 1:nb_runs
            
            % adds run specific parameters
            matlabbatch = ...
                set_session_GLM_batch(matlabbatch, 1, data, iRun, cfg);
            
            % adds condition specific parameters for this run
            for iCdt = 1:size(onsets{iRun},2)
                matlabbatch = ...
                    set_cdt_GLM_batch(matlabbatch, 1, iRun, onsets{iRun}, cfg);
            end
            
            % adds extra regressors (RT param mod, movement, ...) for this
            % run
            matlabbatch = ...
                set_extra_regress_batch(matlabbatch, 1, iRun, cfg, RT_regressors_col, confounds);
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
        
        toc
        
    end
    
    
end