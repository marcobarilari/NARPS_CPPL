function analysis_dir = name_analysis_dir(cfg)
% create name of the folder given the GLM configuraton

if ~isempty(cfg.confounds{1})
    condounds = char(cfg.confounds{1}');
    condounds = condounds(:,[1:3 end])';
    condounds = strrep(condounds(:)', ' ', '');
else
    condounds = '0';
end

analysis_dir = [ ...
    'GLM_' ...
    'EM-' num2str(cfg.explicit_mask) '_' ...
    'MT-' num2str(cfg.inc_mask_thres*100) '_' ...
    'HPF-' sprintf('%03.0f',cfg.HPF) '_' ...
    'Des-' cfg.design{1} '_' ...
    'Dur-' cfg.duration{1} '_' ...
    'RT-' num2str(cfg.RT_correction) '_', ...
    'BP-' num2str(cfg.model_button_press) '_' ...
    'UT-' num2str(cfg.rm_unresp_trials.do) '_' ...
    'ST-' num2str(cfg.rm_unresp_trials.thres*1000) '_' ...
    'TD-' num2str(cfg.time_der) '_' ...
    'DD-' num2str(cfg.disp_der) '_' ...
    'Con-' condounds '_' ...
    'FD-' num2str(cfg.FD_censor.do) '_' ...
    'FD-' num2str(cfg.FD_censor.thres*1000) '_' ...
    'SC-' cfg.spher_cor{1}(1:2) ...
    ];

fprintf('  %s\n', analysis_dir)

end
