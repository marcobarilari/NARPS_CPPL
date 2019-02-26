% collects subject responses (1 = weak accept ; 2 = strong accept ; -1 =
% weak reject ; -2 = strong reject) and plots how they are distributed
% across gain and loss on average at the group level and for each subject

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
        accept_mat = [];
        
        for i_file = 1:size(files_2_load)
            
            % load each event file
            data = spm_load(files_2_load(i_file, :));
            
            resp = nan(size(data.participant_response));
            resp(strcmp(data.participant_response, 'weakly_accept')) = 1;
            resp(strcmp(data.participant_response, 'strongly_accept')) = 2;
            resp(strcmp(data.participant_response, 'strongly_reject')) = -2;
            resp(strcmp(data.participant_response, 'weakly_reject')) = -1;
            
            % initialize matrix to store results
            accept_mat(:, :, i_file) = NaN(numel(loss_range), numel(gain_range)); %#ok<*SAGROW>
            
            for i_trial = 1:numel(data.onset)
                loss = find( loss_range==data.loss(i_trial) ); % loss index
                gain = find( gain_range==data.gain(i_trial) ); % loss index
                if data.RT(i_trial)>=.5
                    accept_mat(loss, gain, i_file) = resp(i_trial);
                end
            end
        end
        
        accept_mat_grp{i_group+1}(:,:,i_subj) = nanmean(accept_mat, 3);
        
    end
    
end


%% plot accept-rejects
figure('name', 'accept')

CLIM = [-2 2];

subplot(1, 2, 1)
imagesc( nanmean(accept_mat_grp{1},3) , CLIM )
axis square
title('accept - equal indifference')
ylabel('loss')
xlabel('gain')
set(gca, 'xtick', 1:2:numel(range(1).gain), ...
    'xticklabel', range(1).gain(1:2:numel(range(1).gain)), ...
    'ytick', 1:2:numel(range(1).loss), ...
    'yticklabel', range(1).loss(1:2:numel(range(1).loss)))
colorbar

subplot(1, 2, 2)
imagesc( nanmean(accept_mat_grp{2},3) , CLIM )
axis square
title('accept - equal range')
ylabel('loss')
xlabel('gain')
set(gca, 'xtick', 1:2:numel(range(2).gain), ...
    'xticklabel', range(2).gain(1:2:numel(range(2).gain)), ...
    'ytick', 1:2:numel(range(2).loss), ...
    'yticklabel', range(2).loss(1:2:numel(range(2).loss)))
colorbar


%% plot all subjects

CLIM = [-2 2];

for i_group = 0:1 %loop through each group
    
    if i_group == 0
        figure('name', 'accept - subject - equal indifference')
    else
        figure('name', 'accept - subject - equal range')
    end
    
    group_idx = find(group_id==i_group);
    
    mn = length(group_idx);
    n  = round(mn^0.4);
    m  = ceil(mn/n);
    
    for i_subj = 1:numel(group_idx)
        
        subplot(m, n, i_subj)
        
        % get data for each subject
        subject = participants.participant_id{ group_idx(i_subj) };
        
        imagesc( accept_mat_grp{i_group+1}(:,:,i_subj) , CLIM )
        axis square
        title(subject)
        set(gca, 'xtick', [], ...
            'ytick', [])
    end
end