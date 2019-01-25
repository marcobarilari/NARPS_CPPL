function [opt, all_GLMs] = set_all_GLMS(opt)
% defines some more options for setting up GLMs and gets all possible
% combinations of GLMs to run

opt.HPF = 128; % 
opt.RT_correction = [0 1]; % RT correction (ON or OFF)
opt.design = {'event', 'block'}; 
opt.time_der = [0 1]; % time derivative (used or not )
opt.mvt = [0 1]; % mvt noise regressors (ON or OFF)

% list all possible GLMs to run
% sets{1} = 1:numel(opt.HPF);
% sets{end+1} = 1:numel(opt.RT_correction);
% sets{end+1} = 1:numel(opt.design); 
% sets{end+1} = 1:numel(opt.time_der);
% sets{end+1} = 1:numel(opt.mvt);

% comment the lines above and uncomment the following if you only want to
% run the pipelines for the published results 
sets{1} = 1;
sets{end+1} = 1; 
sets{end+1} = 1;
sets{end+1} = 1;
sets{end+1} = 2;

[a, b, c, d, e] = ndgrid(sets{:}); clear sets
all_GLMs = [a(:), b(:), c(:), d(:), e(:)];

end