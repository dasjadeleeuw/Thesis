%% Z-scoring
% Also includes code for slicing and saving delay- and stimulus-related
% fMRI data, after z-scoring. 


%% Define globals
path = 'O:\Research\FSW\Research_data\PF\Leerstoel Stigchel\Surya Gayet\Student projects\Femke Ruijs\Dasja de Leeuw\'; 
pp_nr = 3;
delay = 2;

% Add helper_functions path
addpath("helper_functions");

disp(datetime)


%% Session-run remappings
if pp_nr == 1
    session_to_TR = [1,732; 733,3172; 3173,5368; 5369,5612; 5613,6588];
    run_to_session = [1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 5, 5, 5, 5];
elseif pp_nr == 2
    session_to_TR = [1,244; 245,2440; 2441,5124; 5125,6588];
    run_to_session = [1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4];
elseif pp_nr == 3
    session_to_TR = [1,1952; 1953,4636; 4636,6588];
    run_to_session = [1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3];
end


%% Load raw fMRI data
[fmri_path, fmri_files] = get_fmri_files(pp_nr);
mask = [path, 'data_pp', int2str(pp_nr), '\masks\grey_matter_mask_whole_pp', int2str(pp_nr), '.nii'];

for f = (1:27)
        
    % Load data for this run
    run_file = char(fullfile(fmri_path, fmri_files(f)));
    run_data = cosmo_fmri_dataset(run_file, 'mask', mask); 
        
    % Append run_data to entire dataset fmri_data
    if f == 1
        fmri_data = run_data;
    elseif f > 1
        fmri_data = cosmo_stack({fmri_data, run_data});
    end
        
end

disp('Data is loaded')
disp(datetime)


%% Remove extra TRs for pp2
if pp_nr == 2
    fmri_data.samples(245:253, :) = [];
end


%% For each voxel, perform z-scoring
z_scored_data = zeros(size(fmri_data.samples));

for i_voxel = 1:size(fmri_data.samples, 2)
    voxel_over_time = zeros(1, length(fmri_data.samples(:,1)));

    % Compute mean activity for each run
    mean_activity = zeros(27,1);
    for i = 1:27
        mean_activity(i) = mean(fmri_data.samples(((i-1)*244)+1:i*244, i_voxel)); % activity for 244 TRs per run
    end
    
    % Compute stdev of selected voxel for each session
    std_per_session = zeros(5,1);
    for i = 1:length(session_to_TR)
        session_start = session_to_TR(i,1);
        session_end = session_to_TR(i,2);
        std_per_session(i) = std(fmri_data.samples(session_start:session_end, i_voxel));
    end
    
    % Z-score each voxel
    for i = (1:length(voxel_over_time))
        i_run = floor((i-1)/244)+1;
        av = mean_activity(i_run);
        stdev = std_per_session(run_to_session(i_run));
        voxel_over_time(i) = (fmri_data.samples(i, i_voxel) - av) / stdev; % subtract the mean activation, divide by the stdev
    end

    % Store voxel over time in new table
    z_scored_data(:,i_voxel) = voxel_over_time;
end

disp('Z-scoring is complete')
disp(datetime)


%% Store z-scored data

% Replace .samples with z-scores
z_scored_fmri_data = fmri_data;
z_scored_fmri_data.samples = z_scored_data;

% Clear fmri_data and z_scored_data for memory purposes
clear fmri_data;
clear z_scored_data; 

% Data contains some NaN values after z-scoring, so remove these
% NaN can occur due to division by zero
z_scored_fmri_data = cosmo_remove_useless_data(z_scored_fmri_data);


%% Save z-scored data for whole dataset - TAKES LIKE 14 HOURS
% % Slice in two (otherwise too big to convert)
% fmri_data_1 = cosmo_slice(z_scored_fmri_data, 1:3294);
% fmri_data_2 = cosmo_slice(z_scored_fmri_data, 3295:6588);
% 
% % Filenames
% fn_z_scores_1 = [path, 'data_pp', int2str(pp_nr), '\z_scores_whole_exp_1_pp', int2str(pp_nr), '.nii'];
% fn_z_scores_2 = [path, 'data_pp', int2str(pp_nr), '\z_scores_whole_exp_2_pp', int2str(pp_nr), '.nii'];
% 
% % Convert to nifti and save
% data_as_nifti_1 = cosmo_map2fmri(fmri_data_1, fn_z_scores_1);
% save_nii(data_as_nifti_1, fn_z_scores_1);
% 
% data_as_nifti_2 = cosmo_map2fmri(fmri_data_2, fn_z_scores_2);
% save_nii(data_as_nifti_2, fn_z_scores_2);


