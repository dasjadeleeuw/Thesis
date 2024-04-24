function [path, exp_results, exp_conditions] = get_exp_files(pp_nr)
% Returns paths to relevant experimental data

    if pp_nr == 1
        path = "...\fMRI data participant 01\S01WMWM\";
        exp_results = ["...\Experiment data\01\01-results.mat",
            "...\Experiment data\01\01-TimeCorrections_Run_1_2_3.mat"
            ];
        exp_conditions = "...\Experiment data\01\01-testconditions.mat";
    
    elseif pp_nr == 2
        path = "...\fMRI data participant 02\S02\";
        exp_results = "...\Experiment data\02\02-results.mat";
        exp_conditions = "...\Experiment data\02\02-testconditions.mat";
    
    elseif pp_nr == 3
        path = "...\fMRI data participant 03\";
        exp_results = "...\Experiment data\03\03-results.mat";
        exp_conditions = "...\Experiment data\03\03-testconditions.mat";
    end

end
