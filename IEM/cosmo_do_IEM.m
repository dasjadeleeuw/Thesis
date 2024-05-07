function [output] = cosmo_do_IEM(ds_full,varargin)
% Function that applies IEMs to the specified dataset ds_full using leave one run out cross-validation. 
% Returns a zscore based on n permutations, either using fidelity or the ranking index as a 
% performance measure. 
% IEM CODE BY RADEMAKER & CHUNHARAS (2019)


% Turn off warnings
warning('off', 'all');

%% Setup necessary variables
pp_nr           =   varargin{1}.pp_nr;
nr_perms        =   varargin{1}.nr_perms;
real_labels     =   varargin{1}.real_labels;
shuffled_labels =   varargin{1}.shuffled_labels;     % labels used for permutations
x               =   (0:179);                         % all possible orientations
n_ori_chans     =   9;                               % nr of basis functions


%% Run IEM in leave one run out setup
all_chan_resp = zeros(size(ds_full.samples, 1)/2, 180);
idx = 1; % index of current trial

for i = 1:27
    %% Train-test split
    % Define the train set
    ds_train = cosmo_slice(ds_full, (1:size(ds_full.samples,1)-size(real_labels,1)));

    % Exclude the selected run from train set
    exclude_chunk = ds_train.sa.chunks ~= i;
    ds_train = cosmo_slice(ds_train, exclude_chunk);
    
    % Test set is excluded run
    include_chunk = ds_full.sa.chunks == i + 27;
    ds_test = cosmo_slice(ds_full, include_chunk);
    
    % Make stimulus mask
    orientations = ds_train.sa.targets;
    stim_mask_train = zeros(size(orientations, 1),180);
    for j = 1:size(orientations,1)
        stim_mask_train(j, orientations(j,1)+1) = 1; 
    end
    
    % Train and test samples
    ds_train = ds_train.samples;
    ds_test = ds_test.samples;
    
    %% Setup channel responses and tuning functions
    % Channel response variables
    nt = size(ds_test,1); % number of trials in test data
    chan_resp = NaN(nt,length(x));       
    
    % Anonymous function to make basis set of tuning functions
    basis_pwr = n_ori_chans-1;
    make_basis_function = @(xx,mu) (cosd(xx-mu)).^basis_pwr;
    
    %% Training and testing the IEM
    step_size = length(x)/n_ori_chans; % will need this many steps to cover 180 degrees
    
    for b = 1:step_size
        chan_center = b:step_size:180;
    
        % Make basis functions
        basis_set = NaN(180,n_ori_chans);
        for cc = 1:n_ori_chans
            basis_set(:,cc) = make_basis_function(x,chan_center(cc));
        end
        
        % Transform training stim mask to training channel responses
        trnX = stim_mask_train*basis_set;
        if rank(trnX)~=size(trnX,2)
            fprintf('\nrank deficient training set Design Matrix\nReturning...\n')
            return;
        end
                
        % Compute weights by solving for linear equations
        w = trnX\ds_train;
    
        % Compute the stimulus reconstruction for each trial in the form of channel responses
        chan_resp(:,chan_center) = ((w*w')\w*ds_test').';
    
    end % end loop over basis set centers 
   
    %% Concatenate channel responses
    all_chan_resp(idx:idx+nt-1, :) = chan_resp;
    idx = idx + nt;
end


%% Evaluate channel responses and store results: fidelity
% fidelity = fidelity_permutations(all_chan_resp, real_labels, shuffled_labels, pp_nr, nr_perms);
% output.samples = fidelity;


%% Evaluate channel responses and store results: ranking index
basis_funcs = NaN(180,180);
for b = 1:180
    basis_funcs(:,b) = make_basis_function(x,b);
end
results = ranking_perms(all_chan_resp, basis_funcs, real_labels, shuffled_labels, nr_perms); 
output.samples = results;


end

