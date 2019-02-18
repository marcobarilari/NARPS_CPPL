function explicit_mask = create_mask(subj_dir, folder_subj)

    explicit_mask = spm_select('FPList', ...
        subj_dir ,...
        ['^' folder_subj ...
        '_task-MGT_run-.*_bold_space-MNI152NLin2009cAsym_brainmask.nii$'] );
    
    hdr = spm_vol(explicit_mask);
    mask = any(spm_read_vols(hdr), 4);
    
    hdr =  hdr(1);
    hdr.fname = fullfile(subj_dir, ...
        [folder_subj '_task-MGT_bold_space_brainmask.nii']);
    spm_write_vol(hdr, mask);
    
    explicit_mask = hdr.fname;

end