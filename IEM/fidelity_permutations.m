function [fidelity] = fidelity_permutations(chan_resp, real_labels, all_perm_labels, pp_nr, nr_perms)
% Perform permutations on the fidelity of the channel responses 


%% Add relevant paths
addpath('helper_functions', 'IEM')


%% Shift observed- and permuted channel responses
% Shift observed channel responses
chan_resp_shift = zeros(size(chan_resp));
nt = size(chan_resp, 1);
for trial = 1:nt % for every test trial
    chan_resp_shift(trial,:) =  wshift('1D', chan_resp(trial,:), real_labels(trial,:)-90);
end
mean_chan_resp = mean(chan_resp_shift, 1);

% Permutation: randomly align channel responses
perm_chan_resp = zeros(nr_perms, 180);
for j = 1:nr_perms
    perm = zeros(nt, 180);
    % Pick jth volumn vector of shuffeled labels
    perm_labels = all_perm_labels(:,j);
    for trial = 1:nt % for every test trial
        perm(trial, :) = wshift('1D', chan_resp(trial,:), perm_labels(trial,:)-90);
    end
    perm_chan_resp(j, :) = mean(perm);
end


%% Compute fidelity
fid_function = cosd(abs((1:180)*2-180));                    % fidelity function (1x180)
fid_perm = mean(perm_chan_resp.*fid_function, 2);           % permutation fidelity
fid_o = mean(mean_chan_resp.*fid_function);                 % observed fidelity


%% Compute p-value
prop_lower = 0;
for j = 1:nr_perms
    fid_p = fid_perm(j, :);
    if fid_o > fid_p
        prop_lower = prop_lower + 1;
    end
end
p = prop_lower / nr_perms;


%% Store results
fidelity = [fid_o; p; fid_perm];


end
