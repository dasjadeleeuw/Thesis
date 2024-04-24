function [coefficients] = ranking_perms(chan_resp, b_functions, real_labels, all_perm_labels, nr_perms, condition)
% Perform permutations on the channel responses; outcome measure is the
% rank of the acutal orientation when sorting correlation coefficients with
% the channel responses, for every orientation. 


nt = length(real_labels);

% Compute correlations between all columns in basis_functions and all columns in channel responses
[coefficients, ~] = corr(b_functions, chan_resp.'); % transpose for column-wise correlations

% Rank the correlation coefficients
[~, corr_ranked] = sort(coefficients, 1); % second output variable are the indices, i.e. the orientations
corr_ranked = corr_ranked - 1; % convert from 1-180 to 0-179

% See on which rank the actual orientation lies
actual_ranks = zeros(1,nt);
opposite_ranks = zeros(1,nt); % +- 90 degrees
for trial = 1:nt
    % If we're testing on the stimulus response data, we have two targets,
    % so test them both and average the result
    if strcmp(condition, 'stim')
         rank1 = find(corr_ranked(:,trial) == real_labels(trial,1));
         rank2 = find(corr_ranked(:,trial) == real_labels(trial,2));
         actual_ranks(1,trial) = mean([rank1, rank2]);
    else
        % Actual rank
        ac_rank = real_labels(trial,1);
        actual_ranks(1,trial) = find(corr_ranked(:,trial) == ac_rank);
        
        % Opposite of actual rank
        if ac_rank > 90
            op_rank = ac_rank - 90;
        else
            op_rank = ac_rank + 90;
        end
        opposite_ranks(1,trial) = find(corr_ranked(:,trial) == op_rank);
    end
end

% Average the actual rank
av_observed_rank = mean(actual_ranks);
% Average opposite ranks
av_opposite_rank = mean(opposite_ranks);

% Compute the ranking for the shuffled labels, i.e. perm_labels
perm_ranks = zeros(nr_perms,1);
for i = 1:nr_perms
    p_ranks = zeros(1,nt);
    if strcmp(condition, 'stim')
        perm_labels = reshape(all_perm_labels(:,i), [size(all_perm_labels, 1)/2, 2]); % reshape from column vector to 2D matrix
        for trial = 1:nt
            rank1 = find(corr_ranked(:,trial) == perm_labels(trial,1)); 
            rank2 = find(corr_ranked(:,trial) == perm_labels(trial,2)); 
            p_ranks(1,trial) = mean([rank1, rank2]);
        end
    else
        perm_labels = all_perm_labels(:,i);
        for trial = 1:nt
            p_ranks(1,trial) = find(corr_ranked(:,trial) == perm_labels(trial,1));
        end
    end
    perm_ranks(i,:) = mean(p_ranks);
end

% Compute p-value
prop_lower = 0;
for j = 1:nr_perms
    rank_p = perm_ranks(j, :);
    if av_observed_rank > rank_p
        prop_lower = prop_lower + 1;
    end
end
p = prop_lower / nr_perms;

% Convert the ranks from 1-180 to (-1)-1
av_observed_rank = (av_observed_rank-90)/90;
perm_ranks = (perm_ranks-90)/90;
%actual_ranks = (actual_ranks-90)/90;
av_opposite_rank = (av_opposite_rank-90)/90;

% Store (1) mean actual rank, (2) p-value, (3) permuted ranks 
% and (4) mean opposite acutal rank
% (and (4) actual ranks per trial - ; actual_ranks') - no more
results = [av_observed_rank; p; perm_ranks; av_opposite_rank];

end