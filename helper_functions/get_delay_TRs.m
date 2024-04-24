function TR_indices = get_delay_TRs(pp_nr, nr_TRs, delay)
% Returns the TRs corresponding to the first or second delay
% The number of TRs can be specified as a parameter (usually 5 or 6)


% Get correct file paths for this pp
[~, exp_results_files, exp_conditions_files] = get_exp_files(pp_nr);

% Load experimental data
[exp_timings_onsets, ~, total_nr_trials] = load_exp_data(pp_nr, exp_results_files, exp_conditions_files);

% List the relevant TR indices
TR_indices = zeros(total_nr_trials, nr_TRs);
        
for i = (1:total_nr_trials)
    if delay == 1
        delay_onset = exp_timings_onsets(5,i);                  % row5=delay1
    elseif delay == 2
        delay_onset = exp_timings_onsets(8,i);                  % row8=delay2
    end
    delay_onset = delay_onset + 4.5;                            % account for HRF
    TR_index = floor(delay_onset/1.5) + 1;                      % compute TR index 1
    TR_indices(i,:) = TR_index:1:TR_index+(nr_TRs-1);           % add TR indices 1:nr_TRs
end

end