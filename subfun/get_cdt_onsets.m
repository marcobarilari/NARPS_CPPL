function [onsets] = get_cdt_onsets(onsets, iRun)
% Defines the different conditions we will use in the GLMs with their onset and durations 

% identify missed responses
onsets{iRun}.is_missed = strcmp(onsets{iRun}.participant_response, 'NoResp');

end

