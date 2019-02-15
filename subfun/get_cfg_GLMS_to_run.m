function [sets] = get_cfg_GLMS_to_run()
% will load the sets of of GLM to compute at the subject level.
% see set_all_GLMS for what each analytical choice corresponds to

% opt.explicit_mask = [0 1]; 
sets{1} = 2;

% opt.inc_mask_thres = [0 0.8]; 
sets{end+1} = 1;

% opt.HPF = 128; % high pass filter
sets{end+1} = 1;

% opt.design = {'block' 'event'}; 
sets{end+1} = 1;  
% opt.duration = {'whole' 'max_RT' 'subj_max_RT' 'median_RT' 'subj_median_RT'}; 
sets{end+1} = 1;
% opt.RT_correction = [0 1]; 
sets{end+1} = 1;

% opt.model_button_press = [0 1]; 
sets{end+1} = 2;
% opt.rm_unresp_trials.do = [0 1];
sets{end+1} = 2;
% opt.rm_unresp_trials.thres = .500; 
sets{end+1} = 1;

% opt.time_der = [0 1]; 
sets{end+1} = 1;
% opt.disp_der = [0 1]; 
sets{end+1} = 1;

% opt.confounds = {...
%     {'FramewiseDisplacement', 'WhiteMatter', 'CSF'}, ...
%     {'X' 'Y' 'Z' 'RotX' 'RotY' 'RotZ'},...
%     }; 
sets{end+1} = 1;
% opt.FD_censor.do = [0 1]; 
sets{end+1} = 1;
% opt.FD_censor.thres = 0.5; 
sets{end+1} = 1;

% opt.spher_cor = {'AR1' 'FAST' 'none'}; 
sets{end+1} = 2;
    
end