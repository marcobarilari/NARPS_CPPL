function analysis_dir = name_analysis_dir(cfg)
% create name of the folder given the GLM configuraton

analysis_dir = [ ...
    'GLM_' ...
    'HPF-' sprintf('%03.0f',cfg.HPF) '_' ...
    'RT-' num2str(cfg.RT_correction) '_' ...
    'block-' cfg.block_type '_' ...
    'timeder-' num2str(cfg.time_der) '_' ...
    'mvt-' num2str(cfg.mvt) '_' ...
    ];

fprintf('\n\nRunning %s\n\n', analysis_dir)

end