%% Slice and save delay TRs as *separate* TRs

% % Get delay TR indices
% delay_TRs = get_delay_TRs(pp_nr, 5);
% 
% % Alter TR indices to fit with whole dataset
% delay_TRs = alter_TR_indices(delay_TRs, 27, 244, 12);
% 
% % Slice delay intervals separately (1-5)
% for i = 1:5
%     TR_i = delay_TRs(:, i);
% 
%     % Slice the fMRI data with the TR mask
%     delay_TR_mask = false(size(z_scored_fmri_data.samples, 1), 1);
%     delay_TR_mask(TR_i) = true;
%     
%     fmri_data_delay = cosmo_slice(z_scored_fmri_data, delay_TR_mask);
% 
%     % Save
%     fn_delay = [path, 'data_pp', int2str(pp_nr), '\z_scores\z_scores_delay_', int2str(i), '_pp', int2str(pp_nr), '.nii'];
%     data_as_nifti = cosmo_map2fmri(fmri_data_delay, fn_delay);
%     save_nii(data_as_nifti, fn_delay);
% 
% end


%% Slice and save delay TRs as *averaged* TRs (two parts)

% % Get 6 delay TR indices
% delay_TRs = get_delay_TRs(pp_nr, 6);
% 
% % Alter TR indices to fit with whole dataset
% delay_TRs = alter_TR_indices(delay_TRs, 27, 244, 12);
% 
% % Slice delay intervals into 2 parts (each of 3 TRs)
% columns = [1,2,3;4,5,6];
% 
% for part = 1:size(columns,1)
%     TR_i = delay_TRs(:, columns(part,:));
% 
%     % Slice the fMRI data with the TR mask
%     delay_TR_mask = false(size(z_scored_fmri_data.samples, 1), 1);
%     delay_TR_mask(TR_i) = true;
%     fmri_data_delay = cosmo_slice(z_scored_fmri_data, delay_TR_mask);
% 
%     % Average every three TRs
%     fmri_data_delay.samples = average_TRs(fmri_data_delay.samples, 3);
% 
%     % Save
%     fn_delay = [path, 'data_pp', int2str(pp_nr), '\z_scores\z_scores_delay_part_', int2str(part), '.nii'];
%     data_as_nifti = cosmo_map2fmri(fmri_data_delay, fn_delay);
%     save_nii(data_as_nifti, fn_delay);
% 
% end
% 
% disp('Data is saved')
% disp(datetime)


%% Slice and save delay TRs as one *averaged* TR

% Get 6 delay TR indices
delay_TRs = get_delay_TRs(pp_nr, 6, delay);

% Alter TR indices to fit with whole dataset
delay_TRs = alter_TR_indices(delay_TRs, 27, 244, 12);

% Slice the fMRI data with the TR mask
delay_TR_mask = false(size(z_scored_fmri_data.samples, 1), 1);
delay_TR_mask(delay_TRs) = true;
fmri_data_delay = cosmo_slice(z_scored_fmri_data, delay_TR_mask);

% Average all 6 TRs
fmri_data_delay.samples = average_TRs(fmri_data_delay.samples, 6);

% fn_delay = [path, 'data_pp', int2str(pp_nr), '\z_scores\z_scores_delay_whole.nii'];
% data_as_nifti = cosmo_map2fmri(fmri_data_delay, fn_delay);
% save_nii(data_as_nifti, fn_delay);

% Save in two parts
sliced_results = cell(1, 2);
sliced_results{1} = cosmo_slice(fmri_data_delay, (1:162) , 1);
sliced_results{2} = cosmo_slice(fmri_data_delay, (163:324), 1);
clear fmri_data_delay;
for i = 1:2
    fn_results = [path, 'data_pp', int2str(pp_nr), '\z_scores\z_scores_delay_whole_delay', int2str(delay), '_pt', int2str(i), '.nii'];
    as_nifti = cosmo_map2fmri(sliced_results{i}, fn_results);
    save_nii(as_nifti, fn_results)
end

disp('Data is saved')
disp(datetime)


%% Slice and save delay TRs as *averaged* TRs (three parts: 1-2, 3-4, 5-6)

