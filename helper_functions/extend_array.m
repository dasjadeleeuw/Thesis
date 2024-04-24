function ext_values = extend_array(arr, nr_reps)
% Extends a given array (by repetition)


ext_values = [];

for i = 1:length(arr)
    repeat_val = repmat(arr(i), 1, nr_reps);
    ext_values = [ext_values, repeat_val]; %#ok<AGROW> 
end


end