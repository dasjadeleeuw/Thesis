

pp_nr = 3;
nr_perms = 10000;
path = 'O:\Research\FSW\Research_data\PF\Leerstoel Stigchel\Surya Gayet\Student projects\Dasja de Leeuw\'; 

% Get expertimental results files
[mask_path, exp_results_files, exp_conditions_files] = get_exp_files(pp_nr);

% Lose the correct timings file for pp1
if pp_nr == 1
    exp_results_files = exp_results_files(1);
end

% Load the conditions data
conditions = load(exp_results_files).conditions;

% Identify the switch trials
switch_trial_indices = [];
for trial = 1:324
    if conditions(1, trial) ~= conditions(2, trial)
        switch_trial_indices(end+1,1) = trial;
    end
end


%% Observed data
% Load the absolute errors
errors = load(exp_results_files).error(4,:); % 3rd row: absolute error second delay
% boxplot(errors)

% Make a list of mae's from second delay for switch trials
errors_in_switch_trials = zeros(324,1);
for trial = 1:324
    errors_in_switch_trials(trial) = errors(trial);
end
errors_in_switch_trials = errors_in_switch_trials(switch_trial_indices);

% Compute the observed mae
obs_mae = mean(errors_in_switch_trials);


%% Permutations
% Get raw behavioral responses
raw_data = load(exp_results_files).raw_data;
raw_responses = raw_data(4,:);
raw_responses = raw_responses(switch_trial_indices);

% Get target orientations
targets = zeros(324,1);
for trial = 1:324
    cue = conditions(2,trial);
    targets(trial,:) = raw_data(cue,trial);
end
targets = targets(switch_trial_indices);

% Run the permutations to establish a null distribution
perms_mae = zeros(nr_perms,1);
for i = 1:nr_perms

    % Shuffle the targets
    rand_indices = randperm(324/2);
    shuff_targets = targets(rand_indices,:);

    % Compute absolute error for each trial
    abs_errors = zeros(162,1);
    for trial = 1:162
        abs_errors(trial) = compute_error(raw_responses(trial), shuff_targets(trial));
    end

    % Append mae to array
    perms_mae(i) = mean(abs_errors);
end

%% Compute p 
% boxplot(perms_mae)
prop_lower = 0;
for i = 1:nr_perms
    if obs_mae > perms_mae(i)
        prop_lower = prop_lower + 1;
    end
end
p = prop_lower / nr_perms;
disp(p)



function error_deg = compute_error(orientation1, orientation2)
    
    % Ensure that both orientations are under 180
    if orientation1 > 179
        orientation1 = orientation1 - 179;
    end
    if orientation1 > 179
        orientation1 = orientation1 - 179;
    end

    % Ensure orientations are between 1 and 180
    orientation1 = mod(orientation1, 180);
    orientation2 = mod(orientation2, 180);

    % Compute absolute error
    error_deg = min(abs(orientation1 - orientation2), 180 - abs(orientation1 - orientation2));
end


