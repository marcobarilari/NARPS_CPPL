function [opt, all_GLMs] = set_all_GLMS(opt, sets)
% defines some more options for setting up GLMs and gets all possible
% combinations of GLMs to run

opt.explicit_mask = [0 1]; % use fMRIprep mask

opt.inc_mask_thres = [0 0.8]; % SPM threshold to define inclusive mask

opt.HPF = 128; % high pass filter

opt.design = {'block' 'event'}; % 'block', 'event'
opt.duration = {'whole' 'max_RT' 'subj_max_RT' 'median_RT' 'subj_median_RT'}; % whole -> whole stim duration
opt.RT_correction = [0 1]; % RT correction (ON or OFF)

opt.model_button_press = [0 1]; % add a separate regressor that models button presses
opt.rm_unresp_trials.do = [0 1]; % remove unresponded trials and trials with very short RT (< thres)
opt.rm_unresp_trials.thres = .500; % threshold to remove trials with very short RT (in seconds)

opt.time_der = [0 1]; % time derivative of HRF is present
opt.disp_der = [0 1]; % time derivative of HRF is present

opt.confounds = {...
    {'FramewiseDisplacement', 'WhiteMatter', 'CSF'}, ...
    {'X' 'Y' 'Z' 'RotX' 'RotY' 'RotZ'},...
    }; %list the confounds from fMRIprep (or SPM RP) to include 1 cell lists all the regressors to include

opt.FD_censor.do = [0 1]; % censor points with a framewise displacement superior to threshold
opt.FD_censor.thres = 0.5; % FD threshold to censor points (in mm)

opt.spher_cor = {'AR(1)' 'FAST' 'none'}; % non-sphericity correction used for the estimation

if ~exist('sets', 'var')
    % list all possible GLMs to run
    
    sets{1} = 1:numel(opt.explicit_mask);
    
    sets{end+1} = 1:numel(opt.inc_mask_thres);
    
    sets{end+1} = 1:numel(opt.HPF);
    
    sets{end+1} = 1:numel(opt.design);
    sets{end+1} = 1:numel(opt.duration);
    sets{end+1} = 1:numel(opt.RT_correction);
    
    sets{end+1} = 1:numel(opt.model_button_press);
    sets{end+1} = 1:numel(opt.rm_unresp_trials.do);
    sets{end+1} = 1:numel(opt.rm_unresp_trials.thres);
    
    sets{end+1} = 1:numel(opt.time_der);
    sets{end+1} = 1:numel(opt.disp_der);
    
    sets{end+1} = 1:numel(opt.confounds);
    
    sets{end+1} = 1:numel(opt.FD_censor.do);
    sets{end+1} = 1:numel(opt.FD_censor.thres);
    
    sets{end+1} = 1:numel(opt.spher_cor);
    
end

[a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15] = ...
    ndgrid(sets{:});
all_GLMs = [a1(:), a2(:), a3(:), a4(:), a5(:), a6(:), a7(:), a8(:), a9(:),...
    a10(:), a11(:), a12(:), a13(:), a14(:), a15(:)];

end