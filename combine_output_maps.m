%% Load output maps and combine their results, either by averaging or subtracting


for pt = 1:2 % output maps are saved in two parts

    % Globals 
    pp_nr = 3; 
    condition = ['cross_temp_diff', '_pt' int2str(pt)]; % for output filename
    condition_1 = ['cross_temp_dist0_pt', int2str(pt)]; 
    condition_2 = ['cross_temp_dist2_pt', int2str(pt)];  
    path = 'O:\Research\FSW\Research_data\PF\Leerstoel Stigchel\Surya Gayet\Student projects\Dasja de Leeuw\'; 

    % Load the maps
    result_maps_1 = load_result_maps(path, pp_nr, condition_1);
    result_maps_2 = load_result_maps(path, pp_nr, condition_2);

    
    %% Average maps together
    % result_samples = (result_maps_1.samples + result_maps_2.samples) / 2;
    
    
    %% Subtract map 1 from map 2
    result_samples = result_maps_1.samples - result_maps_2.samples;
    
    
    %% Save results
    filename = [path, 'data_pp', int2str(pp_nr), '\', condition, '.nii'];
    results = result_maps_1;
    results.samples = result_samples;
    as_nifti = cosmo_map2fmri(results, filename);
    save_nii(as_nifti, filename);
end


function [result_maps] = load_result_maps(path, pp_nr, condition)
    fn = [path, 'data_pp', int2str(pp_nr), '\', condition, '.nii'];
    mask = [path, 'data_pp', int2str(pp_nr), '\masks\grey_matter_mask_whole_pp', int2str(pp_nr), '.nii'];
    result_maps = cosmo_fmri_dataset(fn, 'mask', mask);
    % Adding targets and chunks to help out cosmo
    length_ds = size(result_maps.samples, 1);
    result_maps.sa.targets((1:length_ds), 1) = 1;
    result_maps.sa.chunks((1:length_ds), 1) = 1;
end

