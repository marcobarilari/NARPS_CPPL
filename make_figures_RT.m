clear
clc
close all

machine_id = 1;
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

% Get which participant is in which group
participants_file = fullfile(code_dir, 'inputs', 'event_tsvs','participants.tsv');
participants = spm_load(participants_file);
group_id = strcmp(participants.group, 'equalRange');


for i_group = 0:1 %loop through each group
    
    group_idx = find(group_id==i_group); % index of each subject
    
    for i_subj = 1:numel(group_idx)
        
        % get data for each subject
        subject = participants.participant_id{ group_idx(i_subj) };
        
        files_2_load = spm_select('FPList', ...
            fullfile(code_dir, 'inputs', 'event_tsvs'), ...
            ['^' subject '.*.tsv$']);
        
        % load each event file
        no_resp = [];
        RT_mat = [];
        
        for i_file = 1:size(files_2_load)
            data = spm_load(files_2_load(i_file, :));
            
            % define gain and loss range for that subject
            if i_file==1
                gain_range = unique(data.gain);
                loss_range = unique(data.loss);
            end
            
            % count number of missing responses for that run
            no_resp(i_file) = sum(strcmp(data.participant_response, 'NoResp')); %#ok<*SAGROW>

            % initialize matrix to store results
            RT_mat(:, :, i_file) = nan(numel(loss_range), numel(gain_range));
            
            for i_trial = 1:numel(data.onset)
                loss = find( loss_range==data.loss(i_trial) ); % loss index
                gain = find( gain_range==data.gain(i_trial) ); % loss index
                RT_mat(loss, gain, i_file) =  data.RT(i_trial); % store RT of this trial in matrix
            end
        end
        
        % store how many missed responses for that subject
        participants.noresp(group_idx(i_subj),1) = sum(no_resp);
        
        % there should be only one type of trial for each gain/loss
        % combination
        check_norepeat = sum(isnan(RT_mat),3);
        if any(check_norepeat(:)~=3)
            error('Something is off: there should be no trial type repeat.')
        end
        
        % average RT over runs
        RT_mat = nanmean(RT_mat, 3);
        RT_mat(RT_mat==0) = NaN; %if a trial was missed we replace its 0 value by NaN
        
        % append to the group results
        RT_mat_grp{i_group+1}(:,:,i_subj) = nanmean(RT_mat, 3);
        
    end

end


%% plot
figure('name', 'RT')

CLIM = [1 2];

subplot(1, 2, 1)
imagesc( nanmean(RT_mat_grp{1},3) , CLIM )
axis square

subplot(1, 2, 2)
imagesc( nanmean(RT_mat_grp{2},3) , CLIM )
axis square


figure('name', 'Missed responses')
bar(participants.noresp)
