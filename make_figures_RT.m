% collects subject RT and plots how they are distributed
% across gain and loss on average at the group level and for each subject
% Also checks overall distributions of RT for each subjects and missed
% reponses.

clear
clc
close all

machine_id = 1;
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

% Get which participant is in which group
participants_file = fullfile(code_dir, 'inputs', 'event_tsvs','participants.tsv');
participants = spm_load(participants_file);

group_id = strcmp(participants.group, 'equalRange');

% remove excluded subjects
[participants, group_id] = ...
    rm_subjects(participants, group_id, [], 1);


for i_group = 0:1 %loop through each group
    
    group_idx = find(group_id==i_group); % index of each subject
    
    if i_group == 0
        gain_range = 10:2:40;
    else
        gain_range = 5:1:20;
    end
    loss_range = 5:1:20;
    
    range(i_group+1).gain = gain_range; % to keep track of those ranges for plotting
    range(i_group+1).loss = loss_range;
    
    for i_subj = 1:numel(group_idx)
        
        % get data for each subject
        subject = participants.participant_id{ group_idx(i_subj) };
        
        files_2_load = spm_select('FPList', ...
            fullfile(code_dir, 'inputs', 'event_tsvs'), ...
            ['^' subject '.*.tsv$']);
        
        no_resp = [];
        RT_mat = [];
        
        for i_file = 1:size(files_2_load)
            
            % load each event file
            data = spm_load(files_2_load(i_file, :));
            
            % count number of missing responses for that run
            no_resp(i_file) = sum(strcmp(data.participant_response, 'NoResp')); %#ok<*SAGROW>
            
            % initialize matrix to store results
            RT_mat(:, :, i_file) = nan(numel(loss_range), numel(gain_range));
            
            for i_trial = 1:numel(data.onset)
                loss = find( loss_range==data.loss(i_trial) ); % loss index
                gain = find( gain_range==data.gain(i_trial) ); % loss index
                if data.RT(i_trial)<.5 % only include RT with plausible RT
                    RT_mat(loss, gain, i_file) =  0; % store RT of this trial in matrix
                else
                    RT_mat(loss, gain, i_file) = data.RT(i_trial);
                end
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


%% plot RT
figure('name', 'RT')

CLIM = [1 2];

subplot(1, 2, 1)
imagesc( nanmean(RT_mat_grp{1},3) , CLIM )
axis square
title('RT equal indifference (seconds)')
ylabel('loss')
xlabel('gain')
set(gca, 'xtick', 1:2:numel(range(1).gain), ...
    'xticklabel', range(1).gain(1:2:numel(range(1).gain)), ...
    'ytick', 1:2:numel(range(1).loss), ...
    'yticklabel', range(1).loss(1:2:numel(range(1).loss)))
colorbar

subplot(1, 2, 2)
imagesc( nanmean(RT_mat_grp{2},3) , CLIM )
axis square
title('RT equal range (seconds)')
ylabel('loss')
xlabel('gain')
set(gca, 'xtick', 1:2:numel(range(2).gain), ...
    'xticklabel', range(2).gain(1:2:numel(range(2).gain)), ...
    'ytick', 1:2:numel(range(2).loss), ...
    'yticklabel', range(2).loss(1:2:numel(range(2).loss)))
colorbar


%% plot missed responses
figure('name', 'Missed responses')
bar(participants.noresp)
title('Missed responses')
ylabel('number of misses')
xlabel('subject')


%% plot RT times for each subject
figure('name', 'RT for each subject ')

subplot(1, 2, 1)

RT_to_plot = reshape(RT_mat_grp{1}, ...
    [size(RT_mat_grp{1},1) * size(RT_mat_grp{1},2) , size(RT_mat_grp{1},3)]);

boxplot(RT_to_plot)

title('RT distribution per subject  - equal indifference group')
ylabel('RT (secs)')
xlabel('subject')
set(gca, 'xtick', 1:2:size(RT_mat_grp{1},3), ...
    'xticklabel', 1:2:size(RT_mat_grp{1},3), ...
    'ytick', 0:.5:4, ...
    'yticklabel', 0:.5:4)


subplot(1, 2, 2)

RT_to_plot = reshape(RT_mat_grp{2}, ...
    [size(RT_mat_grp{2},1) * size(RT_mat_grp{2},2) , size(RT_mat_grp{2},3)]);

boxplot(RT_to_plot)

title('RT distribution per subject  - equal range group')
ylabel('RT (secs)')
xlabel('subject')
set(gca, 'xtick', 1:2:size(RT_mat_grp{1},3), ...
    'xticklabel', 1:2:size(RT_mat_grp{1},3), ...
    'ytick', 0:.5:4, ...
    'yticklabel', 0:.5:4)