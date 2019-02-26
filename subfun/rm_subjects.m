function [ppp, grp_id, folder_subj] = rm_subjects(ppp, grp_id, folder_subj, rm_do)
% Removes the particpants from the subject listing that have been
% excluded because of their func/anat/beh data
% ppp = participants structure resulting from loading the participant.tsv
% file


if ~exist('rm_do', 'var')
    rm_do = false;
end
if ~exist('folder_subj', 'var')
    folder_subj = [];
end

if rm_do
    % Remove outliers in terms of fMRI or behavior
    subj_to_exclude = {
        'sub-016', ...
        'sub-030', ...
        'sub-088', ...
        'sub-100', ...
        'sub-118', ...
        'sub-022', ...
        'sub-110', ...
        'sub-116', ...
        'sub-056'}'; %sub-056 seems to have buttons switched.
else
    subj_to_exclude = '';
end

% Remove excluded subjects
to_rm = ismember(ppp.participant_id, subj_to_exclude);
grp_id(to_rm) = [];
ppp.participant_id(to_rm) = [];
ppp.group(to_rm) = [];
ppp.gender(to_rm) = [];
ppp.age(to_rm) = [];

if ~isempty(folder_subj)
    to_rm = ismember(folder_subj, subj_to_exclude);
    folder_subj(to_rm) = [];
end

end
