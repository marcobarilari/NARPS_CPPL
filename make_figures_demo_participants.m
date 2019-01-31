machine_id = 1;
[data_dir, code_dir, output_dir, fMRIprep_DIR] = set_dir(machine_id);

participants_file = fullfile(code_dir, 'inputs', 'event_tsvs','participants.tsv');
participants = spm_load(participants_file);

group_id = strcmp(participants.group, 'equalRange');
gender = strcmp(participants.gender, 'M');

nb_male_equalrange = sum(all([group_id gender], 2))
nb_male_equalindiff = sum(all([~group_id gender], 2))

age_equalrange = participants.age(group_id);
age_equalindiff = participants.age(~group_id);

boxplot([age_equalrange age_equalindiff])
ylabel('age')
xlabel('group')
set(gca, 'xticklabel', {'equal range' 'equal indifference'})