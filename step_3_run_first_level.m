% runs subject level on the NARPS data:
% This pipeline should allow to run all the possible combinations of options
% for the GLM: this is currentlyy defined in the set_all_GLMS.m subfunction
% but should eventually be partly moved out of it.

% Garden of forking paths: GoFP
% for the possible options of subject level GLM see the functions:
%  - set_all_GLMS.m: that lists all the possible options of GLM to run
%  - get_cfg_GLMS_to_run.m: sets the GLM that will actually be run

% TO DO:
% opt.RT_correction
% expected value
% merge brain masks
% - send email in case of crash or when finished
% - add parfor loop over subjects (??): remember that parfor over GLM
% estimation lead to problems. Makes me think this whole thing could be
% split up in 3 scripts which would make parfor looping easier:
%   - one to specify models
%   - one to estimate them
%   - one to estimate contrasts


%% parameters
clear all
clc

machine_id = 0;% 0: container ;  1: Remi ;  2: Marco
smoothing_prefix = 's-6_';
filter =  '.*_bold_space-MNI152NLin2009cAsym_preproc.nii$'; % to unzip only the files in MNI space
% nb_subjects = 2; % to only try on a couple of subjects; comment out to run on all


%% set options
opt.task = 'MGT';
opt.nb_slices = 64;
opt.TR = 1;
opt.TA = 0.9844;
opt.slice_reference = 32;

% manually specify prefix of the images to use
opt.prefix = smoothing_prefix;
opt.suffix = filter;


%% setting up
% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

data_dir
code_dir
output_dir

% listing subjects
folder_subj = get_subj_list(output_dir);
folder_subj = cellstr(char({folder_subj.name}')); % turn subject folders into a cellstr
if ~exist('nb_subjects', 'var')
    nb_subjects = numel(folder_subj);
end


%% figure out which GLMs to run
% set up all the possible of combinations of GLM possible given the
% different analytical options we have
[sets] = get_cfg_GLMS_to_run();
[opt, all_GLMs] = set_all_GLMS(opt, sets);


%% for each subject
for isubj = 1:nb_subjects

    fprintf('running %s\n', folder_subj{isubj})

    subj_dir = fullfile(output_dir, [folder_subj{isubj}], 'func')


    %% get explicit mask
    fprintf(' getting mask\n')
    explicit_mask = create_mask(subj_dir, folder_subj{isubj});


    %% get data for all runs
    fprintf(' getting data\n')
    data = spm_select('FPList', ...
        subj_dir, ...
        ['^' opt.prefix folder_subj{isubj} opt.suffix ] );
    data = cellstr(data);

    nb_runs = size(data,1);


    %%  get onsets and confounds for each run
    fprintf(' getting onsets and confounds\n')
    for iRun = 1:nb_runs

        % get the base name of the func file before it was smoothed
        source_file = strrep( data{iRun,1}, ...
            opt.prefix, ...
            '');

        % get onsets for all the conditions and blocks as well as each trial caracteristics
        events_file = strrep( source_file, ...
            '_bold_space-MNI152NLin2009cAsym_preproc.nii', ...
            '_events.tsv');
        onsets{iRun} = spm_load(events_file); %#ok<*SAGROW>
        onsets{iRun}.name = 'gamble_trial';
        onsets{iRun}.param = {'gain' 'loss' 'EV'}; %name of the fields to use as parametric factors

        % compute euclidian distance to the indifference line defined by
        % gain twice as big as losses
        % https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
        a = 0.5;
        b = -1;
        c = 0;
        x = onsets{iRun}.gain;
        y = onsets{iRun}.loss;
        dist = abs(a * x + b * y + c) / (a^2 + b^2)^.5;
        onsets{iRun}.EV = dist; % create an "expected value" regressor

        % identify missed responses
        onsets = get_cdt_onsets(onsets, iRun);

        % list realignement parameters and other fMRIprep data for each run
        confounds_file = strrep( source_file, ...
            '_space-MNI152NLin2009cAsym_preproc.nii', ...
            '_confounds.tsv');
        confounds{iRun} = spm_load(confounds_file); %#ok<*SAGROW>

    end

    % set this variable aside in case it needs to be used differently for
    % several analysis
    onsets_ori = onsets;



    %% now we specify the batch and run the GLMs
    % or just a subset of GLMs ; see set_all_GLMS.m for more info
    fprintf(' running GLMs\n')
    for iGLM = 1:size(all_GLMs)

        tic

        % get onsets
        onsets = onsets_ori;

        % get configuration for this GLM
        cfg = get_configuration(all_GLMs, opt, iGLM);

        disp(cfg)

        % create the directory for this specific analysis
        analysis_dir = name_analysis_dir(cfg);
        analysis_dir = fullfile ( ...
            output_dir, ...
            folder_subj{isubj}, analysis_dir );
        [~, ~, ~] = mkdir(analysis_dir);

        % to remove any previous analysis so that the whole thing does not
        % crash
        delete(fullfile(analysis_dir,'SPM.mat'))

        % define the explicit mask for this GLM if specified
        if cfg.explicit_mask
            cfg.explicit_mask = explicit_mask;
        else
            cfg.explicit_mask = '';
        end

        % TO DO as not implemented yet
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

        % for each run
        for iRun = 1:nb_runs

            % create extra conditions (missed trials, button presses, ...)
            % create missed trial conditions
            if cfg.rm_unresp_trials.do
                onsets{iRun} = create_missed_trial_cdt(onsets{iRun}, cfg);
            end
            % create button press conditions
            if cfg.model_button_press
                onsets{iRun} = create_button_press_cdt(onsets{iRun});
            end

            % adds run specific parameters
            matlabbatch = ...
                set_session_GLM_batch(matlabbatch, 1, data, iRun, cfg);

            % adds condition specific parameters for this run
            for iCdt = 1:size(onsets{iRun},2)
                matlabbatch = ...
                    set_cdt_GLM_batch(matlabbatch, 1, iRun, onsets{iRun}(1,iCdt), cfg);
            end

            % adds extra regressors (RT param mod, movement, ...) for this
            % run
            matlabbatch = ...
                set_extra_regress_batch(matlabbatch, 1, iRun, cfg, RT_regressors_col, confounds);
        end

        % estimate design
        matlabbatch{end+1}.spm.stats.fmri_est.spmmat{1,1} = fullfile(analysis_dir, 'SPM.mat');
        matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;

        save(fullfile(analysis_dir,'GLM_matlabbatch.mat'), 'matlabbatch')

        spm_jobman('run', matlabbatch)

        % estimate contrasts
        matlabbatch = [];
        matlabbatch = set_t_contrasts(analysis_dir);

        spm_jobman('run', matlabbatch)

        save(fullfile(analysis_dir,'contrast_matlabbatch.mat'), 'matlabbatch')

        toc

    end


end
