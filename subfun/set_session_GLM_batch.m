function matlabbatch = set_session_GLM_batch(matlabbatch, idx, data, irun, cfg)
% Sets the parameters the GLM model for one fMRI run

% set high pass filter
matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).hpf = cfg.HPF;

% list all the volume of the 4D nifti image of this run
[direc, name, ext] = spm_fileparts(data{irun});
matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).scans = ...
    cellstr(spm_select('ExtFPList', direc, ['^' name ext '$'], Inf));

end