function TR_indices_whole_ds = alter_TR_indices(original_TRs, nr_runs, nr_TRs, nr_selected_TRs)
% Alters TR indices by adding a specified value; goal is to fit with the
% whole fMRI dataset instead of with separate runs. 
% nr_TRs refers to the total number of TRs per run, which is always 244. 
% nr_selected_TRs refers to the number of TRs selected per run. 

TR_indices_whole_ds = zeros(size(original_TRs));

for i = 1:nr_runs
    start_idx = (i-1)*nr_selected_TRs + 1;
    end_idx = i*nr_selected_TRs;
    TR_indices_whole_ds(start_idx:end_idx, :) = original_TRs(start_idx:end_idx, :) + i*nr_TRs - nr_TRs;
end

end