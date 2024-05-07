%% Perform tfce on searchlight output map


% Define globals
pp_nr = 1;
conditions = ["cross_decoding_2_1", "cross_decoding_1_2"];  
nr_perms = 1000;
sign_flip_save = 1; % 1 for saving sign-flipped data
mask = ['grey_matter_mask_whole_pp', int2str(pp_nr)]; 
% !If condition mask is used, be sure to change output file name!
op = 1; % if op=1 test the opposite orientation
% !If op=1, be sure to change the output file name!
path = 'O:\Research\FSW\Research_data\PF\Leerstoel Stigchel\Surya Gayet\Student projects\Dasja de Leeuw\'; 


% Run tfce for specified conditions
for cond = conditions
    condition = convertStringsToChars(cond);

    % Loading data
    [obs_map, perm_maps] = load_results(path, pp_nr, mask, condition, nr_perms, op);
    
    % TFCE setup
    opt                 =   struct();
    opt.feature_stat    =   'none';
    opt.null            =   perm_maps;
    opt.cluster_stat    =   'tfce';
    opt.dh              =   0.01;
    opt.h0_mean         =   0;
    %opt.nproc           =   12;
    
    nbrhood = cosmo_cluster_neighborhood(obs_map);
    
    % Monte carlo clustering with tfce
    [tfce_results] = cosmo_montecarlo_cluster_stat(obs_map, nbrhood, opt); 
    
    % Saving results
    filename = [path, 'data_pp', int2str(pp_nr), '\', condition, '_op_tfce.nii'];
    as_nifti = cosmo_map2fmri(tfce_results, filename);
    save_nii(as_nifti, filename);
    
    % Saving sign-flipped results
    if sign_flip_save == 1
        filename = [path, 'data_pp', int2str(pp_nr), '\', condition, '_op_tfce_neg.nii'];
        tfce_results.samples = -1*(tfce_results.samples);
        as_nifti = cosmo_map2fmri(tfce_results, filename);
        save_nii(as_nifti, filename);
    end
end


%% -----------------------------------------------------FUNCTIONS------------------------------------------------------------- %%

function [obs_map, perm_maps] = load_results(path, pp_nr, mask_name, condition, nr_perms, op)
    for pt = 1:2
        fn = [path, 'data_pp', int2str(pp_nr), '\', condition, '_pt', int2str(pt), '.nii'];
        disp(fn)
        mask = [path, 'data_pp', int2str(pp_nr), '\masks\', mask_name, '.nii'];
        data = cosmo_fmri_dataset(fn, 'mask', mask);
        if pt == 1
            result_maps = data;
        elseif pt == 2
            result_maps = cosmo_stack({result_maps, data});
        end
    end 

    % Adding targets and chunks to help out cosmo
    length_ds = size(result_maps.samples,1);
    result_maps.sa.targets((1:length_ds), 1) = 1;
    result_maps.sa.chunks((1:length_ds), 1) = 1;

    % Taking the first map as the observed map (with actual IEM results)
    obs_map = cosmo_slice(result_maps, 1);

    % If opposite, overwrite obs_map to be the last map, i.e. opposite
    % orientation results
    if op == 1
        obs_map = cosmo_slice(result_maps, nr_perms+3);
    end

    % Make a (1 x nr_perms) cell to store permuted maps as separate structs
    perm_maps = cell(1, nr_perms);
    for i = 1:nr_perms
        perm_maps{i} = cosmo_slice(result_maps, i+2); % indices perm_maps start at 3
    end
    
end

