%% Entire script to run a searchlight analysis with IEM as measure
% Cross-decoding based on condition: CMI or UMI


% Define globals
pp_nr = 1;
mask_name = 'test_mask';
nr_perms = 1000;
delay = 1;
path = 'O:\Research\FSW\Research_data\PF\Leerstoel Stigchel\Surya Gayet\Student projects\Dasja de Leeuw\'; 


% Access relevant folders
addpath('helper_functions', 'IEM');
% Get correct file paths for this pp
[mask_path, exp_results_files, exp_conditions_files] = get_exp_files(pp_nr);
% Get mask
mask = grey_matter_mask(pp_nr, mask_path, mask_name);

% Load experimental data
[exp_timings_onsets, exp_conditions, total_nr_trials] = load_exp_data(pp_nr, exp_results_files, exp_conditions_files);

% Define outliers; only keep trials without outliers
kept_trials = keep_trials(pp_nr, exp_results_files, delay);


%% Load dataset with delay-related data
% Get orientations - for cmi or umi
delay_oris_cmi = get_orientations(exp_conditions, 1, delay, total_nr_trials);
delay_oris_umi = get_orientations(exp_conditions, 2, delay, total_nr_trials);

% Chunks to indicate which data entry belongs to which run
runs = (1:27);
run_chunks = extend_array(runs, 12)'; % transpose

% Load data when it is in two parts
for pt = 1:2
    fn = [path, 'data_pp', int2str(pp_nr), '\z_scores\z_scores_delay_whole_pt', int2str(pt), '.nii'];
    data = cosmo_fmri_dataset(fn, 'mask', mask);
    if pt == 1
        fmri_data_delay = data;
    elseif pt == 2
        fmri_data_delay = cosmo_stack({fmri_data_delay, data});
    end
end 
clear data;
fmri_data_delay.sa.chunks = run_chunks;
fmri_data_delay = cosmo_slice(fmri_data_delay, kept_trials);

% Load data for both conditions into a cell
fmri_data = cell(1,2);
for cond = 1:2
    if cond == 1
        fmri_data_delay.sa.targets = delay_oris_cmi(kept_trials);
    elseif cond == 2
        fmri_data_delay.sa.targets = delay_oris_umi(kept_trials);
    end
    fmri_data{cond} = fmri_data_delay;
end
clear fmri_data_delay; 

disp('Data is loaded!')


%% Start the loop: try every combination of conditions (CMI, UMI) and run SL

for pt1 = 1:1
    for pt2 = 1:1
            % 1 -> 1: train and test on cmi
            % 1 -> 2: train on cmi, test on umi
            % 2 -> 1: train on umi, test on cmi
            % 2 -> 2: train and test on umi

            % Prepare dataset (train-test split)
            ds = cosmo_stack({fmri_data{pt1}, fmri_data{pt2}});
            test_labels = fmri_data{pt2}.sa.targets;
            ds_length = size(ds.samples,1); % add 27 to test set chunks (last half)
            ds.sa.chunks((ds_length/2)+1:ds_length, :) = ds.sa.chunks((ds_length/2)+1:ds_length, :) + 27;
    
            % Shuffle the test labels to use for permutations
            shuffled_labels = zeros(size(test_labels,1)*size(test_labels,2), nr_perms); % 
            for i = 1:nr_perms
                rand_indices = randperm(length(test_labels));
                shuff_labels = test_labels(rand_indices,:);
                shuffled_labels(:,i) = shuff_labels(:); % cast to column vector
            end
    
            %% Searchlight settings
            radius = 3;
            nbrhood = cosmo_spherical_neighborhood(ds,'radius',radius);
            measure = @cosmo_do_IEM;
            
            % Options
            opt                     =   struct();
            opt.nr_perms            =   nr_perms;
            opt.pp_nr               =   pp_nr;
            opt.real_labels         =   test_labels;
            opt.shuffled_labels     =   shuffled_labels;
            
            
            % Run SL ~this is where the magic happens~
            iem_results = cosmo_searchlight(ds, nbrhood, measure, opt, 'nproc', 12, 'progress', 1);


            %% Save results; in two separate files
            sliced_results = cell(1, 2);
            nr_samples = size(iem_results.samples, 1);
            sliced_results{1} = cosmo_slice(iem_results, (1:501) , 1);
            sliced_results{2} = cosmo_slice(iem_results, (502:nr_samples), 1);
            clear iem_results;
            for i = 1:2
                fn_results = [path, 'data_pp', int2str(pp_nr), '\cross_decoding_' int2str(pt1), '_', int2str(pt2), '_delay', int2str(delay), '_pt', int2str(i), '.nii'];
                as_nifti = cosmo_map2fmri(sliced_results{i}, fn_results);
                save_nii(as_nifti, fn_results)
                clear as_nifti;
            end
    
            disp('Searchlight is finished; results are saved!')

    end
end

disp('Cross-decoding analyses complete!')

