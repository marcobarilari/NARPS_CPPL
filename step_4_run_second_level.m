% runs group level on the McGurk experiment and export the results corresponding to those
% published in the NIDM format

% t-test
% all events > baseline
% all blocks > baseline

%% parameters
clear all
clc

machine_id = 0;% 0: container ;  1: Remi ;  2: Marco


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


%%
cdt_ls = {...
    'mcgurk_con_aud', ...
    'mcgurk_con_fus', ...
    'mcgurk_con_other', ...
    'mcgurk_inc_aud', ...
    'mcgurk_inc_fus', ...
    'mcgurk_inc_other', ...
    'con_aud_vis', ...
    'con_other', ...
    'inc_aud', ...
    'inc_vis', ...
    'inc_other', ...
    'missed', ...
    'con_block', ...
    'inc_block'};

contrast_ls = {...
    ' con_aud_vis', ...
    ' inc_aud', ...
    ' mcgurk_con_aud', ...
    ' mcgurk_con_fus', ...
    ' mcgurk_inc_aud', ...
    ' mcgurk_inc_fus', ...
    ' con_block', ...
    ' inc_block', ...
    'all_events', ...
    'all_blocks'};

%%
for iGLM = 1:size(all_GLMs)
    
    %% get configuration for this GLM
    cfg = get_configuration(all_GLMs, opt, iGLM);
    
    % set output dir for this GLM configutation
    analysis_dir = name_analysis_dir(cfg);
    grp_lvl_dir = fullfile (OUTPUT_DIR, analysis_dir );
    mkdir(grp_lvl_dir)
    
    contrasts_file_ls = struct('con_name', {}, 'con_file', {});
    
    nb_events = {};
    
    %%
    for isubj = 1:nb_subj

        subj_lvl_dir = fullfile ( ...
            OUTPUT_DIR, '..', ...
            ['sub-' subj_ls{isubj}], analysis_dir);
        
        load(fullfile(subj_lvl_dir, 'SPM.mat'))
        
        %% Count how many events for each condition / session / subject
        for iCdt = 1:numel(cdt_ls)
            
            nb_events{iCdt, isubj} = []; %#ok<SAGROW>
            
            for iSess = 1:numel(SPM.Sess)
                
                cdt_in_sess = cat(1,SPM.Sess(iSess).U(:).name);
                cdt_idx = contains(cdt_in_sess, cdt_ls{iCdt});
                
                if any(cdt_idx)
                    nb_event_this_sess = numel(SPM.Sess(iSess).U(cdt_idx).ons);
                else
                    nb_event_this_sess = 0;
                end
                
                nb_events{iCdt, isubj}(end+1) = nb_event_this_sess;
                
            end
        end
        
        %% Stores names of the contrast images
        for iCtrst = 1:numel(contrast_ls)
            
            contrasts_file_ls(isubj).con_name{iCtrst,1} = ...
                SPM.xCon(iCtrst).name;
            
            contrasts_file_ls(isubj).con_file{iCtrst,1} = ...
                fullfile(subj_lvl_dir, SPM.xCon(iCtrst).Vcon.fname);
            
        end
        
    end

    
    %% EVENTS
    % paired ttest con_aud VS inc_aud
    cdts = {'con_aud_vis', 'inc_aud'};
    ctrsts = {' con_aud_vis', ' inc_aud'};
    
    subj_to_include = find_subj_to_include(cdt_ls, cdts, nb_events);
    scans = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include);

    matlabbatch = [];
    matlabbatch = set_ttest_batch(matlabbatch, grp_lvl_dir, scans, ...
        {'CON_aud', 'INC_aud'}, ...
        {'>','<','+>'});
    
    spm_jobman('run', matlabbatch)
    
    
    % ttest for all events
    ctrsts = {'all_events'};
    subj_to_include = 1:nb_subj;

    scans = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include);

    matlabbatch = [];
    matlabbatch = set_ttest_batch(matlabbatch, grp_lvl_dir, scans, ...
            {'all_events'}, ...
            {'>','<'});
    
    spm_jobman('run', matlabbatch)
    
    
    

    
    
end
