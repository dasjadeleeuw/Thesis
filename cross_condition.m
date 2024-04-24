%% Entire script to run a searchlight analysis with IEM as measure
% Cross-decoding based on condition: AMI or UMI
% Check the globals, the data to load, train-test set and filenames for
% output data


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
% Get orientations - for ami or umi
delay_oris_ami = get_orientations(exp_conditions, 1, delay, total_nr_trials);
delay_oris_umi = get_orientations(exp_conditions, 2, delay, total_nr_trials);

% Chunks to indicate which data entry belongs to which run
runs = (1:27);
run_chunks = extend_array(runs, 12)'; % transpose

% Load the data for whole delay; add targets later
fmri_data_delay_file = [path, 'data_pp', int2str(pp_nr), '\z_scores\z_scores_delay_whole.nii'];
fmri_data_delay = cosmo_fmri_dataset(fmri_data_delay_file, 'mask', mask, 'chunks', run_chunks);
fmri_data_delay = cosmo_slice(fmri_data_delay, kept_trials);

% % Load data when it is in two parts
% for pt = 1:2
%     fn = [path, 'data_pp', int2str(pp_nr), '\z_scores\z_scores_delay_whole_pt', int2str(pt), '.nii'];
%     data = cosmo_fmri_dataset(fn, 'mask', mask);
%     if pt == 1
%         fmri_data_delay = data;
%     elseif pt == 2
%         fmri_data_delay = cosmo_stack({fmri_data_delay, data});
%     end
% end 
% clear data;
% fmri_data_delay.sa.chunks = run_chunks;
% fmri_data_delay = cosmo_slice(fmri_data_delay, kept_trials);

% Load data for both conditions into a cell
fmri_data = cell(1,2);
for cond = 1:2
    if cond == 1
        fmri_data_delay.sa.targets = delay_oris_ami(kept_trials);
    elseif cond == 2
        fmri_data_delay.sa.targets = delay_oris_umi(kept_trials);
    end
    fmri_data{cond} = fmri_data_delay;
end
clear fmri_data_delay; 

disp('Data is loaded!')


%% Start the loop: try every combination of conditions and run SL
for pt1 = 1:1
    for pt2 = 1:1

        if ((pt1 + pt2) > 0) % just run everything :)

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
            opt.test_condition      =   'delay';
            opt.train_condition     =   'delay';
            
            
%             % Run SL ~this is where the magic happens~
%             iem_results = cosmo_searchlight(ds, nbrhood, measure, opt, 'nproc', 12, 'progress', 1);


            %% IEM separately
            [trnX] = cosmo_do_IEM(ds, opt);

%             %% Plotting
% 
%             trial = 1;
%             ori = 120; %delay_oris_ami(trial);
%             best_fit = 1; %30;
%             
%             figure
%             hold on
% 
% %             plot((chan_resp(trial,:)/3)+0.2, 'Linewidth', 3.0, 'Color', "#EDB120")
%             
% %            plot((coefficients(:,1)/3)+0.2, 'Linewidth', 3.0, 'Color', "#0072BD")
%             plot((coefficients(:,12)/1.5)+0.2, 'Linewidth', 3.0, 'Color', "#0072BD")
% 
% %             plot(b_funcs(ori,:), '--', 'Linewidth', 3.0, 'Color', "#D95319")
% %             xline(ori, 'Linewidth', 3.0, 'Color', "#D95319")
% 
% %             plot(b_funcs(best_fit,:), '--', 'Linewidth', 3.0, 'Color', "#77AC30")
% %             xline(best_fit, 'Linewidth', 3.0, 'Color', "#77AC30")
% 
% %             empty_line = zeros(180,1);
% % 
% %             plot(empty_line+0.5, 'Linewidth', 2.0, 'Color', "#EDB120")
% %             plot(empty_line+0.3, 'Linewidth', 2.0, 'Color', "#0072BD")
% %             plot(empty_line+0.1, '--', 'Linewidth', 2.0, 'Color', "#D95319")
% %             plot(empty_line-0.1, '--', 'Linewidth', 2.0, 'Color', "#77AC30")
% 
%             ylim([-0.5, 1.2])
% 
%             set(gca,'XTick',[], 'YTick', [])
% 
%             hold off


            %% Save results as one
%             fn_results = [path, 'data_pp', int2str(pp_nr), '\cross_decoding_' int2str(pt1), '_', int2str(pt2), '.nii'];
%             as_nifti = cosmo_map2fmri(iem_results, fn_results);
%             save_nii(as_nifti, fn_results)
%             clear as_nifti;
            
%             %% Save results; in two separate files
%             sliced_results = cell(1, 2);
%             nr_samples = size(iem_results.samples, 1);
%             sliced_results{1} = cosmo_slice(iem_results, (1:501) , 1);
%             sliced_results{2} = cosmo_slice(iem_results, (502:nr_samples), 1);
%             clear iem_results;
%             for i = 1:2
%                 fn_results = [path, 'data_pp', int2str(pp_nr), '\cross_decoding_' int2str(pt1), '_', int2str(pt2), '_delay', int2str(delay), '_pt', int2str(i), '.nii'];
%                 as_nifti = cosmo_map2fmri(sliced_results{i}, fn_results);
%                 save_nii(as_nifti, fn_results)
%                 clear as_nifti;
%             end
%     
%             disp('Searchlight is done; results are saved!')

        end
    end
end

disp('Cross-decoding analyses complete!')
disp(datetime)


%% Average size neighborhood

nh_size = 0;

for i = 1:length(nbrhood.neighbors)
    nh_size = nh_size + length(nbrhood.neighbors{i,1});
end

av_size = nh_size / length(nbrhood.neighbors);


%% -----------------------------------------------------TFCE FUNCTIONS------------------------------------------------------- %%
function [obs_map, perm_maps] = get_result_maps(result_maps, nr_perms)
    % Adding targets and chunks to help out cosmo
    length_ds = size(result_maps.samples,1);
    result_maps.sa.targets((1:length_ds), 1) = 1;
    result_maps.sa.chunks((1:length_ds), 1) = 1;

    % Taking the first map as the observed map (with actual IEM results)
    obs_map = cosmo_slice(result_maps, 1);
    % Make a (1 x nr_perms) cell to store permuted maps as separate structs
    perm_maps = cell(1, nr_perms);
    for i = 1:nr_perms
        perm_maps{i} = cosmo_slice(result_maps, i+2); % indices perm_maps start at 3
    end
end

function [tfce_results] = do_tfce(obs_map, perm_maps)
    opt                 =   struct();
    opt.feature_stat    =   'none';
    opt.null            =   perm_maps;
    opt.cluster_stat    =   'tfce';
    opt.dh              =   0.01;
    opt.h0_mean         =   0;
    opt.nproc           =   1;

    nbrhood = cosmo_cluster_neighborhood(obs_map);

    [tfce_results] = cosmo_montecarlo_cluster_stat(obs_map, nbrhood, opt); 
end

