% runs group level on the McGurk experiment and export the results corresponding to those
% published in the NIDM format

% Parametric effect of gain:
%
% Positive effect in ventromedial PFC - for the equal indifference group
% Positive effect in ventromedial PFC - for the equal range group
% Positive effect in ventral striatum - for the equal indifference group
% Positive effect in ventral striatum - for the equal range group

% Parametric effect of loss:
%
% Negative effect in VMPFC - for the equal indifference group
% Negative effect in VMPFC - for the equal range group
% Positive effect in amygdala - for the equal indifference group
% Positive effect in amygdala - for the equal range group

% Equal range vs. equal indifference:
%
% Greater positive response to losses in amygdala for equal range condition vs. equal indifference condition.


%% parameters
clear
clc

machine_id = 1;% 0: container ;  1: Remi ;  2: Marco

%% setting up
% setting up directories
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

output_dir = 'E:\ds001205\derivatives\spm12';
output_dir

% listing subjects
folder_subj = get_subj_list(output_dir);
folder_subj = cellstr(char({folder_subj.name}')); % turn subject folders into a cellstr

opt = [];

% Get which participant is in which group
participants_file = fullfile(code_dir, 'inputs', 'event_tsvs','participants.tsv');
participants = spm_load(participants_file);
group_id = strcmp(participants.group, 'equalRange');

% remove excluded subjects
[participants, group_id, folder_subj] = ...
    rm_subjects(participants, group_id, folder_subj, 1)

nb_subj = numel(folder_subj);


%% figure out which GLMs to run
% set up all the possible of combinations of GLM possible given the
% different analytical options we have
[sets] = get_cfg_GLMS_to_run();
[opt, all_GLMs] = set_all_GLMS(opt, sets);


%%
cdt_ls = {...
    ' gamble_trial*bf(1) > 0'; ...
    ' gamble_trial*bf(1) < 0'; ...
    ' gamble_trialxgain^1*bf(1) > 0'; ...
    ' gamble_trialxgain^1*bf(1) < 0'; ...
    ' gamble_trialxloss^1*bf(1) > 0'; ...
    ' gamble_trialxloss^1*bf(1) < 0'; ...
    ' gamble_trialxEV^1*bf(1) > 0'; ...
    ' gamble_trialxEV^1*bf(1) < 0'; ...
    ' missed_trial*bf(1) > 0'; ...
    ' missed_trial*bf(1) < 0'; ...
    ' gamble_trial_button_press*bf(1) > 0'; ...
    ' gamble_trial_button_press*bf(1) < 0'};

contrast_ls = {...
    'gamble_trial>0'; ...
    'gamble_trial<0'; ...
    'gamble_trialxgain>0'; ...
    'gamble_trialxgain<0'; ...
    'gamble_trialxloss>0'; ...
    'gamble_trialxloss<0'; ...
    'gamble_trialxEV>0'; ...
    'gamble_trialxEV<0'; ...
    'missed_trial>0'; ...
    'missed_trial<0'; ...
    'gamble_trial_button_press>0'; ...
    'gamble_trial_button_press<0'};


%%
for iGLM = 1:size(all_GLMs)
    
    %% get configuration for this GLM
    cfg = get_configuration(all_GLMs, opt, iGLM);
    
    % set output dir for this GLM configutation
    analysis_dir = name_analysis_dir(cfg);
    grp_lvl_dir = fullfile (output_dir, 'group', analysis_dir );
    mkdir(grp_lvl_dir)
    
    contrasts_file_ls = struct('con_name', {}, 'con_file', {});
    
    
    %% list the fiels
    for isubj = 1:nb_subj
        
        %         subj_lvl_dir = fullfile ( ...
        %             output_dir, folder_subj{isubj}, analysis_dir);
        
        subj_lvl_dir = fullfile ( ...
            output_dir, folder_subj{isubj});
        
        load(fullfile(subj_lvl_dir, 'SPM.mat'))
        
        
        %% Stores names of the contrast images
        for iCtrst = 1:numel(contrast_ls)
            
            contrasts_file_ls(isubj).con_name{iCtrst,1} = ...
                SPM.xCon(iCtrst).name;
            
            contrasts_file_ls(isubj).con_file{iCtrst,1} = ...
                fullfile(subj_lvl_dir, SPM.xCon(iCtrst).Vcon.fname);
            
        end
        
    end
    
    
    %% ttest
    for i_ttest = 1:5
        
        switch i_ttest
            case 1
                % Parametric effect of gain:
                % Positive effect
                cdts = {' gamble_trialxgain^1*bf(1) > 0'}; %#ok<*NASGU>
                ctrsts = {'gamble_trialxgain>0'};
                subdir_name = 'gamble_trialxgain_sup_baseline';
                
            case 2
                % Parametric effect of loss:
                % Negative effect
                cdts = {' gamble_trialxloss^1*bf(1) < 0'};
                ctrsts = {'gamble_trialxloss<0'};
                subdir_name = 'gamble_trialxloss_inf_baseline';
                
            case 3
                % Parametric effect of loss:
                % Positive effect
                cdts = {' gamble_trialxloss^1*bf(1) > 0'};
                ctrsts = {'gamble_trialxloss>0'};
                subdir_name = 'gamble_trialxloss_sup_baseline';
                
            case 4
                % gamble trials themselves ('positive control')
                cdts = {' gamble_trial*bf(1) > 0'};
                ctrsts = {'gamble_trial>0'};
                subdir_name = 'gamble_trial_sup_baseline';
                
            case 5
                % gamble trials themselves ('positive control')
                cdts = {' gamble_trial*bf(1) < 0'};
                ctrsts = {'gamble_trial<0'};
                subdir_name = 'gamble_trial_inf_baseline';                
                
            case 6
                % button presses ('positive control')
                cdts = {' gamble_trial_button_press*bf(1) > 0'};
                ctrsts = {'gamble_trial_button_press>0'};
                subdir_name = 'gamble_trial_button_press_sup_baseline';
                
            case 7
                % button presses ('positive control')
                cdts = {' gamble_trial_button_press*bf(1) < 0'};
                ctrsts = {'gamble_trial_button_press<0'};
                subdir_name = 'gamble_trial_button_press_sup_baseline';                
                
        end
        
        ctrsts %#ok<*NOPTS>
        
        for iGroup = 1:2
            
            if iGroup==1
                grp_name = 'equalRange';
                subj_to_include = find(group_id(1:nb_subj)==1);
            else
                grp_name = 'equalIndifference';
                subj_to_include = find(group_id(1:nb_subj)==0);
            end
            
            grp_name
            
            % identify the right con images for each subject to bring to
            % the grp lvl as summary stat
            
            scans = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include);
            
            scans'
            
            matlabbatch = [];
            matlabbatch = set_ttest_batch(matlabbatch, ...
                fullfile(grp_lvl_dir, grp_name), ...
                scans, ...
                {subdir_name}, ...
                {'>'});
            
            spm_jobman('run', matlabbatch)
        end
        
    end
    
    %% two sample ttest
    
    % Equal range vs. equal indifference:
    %
    % Greater positive response to losses in amygdala for equal range condition vs. equal indifference condition.
    
    % Positive effect
    cdts = {' gamble_trialxloss^1*bf(1) > 0'};
    ctrsts = {'gamble_trialxloss>0'};
    subdir_name = 'loss_sup_baseline_range_sup_indiff';
    
    % identify the right con images for each subject to bring to
    % the grp lvl as summary stat
    subj_to_include = find(group_id(1:nb_subj)==1);
    scans1 = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include)
    
    subj_to_include = find(group_id(1:nb_subj)==0);
    scans2 = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include)
    
    scans{1,1} =  scans1;
    scans{2,1} =  scans2;
    
    matlabbatch = [];
    matlabbatch = set_ttest_batch(matlabbatch, ...
        fullfile(grp_lvl_dir), ...
        scans, ...
        {subdir_name}, ...
        {'>'});
    
    spm_jobman('run', matlabbatch)
    
end
