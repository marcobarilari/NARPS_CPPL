%  This script uses the report from fmriprep to estimate the number of
%  timepoints in framewise displacement timeseries with values superior to
%  threshold.
% https://fmriprep.readthedocs.io/en/stable/outputs.html

% plots the proportion of timepoints per run (to identidy runs with that goes above a limit)
% also plots the sum of the proportion of timepoints over the 4 runs to
% identify who move a lot but for whom no run goes above the threshold

clear
clc

%%
thresh = 0.5; %FD threshold to "censor" timepoints

%% Load fMRIprep confound reports
% stores only the FD values and separates them into 2 groups

code_dir = pwd;
[~]  = addpath(fullfile(code_dir,'subfun'));

% Get which participant is in which group
participants_file = fullfile(code_dir, 'inputs', 'event_tsvs','participants.tsv');
participants = spm_load(participants_file);
group_id = strcmp(participants.group, 'equalRange');

[participants, group_id] = ...
    rm_subjects(participants, group_id, [], 0);

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

    
    proportion = sum(FramewiseDisplacement{i_group} > thresh) ...
        / size(FramewiseDisplacement{i_group},1);
    
    summed_proportion = sum(reshape(proportion, [4, size(proportion,2)/4]));

    %%
    figure('name', ['Framewise Displacement - ' group_name])

    hold on
    
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
    
    %%
    figure('name', ['Framewise Displacement - ' group_name])

    hold on
    
    bar(1:54, summed_proportion)
    plot([1 54], [.1 .1], '--r') % plot limit at 10% of time points
    
    title(group_name)
    ylabel(sprintf('summed of proportions per run of time points FD > %0.1f mm', thresh))
    xlabel('subject')
    
    x_tick_label = char(participants.participant_id(group_id==(i_group-1)));
    x_tick_label = x_tick_label(:,5:end);

    set(gca, 'xtick', 1:size(FramewiseDisplacement{1},2), ...
        'xticklabel', x_tick_label, ...
        'ytick', 0:.05:.5, ...
        'yticklabel', 0:.05:.5, ...
        'fontsize', 8)
    
    axis([.5 54.5 0 0.25])
    
end


