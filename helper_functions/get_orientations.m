function orientations = get_orientations(exp_conditions, ami_umi, delay, total_nr_trials)
% Obtains the to-be-maintained orientation for each individual trial. 
% Selects either the attended- or unattended orientations. 

orientations = zeros(1,total_nr_trials);

for i = (1:total_nr_trials)
    cue = exp_conditions(delay,i);                  % delay 1 is first row, delay 2 is second row

    if     ami_umi == 1 && cue == 1                 % if ami, append cued orientation
        orientations(i) = exp_conditions(3, i);
    elseif ami_umi == 1 && cue == 2
        orientations(i) = exp_conditions(4, i);
    elseif ami_umi == 2 && cue == 1                 % if umi, append uncued orientation
        orientations(i) = exp_conditions(4, i);
    elseif ami_umi == 2 && cue == 2
        orientations(i) = exp_conditions(3, i);
    end
    
end

orientations = round(orientations(:));

end