%% Script to load tfce results and make a mask of the results


% Define globals
pp_nr = 3;
condition = 'cross_temp_dist0';
tailed = 1;
path = 'O:\Research\FSW\Research_data\PF\Leerstoel Stigchel\Surya Gayet\Student projects\Femke Ruijs\Dasja de Leeuw\'; 


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


%% Two conditions: AMI and UMI -> vwm_mask

% Define globals
pp_nr = 3;
path = 'O:\Research\FSW\Research_data\PF\Leerstoel Stigchel\Surya Gayet\Student projects\Femke Ruijs\Dasja de Leeuw\'; 
mask = [path, 'data_pp', int2str(pp_nr), '\masks\grey_matter_mask_whole_pp', int2str(pp_nr), '.nii'];

% Load the AMI tfce results
fn_ami = [path, 'data_pp', int2str(pp_nr), '\cross_decoding_1_1_tfce.nii'];
tfce_data_ami = cosmo_fmri_dataset(fn_ami, 'mask', mask);

% Load the UMI tfce results
fn_umi = [path, 'data_pp', int2str(pp_nr), '\cross_decoding_2_2_tfce.nii'];
tfce_data_umi = cosmo_fmri_dataset(fn_umi, 'mask', mask);

% Make the mask
results_mask = tfce_data_ami;
results_mask.samples = (tfce_data_ami.samples > 1.64) | (tfce_data_umi.samples > 1.64);

% Save the mask
save_fn = [path, 'data_pp', int2str(pp_nr), '\masks\vwm_mask.nii'];
as_nifti = cosmo_map2fmri(results_mask, save_fn);
save_nii(as_nifti, save_fn);

