%% Entire script to run a searchlight analysis with IEM as measure
% Cross-temporal decoding of the CMI


% Define globals
pp_nr = 3;                                  % pp 1-3
cmi_umi = 1;                                % cmi = 1; umi = 2
mask_name = 'grey_matter_mask_whole';       % grey_matter_mask_whole or test_mask
nr_perms = 1000;
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
kept_trials = keep_trials(pp_nr, exp_results_files);


%% Load the TWO datasets (delay parts 1 (early) and 3 (late))
% Get orientations - for cmi or umi
delay_oris = get_orientations(exp_conditions, cmi_umi, total_nr_trials);

% Chunks to indicate which data entry belongs to which run
runs = (1:27);
run_chunks = extend_array(runs, 12)'; % transpose

% Load data for both TWO delay parts into a cell
fmri_data = cell(1,2);
for delay_part = [1,3]

    % Data files in two parts
    for pt = 1:2
        fn = [path, 'data_pp', int2str(pp_nr), '\z_scores\z_scores_delay_part_', int2str(delay_part), '_pt', int2str(pt), '.nii'];
        data = cosmo_fmri_dataset(fn, 'mask', mask);
        if pt == 1
            fmri_data_delay = data;
        elseif pt == 2
            fmri_data_delay = cosmo_stack({fmri_data_delay, data});
        end
    end
    clear data;
    fmri_data_delay.sa.chunks = run_chunks;
    fmri_data_delay.sa.targets = delay_oris;
    fmri_data_delay = cosmo_slice(fmri_data_delay, kept_trials);

    % Add data for this delay part to the cell
    fmri_data{delay_part} = fmri_data_delay;
    clear fmri_data_delay;

end

disp('Data is loaded!')


%% Start the loop: try every combination of delay parts and run SL
for pt1 = [1,3]
    for pt2 = [1,3]

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

        % Searchlight settings
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
            fn_results = [path, 'data_pp', int2str(pp_nr), '\cross_temporal_' int2str(pt1), '_', int2str(pt2), '_pt', int2str(i), '.nii'];
            as_nifti = cosmo_map2fmri(sliced_results{i}, fn_results);
            save_nii(as_nifti, fn_results)
            clear as_nifti;
        end
        

        disp('Searchlight is done; results are saved!')

    end
end

disp('Cross-temporal decoding analyses complete!')

