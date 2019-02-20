%  This script uses the report from MRIQC (bold and T1) identify outliers using
%  robust statistics (interquartile range).
clear
clc

%%
thresh = 0.4; %FD threshold to "censor" timepoints

%% Load fMRIprep confound reports
% stores only the FD values and separates them into 2 groups

code_dir = pwd;
[~]  = addpath(fullfile(code_dir,'subfun'));

% Get which participant is in which group
participants_file = fullfile(code_dir, 'inputs', 'event_tsvs','participants.tsv');
participants = spm_load(participants_file);
group_id = strcmp(participants.group, 'equalRange');

FramewiseDisplacement = cell(2,1); % initialize

for i_group = 0:1 %loop through each group
    
    group_idx = find(group_id==i_group); % index of each subject
    
    for i_subj = 1:numel(group_idx)
        
        % get data for each subject
        subject = participants.participant_id{ group_idx(i_subj) }; %ID
        
        files_2_load = spm_select('FPList', ...
            fullfile(code_dir, 'inputs', 'fmriprep'), ...
            ['^' subject '.*.tsv$']); % list all the confounds files
        
        for i_file = 1:size(files_2_load)
            
            % load each event file
            data = spm_load(files_2_load(i_file, :));
            
            % collect the FD for each run / subject
            FramewiseDisplacement{i_group+1}(:,end+1) =  ...
                data.FramewiseDisplacement;
            
        end
        
    end
    
end


%%  plot proportion datapoint with Framewise Displacement > threshold
% for each group
close all

for i_group = 1:2
    
    if i_group==1
        group_name = 'equal indifference';
    else
        group_name = 'equal range';
    end
    
    figure('name', ['Framewise Displacement - ' group_name])

    hold on
    
    proportion = sum(FramewiseDisplacement{i_group} > thresh) ...
        / size(FramewiseDisplacement{i_group},1);
    
    bar(1.5:216.5, proportion)
    plot([1.5 216.5], [.1 .1], '--r') % plot limit at 10% of time points
    
    title(group_name)
    ylabel(sprintf('proportion time points FD > %0.1f mm / run', thresh))
    xlabel('subject')
    
    x_tick_label = char(participants.participant_id(group_id==(i_group-1)));
    x_tick_label = x_tick_label(:,5:end);

    set(gca, 'xtick', 1:4:size(FramewiseDisplacement{1},2), ...
        'xticklabel', x_tick_label, ...
        'ytick', 0:.05:.5, ...
        'yticklabel', 0:.05:.5, ...
        'fontsize', 8)
    
    axis([1 216 0 0.25])
    
end


