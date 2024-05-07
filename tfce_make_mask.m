%% Script to load tfce results and make a mask of the results


% Define globals
pp_nr = 3;
condition = 'cross_temp_dist0';
tailed = 1;
path = 'O:\Research\FSW\Research_data\PF\Leerstoel Stigchel\Surya Gayet\Student projects\Dasja de Leeuw\'; 


% Load the tfce results
fn = [path, 'data_pp', int2str(pp_nr), '\', condition, '_tfce.nii'];
mask = [path, 'data_pp', int2str(pp_nr), '\masks\grey_matter_mask_whole_pp', int2str(pp_nr), '.nii'];
tfce_data = cosmo_fmri_dataset(fn, 'mask', mask);

% Make the mask
results_mask = tfce_data;
if tailed == 1
    results_mask.samples = tfce_data.samples > 1.64;
elseif tailed == 2
    results_mask.samples = (tfce_data.samples > 1.96) | (tfce_data.samples < -1.96);
elseif tailed == 0
    results_mask.samples = tfce_data.samples == 0;
end

% Save the mask
save_fn = [path, 'data_pp', int2str(pp_nr), '\masks\', condition, '_mask.nii'];
as_nifti = cosmo_map2fmri(results_mask, save_fn);
save_nii(as_nifti, save_fn);

