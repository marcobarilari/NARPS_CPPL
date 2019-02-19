function onsets = create_button_press_cdt(onsets)
% Creates a button press condition for each condition

NbCdt = size(onsets,2);

for iCdt = 1:NbCdt
    
    responded_trials = onsets(1,iCdt).RT > 0;
    
    if any(responded_trials)
        onsets(1,end+1).name = [onsets(1,iCdt).name '_button_press']; %#ok<AGROW>
        onsets(1,end).onset = ...
            onsets(1,iCdt).onset + onsets(1,iCdt).RT(responded_trials);
        onsets(1,end).duration = zeros(sum(responded_trials),1);
        onsets(1,end).gain = onsets(1,iCdt).gain(responded_trials);
        onsets(1,end).loss = onsets(1,iCdt).loss(responded_trials);
        onsets(1,end).EV = onsets(1,iCdt).EV(responded_trials);
        onsets(1,end).RT = [];
        onsets(1,end).participant_response = ...
            onsets(1,iCdt).participant_response(responded_trials);
    end
    
end

end