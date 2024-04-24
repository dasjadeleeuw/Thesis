function stim_mask = make_stim_mask_IEM(orientations)
% Makes a stimulus mask for the given dataset to use for IEMs


stim_mask = zeros(size(orientations, 1),180);

for i = 1:size(orientations,1)
    stim_mask(i, orientations(i,1)+1) = 1; 
    stim_mask(i, orientations(i,2)+1) = 1; % Extra line for two stimuli (stim_tt)
end

end