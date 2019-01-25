function matlabbatch = set_extra_regress_batch(matlabbatch, idx, irun, cfg, RT_regressors_col, confounds)

% Inputs the reaction time parametric modulator regressors
if cfg.RT_correction
    for iRT_reg = 1:size(RT_regressors_col{irun},2)
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).regress(1,end+1).name = ...
            ['RT_par_mod-' num2str(iRT_reg)];
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).regress(1,end).val = ...
            RT_regressors_col{irun}(:,iRT_reg);
    end
end

% includes realignement parameters from the fMRIprep confounds
if cfg.mvt
    target_fields = {'X' 'Y' 'Z' 'RotX' 'RotY' 'RotZ'};
    for iField = 1:numel(target_fields)
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1, irun).regress(1,iField) = struct(...
            'name', target_fields{iField}, ...
            'val', getfield(confounds{irun}, target_fields{iField}) );
    end
else
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1, irun).regress = struct(...
        'name', {''}, 'val', {''});
end
matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).multi_reg{1} = '';
matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).multi{1} = '';


end