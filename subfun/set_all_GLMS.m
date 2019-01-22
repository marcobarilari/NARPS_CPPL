function [opt, all_GLMs] = set_all_GLMS(opt)
% defines some more options for setting up GLMs and gets all possible
% combinations of GLMs to run

opt.HPF = [Inf 100 200]; % HPF none, 100, 200 (original study was 200)
opt.RT_correction = [0 1]; % RT correction (original study had both)
opt.block_type = {'event' 'block'}; % % Blocks of none, Exp83, Exp100, square100 (original study was Exp100)
opt.time_der = [0 1]; % time derivative (used or not ; original study was used)
opt.mvt = [0 1]; % mvt noise regressors (ON or OFF ; original study was ON)

% list all possible GLMs to run
sets{1} = numel(opt.HPF);
sets{end+1} = 1:numel(opt.RT_correction);
sets{end+1} = [1 numel(opt.block_type)]; %1:numel(opt.block_type);
sets{end+1} = numel(opt.time_der);
sets{end+1} = numel(opt.mvt);

% comment the lines above and uncomment the following if you only want to
% run the pipelines for the published results 
% sets{1} = 1;
% sets{end+1} = 2; 
% sets{end+1} = 1;
% sets{end+1} = 1;
% sets{end+1} = 3;

[a, b, c, d, e] = ndgrid(sets{:}); clear sets
all_GLMs = [a(:), b(:), c(:), d(:), e(:)];

end