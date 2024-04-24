function TR_indices = get_stimulus_TRs(pp_nr, condition)
% Returns TR indices corresponding to stimulus display


% Get correct file paths for this pp
[path, exp_results_files, exp_conditions_files] = get_exp_files(pp_nr);

% Load experimental data
[exp_timings_onsets, exp_conditions, total_nr_trials] = load_exp_data(pp_nr, exp_results_files, exp_conditions_files);

if condition == 1
    % List the relevant TR indices
    TR_indices = zeros(total_nr_trials, 3);
            
    for i = (1:total_nr_trials)
        stim_onset = exp_timings_onsets(2,i) + 4.5;            % row2=stimulus1, account for HRF
    
        stim_TR_index = floor(stim_onset/1.5) + 1;            % compute TR index
    
        TR_indices(i,:) = stim_TR_index:1:stim_TR_index+2;    % add TR indices 1-3
    end

elseif condition == 2
    % List the relevant TR indices
    TR_indices = zeros(total_nr_trials*2, 3);
            
    for i = (1:total_nr_trials)
        stim1_onset = exp_timings_onsets(2,i) + 4.5;            % row2=stimulus1, account for HRF
        stim2_onset = exp_timings_onsets(3,i) + 4.5;            % row3=stimulus2, account for HRF
    
        stim1_TR_index = floor(stim1_onset/1.5) + 1;            % compute TR index
        stim2_TR_index = floor(stim2_onset/1.5) + 1;
    
        TR_indices((i*2)-1,:) = stim1_TR_index:1:stim1_TR_index+2;    % add TR indices 1-3
        TR_indices((i*2),:) = stim2_TR_index:1:stim2_TR_index+2;
    end
end


end