%% Z-scoring
% Code to z-score fMRI data to prepare for further analysis (searchlight IEM, etc.). 
% Also includes code for slicing and saving delay- and stimulus-related fMRI data, after z-scoring. 


%% Define globals
path = 'O:\Research\FSW\Research_data\PF\Leerstoel Stigchel\Surya Gayet\Student projects\Dasja de Leeuw\'; 
pp_nr = 3;
delay = 2;

% Add helper_functions path
addpath("helper_functions");


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


%% Store z-scored data

% Replace .samples with z-scores
z_scored_fmri_data = fmri_data;
z_scored_fmri_data.samples = z_scored_data;

% Clear fmri_data and z_scored_data for memory purposes
clear fmri_data;
clear z_scored_data; 

% Data contains some NaN values after z-scoring, so remove these. 
% NaN can occur due to division by zero, 
z_scored_fmri_data = cosmo_remove_useless_data(z_scored_fmri_data);


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


%% Slice and save delay TRs as *averaged* TRs (three parts: 1-2, 3-4, 5-6)

% Get 6 delay TR indices
delay_TRs = get_delay_TRs(pp_nr, 6);

% Alter TR indices to fit with whole dataset
delay_TRs = alter_TR_indices(delay_TRs, 27, 244, 12);

% Slice delay intervals into 3 parts (each of 2 TRs)
columns = [1,2;3,4;5,6];

for part = 1:size(columns,1)
    TR_i = delay_TRs(:, columns(part,:));

    % Slice the fMRI data with the TR mask
    delay_TR_mask = false(size(z_scored_fmri_data.samples, 1), 1);
    delay_TR_mask(TR_i) = true;
    fmri_data_delay = cosmo_slice(z_scored_fmri_data, delay_TR_mask);

    % Average every two TRs
    fmri_data_delay.samples = average_TRs(fmri_data_delay.samples, 2);
    
    % Save in two parts (overwise memory overflows :')
    sliced_results = cell(1, 2);
    sliced_results{1} = cosmo_slice(fmri_data_delay, (1:162) , 1);
    sliced_results{2} = cosmo_slice(fmri_data_delay, (163:324), 1);
    clear fmri_data_delay;
    for i = 1:2
        fn_results = [path, 'data_pp', int2str(pp_nr), '\z_scores\z_scores_delay_part_', int2str(part), '_pt', int2str(i), '.nii'];
        as_nifti = cosmo_map2fmri(sliced_results{i}, fn_results);
        save_nii(as_nifti, fn_results)
    end

end

disp('Data is saved')



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

