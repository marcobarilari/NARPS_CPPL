function matlabbatch = set_cdt_GLM_batch(matlabbatch, idx, irun, cdt, cfg)

if ~isempty(cdt.onset)
    
    % initialise
    if ~isfield(matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun), 'cond')
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond = [];
    end
    
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end+1).name = ...
        cdt.name;
    
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).tmod = 0;
    
    % set condition onsets
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).onset = ...
        cdt.onset ;
    
    % set duration
    % 0 for events
    if strcmp(cfg.design, 'event')
        duration = zeros( size(cdt.onset) );
        % for blocks
    elseif strcmp(cdt.name, 'gamble_trial') || strcmp(cdt.name, 'missed_trial')
        
        if strcmp(cfg.duration, 'whole')
            duration = cdt.duration;
        else
            % TO DO
            % opt.duration = {'whole' 'max_RT' 'subj_max_RT' 'median_RT' 'subj_median_RT'};
            error('other block duration than whole 4 secs block duration not implemented yet');
        end
        
        % for all other conditions (like button presses) we take the preset
        % durations (0 most of the time)
    else
        duration = cdt.duration;
        
    end
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).duration = ...
        duration;
    
    % setting parametric regressors
    if ~isempty(cdt.param)
        if numel(cdt.param)>1
            warning('there is more than one parametric modulator: make sure you get your orthogonalization right.')
        end
        for iParam = 1:numel(cdt.param)
            name = cdt.param{iParam};
            value = getfield(cdt, cdt.param{iParam});
            value = value - mean(value); % mean center the parameters
            
            matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).pmod(iParam).name = ...
                name;
            matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).pmod(iParam).param = ...
                value;
            matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).pmod(iParam).poly = ...
                1;
        end
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).orth = 0;
        
    else
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).pmod = ...
            struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).orth = 0;
    end
    
end

end