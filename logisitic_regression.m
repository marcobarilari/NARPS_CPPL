% runs a logistic regressions on the subject response (1 = accept ; 0 =
% reject) to be explained by gain, loss + constant for every trial

% check the distribution of beta_gain and beta_loss 

% check the distribution of lambda (- beta_loss / beta_gain) across age 
% and gender in each group

clear
clc
close all

machine_id = 1;
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

% Get which participant is in which group
participants_file = fullfile(code_dir, 'inputs', 'event_tsvs','participants.tsv');
participants = spm_load(participants_file);

% Remove outliers in terms of fMRI or behavior
% subj_to_remove = {
%     'sub-016', ...
%     'sub-030', ...
%     'sub-088', ...
%     'sub-100', ...
%     'sub-118', ...
%     'sub-022', ...
%     'sub-110', ...
%     'sub-116', ...
%     'sub-056'}'; %sub-056 seems to have buttons switched.
subj_to_remove = '';

remove = ismember(participants.participant_id, subj_to_remove);

participants.participant_id(remove) = [];
participants.group(remove) = [];
participants.gender(remove) = [];
participants.age(remove) = [];

group_id = strcmp(participants.group, 'equalRange');

for i_group = 0:1 %loop through each group
    
    group_idx = find(group_id==i_group); % index of each subject
    
    for i_subj = 1:numel(group_idx)
        
        % get data for each subject
        subject = participants.participant_id{ group_idx(i_subj) };
        
        files_2_load = spm_select('FPList', ...
            fullfile(code_dir, 'inputs', 'event_tsvs'), ...
            ['^' subject '.*.tsv$']);
        
        gain_all = [];
        loss_all = [];
        resp_all = [];
        
        for i_file = 1:size(files_2_load)
            
            % load each event file
            data = spm_load(files_2_load(i_file, :));
            
            % kick out trials with no response or with responses below 500
            % ms
            to_remove = any(...
                [strcmp(data.participant_response, 'NoResp'), ...
                 data.RT<0.5], 2);
            
             % get gain, loss value of each trial
             gain = data.gain(~to_remove);
             loss = data.loss(~to_remove);

             % convert responses to accept (1) or reject (0)
             resp = any(...
                 [strcmp(data.participant_response, 'weakly_accept'), ... 
                  strcmp(data.participant_response, 'strongly_accept')], 2); 
             resp(to_remove) = [];
             
             % stores them to do the regression collasped across runs.
             gain_all = cat(1,gain_all, gain);
             loss_all = cat(1,loss_all, loss);
             resp_all = cat(1,resp_all, resp);
             
             % mean center gain and losses
             gain = gain-mean(gain);
             loss = loss-mean(loss);
             
             % create design matrix
             X = [gain loss ones(size(gain))];
             Y = round(resp);
             
             % logistic regression using GLM
             B{i_group+1}(i_subj, :, i_file) = pinv(X)*Y; %#ok<*SAGROW>
%              B = mnrfit(X,Y)

        end
        
        % GLM on all data
        gain_all = gain_all - mean(gain_all);
        loss_all = loss_all - mean(loss_all);
        X = [gain_all loss_all ones(size(gain_all))];
        Y = round(resp_all);
        B_all{i_group+1}(i_subj, :) = pinv(X)*Y; %#ok<*SAGROW>

    end
    
end


%% Compute Betas and lambdas

% Beta_1 = B_all{1}(:,1:2,:);
Beta_1 = mean(B{1}(:,1:2,:),3);
Beta_1(:,2) = Beta_1(:,2)*-1;

% Beta_2 = B_all{2}(:,1:2,:);
Beta_2 = mean(B{2}(:,1:2,:),3);
Beta_2(:,2) = Beta_2(:,2)*-1;

Lambda_1 = Beta_1(:,2)./Beta_1(:,1);
Lambda_2 = Beta_2(:,2)./Beta_2(:,1);


%% plot betas
close all

figure('name', 'betas')

subplot(1, 2, 1)
boxplot(Beta_1(:,1:2))

title('Beta_{log reg} equal indifference')
set(gca, 'xtick', 1:2, ...
    'xticklabel', {'gain' 'loss'})
xlabel('Beta')

% axis([0.5 2.5 0 0.1])


subplot(1, 2, 2)
boxplot(Beta_2(:,1:2))

title('Beta_{log reg} equal range')
set(gca, 'xtick', 1:2, ...
    'xticklabel', {'gain' 'loss'})
xlabel('Beta')

% axis([0.5 2.5 0 0.1])


%% plot lambda ('- beta_{loss} / beta_{gain}') 
figure('name', 'lambdas')

subplot(1, 2, 1)
boxplot(Lambda_1)

title('lambda - equal indifference')
set(gca, 'xtick', 1, ...
    'xticklabel', {'- beta_{loss} / beta_{gain}'})
xlabel('lambda')

% axis([0.5 1.5 0 5])


subplot(1, 2, 2)
boxplot(Lambda_2)

title('lambda - equal range')
set(gca, 'xtick', 1, ...
    'xticklabel', {'- beta_{loss} / beta_{gain}'})
xlabel('lambda')

% axis([0.5 1.5 0 5])


%% plot lambda ('- beta_{loss} / beta_{gain}') = f(gender)
figure('name', 'lambdas = f(gender)')

subplot(1, 2, 1)

gender = participants.gender(group_id==0);
M = strcmp(gender, 'M');

boxplot(Lambda_1, M)

title('lambda - equal indifference')
set(gca, 'xtick', 1:2, ...
    'xticklabel', {'Male', 'Female'})
xlabel('gender')
ylabel('lambda')

% axis([0.5 2.5 0 5])


subplot(1, 2, 2)

gender = participants.gender(group_id==1);
M = strcmp(gender, 'M');

boxplot(Lambda_2, M)

title('lambda - equal range')
set(gca, 'xtick', 1:2, ...
    'xticklabel', {'Male', 'Female'})
xlabel('gender')
ylabel('lambda')

% axis([0.5 2.5 0 5])


%% plot lambda ('- beta_{loss} / beta_{gain}') = f(age)
figure('name', 'lambdas = f(gender)')

subplot(1, 2, 1)

age = participants.age(group_id==0);

scatter(age, Lambda_1)
[r,p] = corr(age, Lambda_1)
numel(age)

title('lambda - equal indifference')
xlabel('age')
ylabel('lambda')

% axis([18 38 0 5])


subplot(1, 2, 2)

age = participants.age(group_id==1);

scatter(age, Lambda_2)
[r,p] = corr(age, Lambda_2)
numel(age)

title('lambda - equal range')
xlabel('age')
ylabel('lambda')

% axis([18 38 0 5])
