function onsets = create_missed_trial_cdt(onsets, cfg)
% Creates a missed condition from the RT and response parameters

% identify trials with short RT
is_missed = onsets(1,1).is_missed;
short_RT = onsets(1,1).RT < cfg.rm_unresp_trials.thres;
is_missed(short_RT) = true;

onsets = rmfield(onsets(1,1), 'is_missed');

% only create the condition is there is any missed trial
if any(is_missed)
    
    onsets(1,2).name = 'missed_trial';
    onsets(1,2).onset = onsets(1,1).onset(is_missed);
    onsets(1,2).duration = onsets(1,1).duration(is_missed);
    onsets(1,2).gain = onsets(1,1).gain(is_missed);
    onsets(1,2).loss = onsets(1,1).loss(is_missed);
    onsets(1,2).EV = onsets(1,1).EV(is_missed);
    onsets(1,2).RT = onsets(1,1).RT(is_missed);
    onsets(1,2).participant_response = ...
        onsets(1,1).participant_response(is_missed);
    
    % remove those trials from the original condition
    onsets(1,1).onset(is_missed) = [];
    onsets(1,1).duration(is_missed) = [];
    onsets(1,1).gain(is_missed) = [];
    onsets(1,1).loss(is_missed) = [];
    onsets(1,1).EV(is_missed) = [];
    onsets(1,1).RT(is_missed) = [];
    onsets(1,1).participant_response(is_missed) = [];
    
end

end