function kept_trials = keep_trials(pp_nr, exp_results_files, delay)
% Removes outlier trials based on 3 times the standard deviation. 


% Lose the correct timings file for pp1
if pp_nr == 1
    exp_results_files = exp_results_files(1);
end

if delay == 1
    errors = load(exp_results_files).error(3,:); % 3rd row: absolute error first delay
elseif delay == 2
    errors = load(exp_results_files).error(4,:); % 4th row: absolute error second delay
end

kept_trials = [];

for i = (1:length(errors))
    error = errors(i);
    if error < mean(errors) + (3*std(errors))
        kept_trials = [kept_trials, i];  %#ok<*AGROW> 
    end
end


end