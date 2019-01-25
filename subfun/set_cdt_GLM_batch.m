function matlabbatch = set_cdt_GLM_batch(matlabbatch, idx, irun, cdt, cfg)

if ~isempty(cdt.onset)
    
    % initialise
    if ~isfield(matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun), 'cond')
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond = [];
    end
    
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end+1).name = cdt.name;
    
    % set duration (0 for events)
    if strcmp(cfg.design, 'event')
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).duration = 0;
    elseif strcmp(cfg.design, 'block')
        error('not implemented yet')
    end
    
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).tmod = 0;

    % set condition onsets
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).onset = ...
        cdt.onset ;
    
    % setting parametric regressors
    if isfield(cdt,  'param')
        for iParam = 1:numel(cdt.param)
            matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).pmod(iParam) = ...
                struct(...
                'name', cdt.param{iParam},...
                'param', getfield(cdt, cdt.param{iParam}),...
                'poly', 1);
        end
    else
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).pmod = ...
            struct('name',{},'param',{}, 'poly', {});
    end
    
end

end