% % Get 6 delay TR indices
% delay_TRs = get_delay_TRs(pp_nr, 6);
% 
% % Alter TR indices to fit with whole dataset
% delay_TRs = alter_TR_indices(delay_TRs, 27, 244, 12);
% 
% % Slice delay intervals into 3 parts (each of 2 TRs)
% columns = [1,2;3,4;5,6];
% 
% for part = 1:size(columns,1)
%     TR_i = delay_TRs(:, columns(part,:));
% 
%     % Slice the fMRI data with the TR mask
%     delay_TR_mask = false(size(z_scored_fmri_data.samples, 1), 1);
%     delay_TR_mask(TR_i) = true;
%     fmri_data_delay = cosmo_slice(z_scored_fmri_data, delay_TR_mask);
% 
%     % Average every two TRs
%     fmri_data_delay.samples = average_TRs(fmri_data_delay.samples, 2);
% 
% %     % Save
% %     fn_delay = [path, 'data_pp', int2str(pp_nr), '\z_scores\z_scores_delay_part_', int2str(part), '.nii'];
% %     data_as_nifti = cosmo_map2fmri(fmri_data_delay, fn_delay);
% %     save_nii(data_as_nifti, fn_delay);
% 
%     % Save in two parts
%     sliced_results = cell(1, 2);
%     sliced_results{1} = cosmo_slice(fmri_data_delay, (1:162) , 1);
%     sliced_results{2} = cosmo_slice(fmri_data_delay, (163:324), 1);
%     clear fmri_data_delay;
%     for i = 1:2
%         fn_results = [path, 'data_pp', int2str(pp_nr), '\z_scores\z_scores_delay_part_', int2str(part), '_pt', int2str(i), '.nii'];
%         as_nifti = cosmo_map2fmri(sliced_results{i}, fn_results);
%         save_nii(as_nifti, fn_results)
%     end
% 
% end
% 
% disp('Data is saved')
% disp(datetime)


%% Slice and save stimulus TRs - one TR to represent two stimuli

% % Get stimulus TRs
% stimulus_TRs = get_stimulus_TRs(pp_nr, 1); % condition=1
% 
% % Alter TR indices to fit with whole dataset
% stimulus_TRs = alter_TR_indices(stimulus_TRs, 27, 244, 12);
% 
% % Slice the fMRI data with the TR mask
% stim_TR_mask = false(size(z_scored_fmri_data.samples, 1), 1);
% stim_TR_mask(stimulus_TRs) = true;
% fmri_data_stim = cosmo_slice(z_scored_fmri_data, stim_TR_mask);
% 
% % Average every three TRs
% fmri_data_stim.samples = average_TRs(fmri_data_stim.samples, 3);
% 
% % Save
% fn_stim = [path, 'data_pp', int2str(pp_nr), '\z_scores\z_scores_stim.nii'];
% data_as_nifti = cosmo_map2fmri(fmri_data_stim, fn_stim);
% save_nii(data_as_nifti, fn_stim);


%% Slice and save stimulus TRs - 2 stimuli separately
% 
% % Get stimulus TRs
% stimulus_TRs = get_stimulus_TRs(pp_nr);
% 
% % Alter TR indices to fit with whole dataset
% stimulus_TRs = alter_TR_indices(stimulus_TRs, 27, 244, 24);
% 
% % Average each 3 TRs
% fmri_data_stim_av = z_scored_fmri_data;                                 % make a copy, so no overwrite
% [~, nr_columns] = size(z_scored_fmri_data.samples);                     % get nr of columns, i.e. voxels
% average_TRs = zeros(648, nr_columns);                                   % make variable for average TRs (648 = 2*324 trials)
% 
% for i = 1:length(stimulus_TRs)
%     start_TR = stimulus_TRs(i,1);
%     end_TR = stimulus_TRs(i,3);
% 
%     select_3_TRs = z_scored_fmri_data.samples(start_TR:end_TR, :);
%     average_TRs(i, :) = mean(select_3_TRs, 1);                 % take average along dimension 1 (row)
% 
% end
% 
% fmri_data_stim_av.samples = average_TRs;
% 
% % Save as nifti
% fn_stimulus = [path, 'data_pp', int2str(pp_nr), '\z_scores\z_scores_stimuli_pp', int2str(pp_nr), '.nii'];
% data_as_nifti = cosmo_map2fmri(fmri_data_stim_av, fn_stimulus);
% save_nii(data_as_nifti, fn_stimulus);
% 


%% Function to average every x TRs

function [averaged_mtx] = average_TRs(mtx, nr_TRs)
    % Reshape to 3D, where 1st dimension has groups of x (nr_TRs) rows
    [rows, cols] = size(mtx);
    reshape_mtx = reshape(mtx, [nr_TRs, rows/nr_TRs, cols]);

    % Compute mean along 1st dim
    averaged_mtx = mean(reshape_mtx,1);

    % Reshape back to 2D
    averaged_mtx = squeeze(averaged_mtx);
end

