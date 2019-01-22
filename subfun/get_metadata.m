function [opt] = get_metadata(BIDS, task)
% get_metadata_func(BIDS, subjects)

subjs_ls = spm_BIDS(BIDS, 'subjects');
metadata = spm_BIDS(BIDS, 'metadata', 'sub', subjs_ls{1}, 'type', 'bold', ...
    'task', task, 'run', '01');

opt.nb_slices = numel(metadata.SliceTiming);
opt.TR = metadata.RepetitionTime;
opt.TA = opt.TR - (opt.TR/opt.nb_slices);
opt.acquisition_order = metadata.SliceTiming*1000;
opt.slice_reference = [1 floor(opt.nb_slices/2)];
end
