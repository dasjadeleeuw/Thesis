function gm_mask = grey_matter_mask(pp_nr, path, fn)
    % Returns a grey matter mask for one participant


    path_mask = 'O:\Research\FSW\Research_data\PF\Leerstoel Stigchel\Surya Gayet\Student projects\Dasja de Leeuw\'; 
    filename_mask = [path_mask, 'data_pp', int2str(pp_nr) '\masks\', fn, '_pp', int2str(pp_nr), '.nii'];

    % Make the mask if it doesn't exist yet
    if exist(filename_mask, 'file') ~= 2
        
        anatomy_files = ["t1_classCNN041.nii", "t1_classFS_43.nii", "T1_1mm_class2.nii"];

        % Get anatomy file to make mask
        anatomy_file = anatomy_files(pp_nr);
        anatomy_file_nii = load_nii(char(fullfile(path, anatomy_file)));
        anatomy_values = anatomy_file_nii.img;
        
        % For pp1 and pp3: grey matter = 5, 6; for pp2: grey matter = 0
        if (pp_nr == 1)||(pp_nr == 3)
            mask = ismember(anatomy_values, [5, 6]);
        elseif (pp_nr == 2)
            mask = ismember(anatomy_values, [0]);
        end
        
        % Save mask
        anatomy_file_nii.img = mask;
        save_nii(anatomy_file_nii, filename_mask);
        
    end

    gm_mask = char(filename_mask);

end
