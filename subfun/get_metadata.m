function [opt] = get_metadata(BIDS, opt)
% get_metadata_func(BIDS, subjects)

if any( ~[ ...
        isfield(opt, 'nb_slices') ...
        isfield(opt, 'acquisition_order') ...
        isfield(opt, 'TR') ...
        isfield(opt, 'TA') ...
        isfield(opt, 'slice_reference') ...
        ])
    
    subjs_ls = spm_BIDS(BIDS, 'subjects');
    
    runs_ls = spm_BIDS(BIDS, 'runs', 'sub', subjs_ls{1}, 'type', 'bold', ...
        'task', opt.task);
    
    metadata = spm_BIDS(BIDS, 'metadata', 'sub', subjs_ls{1}, 'type', 'bold', ...
        'task', opt.task, 'run', runs_ls{1});
    
    % get the number of slices and slice timing info in orginal data (use the 1rst run of the 1rst
    % subject)
    if isfield('SliceTiming', metadata) % from metadata if possible
        
        opt.nb_slices = numel(metadata{1}.SliceTiming); %
        opt.acquisition_order = metadata{1}.SliceTiming*1000;
        
    else % from the header of the file otherwise (no slice timing data in header though :-( )
        bold_data = spm_BIDS(BIDS, 'data', 'sub', subjs_ls{1}, 'type', 'bold', ...
            'task', opt.task, 'run', runs_ls{1});
        
        filename = unzip_file(bold_data{1});
        
        hdr = spm_vol(filename);
        
        opt.nb_slices = hdr(1).dim(3);
    end
    
    % get the rest of the metadata
    opt.TR = metadata{1}.RepetitionTime;
    
    opt.TA = opt.TR - (opt.TR/opt.nb_slices); % acquisition time
    
    opt.slice_reference = floor(opt.nb_slices/2); % reference slice
    
    
end

end
