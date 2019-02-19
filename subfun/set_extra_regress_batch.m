function matlabbatch = set_extra_regress_batch(matlabbatch, idx, irun, cfg, RT_regressors_col, confounds)

extra_regress = 1;
% Inputs the reaction time parametric modulator regressors
if cfg.RT_correction
    error('RT parametric regressors not implemented yet')
    for iRT_reg = 1:size(RT_regressors_col{irun},2)
        
        name = ['RT_par_mod-' num2str(iRT_reg)];
        value = RT_regressors_col{irun}(:,iRT_reg);
        
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).regress(1,extra_regress) = ...
            struct(...
            'name', name, ...
            'val', value );

        extra_regress = extra_regress + 1;
    end
end

% includes realignement parameters from the fMRIprep confounds
if ~isempty(cfg.confounds)
    target_fields = cfg.confounds{1};
    for iField = 1:numel(target_fields)
        
        name = target_fields{iField};
        value = getfield(confounds{irun}, target_fields{iField});
        
        if isnan(value(1))
            value(1) = 0;
        end
        if any(isnan(value))
            warning('NaN values one of the extra regressors.')
        end
        
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1, irun).regress(1,extra_regress) = ...
            struct(...
            'name', name, ...
            'val', value );
        
        extra_regress = extra_regress + 1;
    end
else
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1, irun).regress = struct(...
        'name', {''}, 'val', {''});
end

% compute scrubbing regressors
if cfg.FD_censor.do
    
    to_censor = ...
        confounds{irun}.FramewiseDisplacement > cfg.FD_censor.thres;
    
    if any(to_censor)
        
        to_censor = find(to_censor);
        
        for i_censor = 1:numel(to_censor)
            
            reg_name = sprintf('censor_%02.0f', i_censor);
            value = zeros(size(matlabbatch{idx}.spm.stats.fmri_spec.sess(1, irun).scans));
            value(to_censor(i_censor)) = 1;
            
            matlabbatch{idx}.spm.stats.fmri_spec.sess(1, irun).regress(1,extra_regress) = struct(...
                'name', reg_name, ...
                'val', value );
            
            extra_regress = extra_regress + 1;
        end
    end
    
end

matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).multi_reg{1} = '';
matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).multi{1} = '';


end