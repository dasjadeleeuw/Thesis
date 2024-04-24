function [output] = cosmo_do_IEM(ds_full,varargin)
%% CODE BY -NOTED BELOW- APPENDED TO BE USED IN COSMOMVPA SEARCHLIGHT.
% ALL CODE BY RADEMAKER & CHUNHARAS (2019)


% Turn off warnings
warning('off', 'all');

%% Setup necessary variables
pp_nr           =   varargin{1}.pp_nr;
nr_perms        =   varargin{1}.nr_perms;
real_labels     =   varargin{1}.real_labels;
shuffled_labels =   varargin{1}.shuffled_labels;
test_condition  =   varargin{1}.test_condition;      % specifies the kind of test set (stim or delay)
train_condition =   varargin{1}.train_condition;
x               =   (0:179);                         % all possible orientations
n_ori_chans     =   9;                               % nr of basis functions


%% Leave one run out
all_chan_resp = zeros(size(ds_full.samples, 1)/2, 180);
idx = 1;

for i = 1:27
    %% Train-test split
    % Define the train set
    ds_train = cosmo_slice(ds_full, (1:size(ds_full.samples,1)-size(real_labels,1)));

    % Exclude this run from train set
    exclude_chunk = ds_train.sa.chunks ~= i;
    ds_train = cosmo_slice(ds_train, exclude_chunk);
    
    % Test set is excluded run
    include_chunk = ds_full.sa.chunks == i + 27;
    ds_test = cosmo_slice(ds_full, include_chunk);
    
    % Make stimulus mask
    if strcmp(train_condition, 'stim')
        % If training on stim-response, use both stimuli
        orientations = real_labels(exclude_chunk, :);
        stim_mask = zeros(size(orientations, 1),180);
        for j = 1:size(orientations,1)
            stim_mask(j, orientations(j,1)+1) = 1; 
            stim_mask(j, orientations(j,2)+1) = 1;
        end
    elseif strcmp(train_condition, 'delay')
        % If training on delay, use the training targets (ami or umi)
        orientations = ds_train.sa.targets;
        stim_mask_train = zeros(size(orientations, 1),180);
        for j = 1:size(orientations,1)
            stim_mask_train(j, orientations(j,1)+1) = 1; 
        end
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
    % Note: in a circular space with xx from 0-pi, mu would be between
    % 0 and pi, and the function would use cos instead of cosd  

    % Extra variable for testing: training channel responses
    %train_chans = zeros(size(ds_train, 1), length(x));
    
    %% Training and testing the IEM
    step_size = length(x)/n_ori_chans; % will need this many steps to cover 180 degrees
    
    for b = 1:step_size
        chan_center = b:step_size:180;
    
        % Make basis functions
        basis_set = NaN(180,n_ori_chans); % basis-set can go in here
        for cc = 1:n_ori_chans
            basis_set(:,cc) = make_basis_function(x,chan_center(cc));
        end
        
        % Now generate the design matrix
        trnX = stim_mask_train*basis_set;
        if rank(trnX)~=size(trnX,2)
            fprintf('\nrank deficient training set Design Matrix\nReturning...\n')
            return;
        end
                
        % Compute weights
        w = trnX\ds_train; % uses design matrix (for these channel centers) and training data 
    
        % Compute the stimulus reconstruction for each trial, by filling in the
        % predicted orientations corresponding to the current centers of the 
        % basis functions. So here we reconstruct the memory orientation (after
        % having trained on the localizer donut)
        chan_resp(:,chan_center) = ((w*w')\w*ds_test').';

        % Extra; for testing
        %train_chans(:,chan_center) = trnX;
    
    end % end loop over basis set centers.   
   
    %% Concatenate channel responses
    all_chan_resp(idx:idx+nt-1, :) = chan_resp;
    idx = idx + nt;
end


%% Evaluate channel responses and store results: fidelity
% fidelity = fidelity_permutations(all_chan_resp, real_labels, shuffled_labels, pp_nr, nr_perms, test_condition);
% output.samples = fidelity;


%% Evaluate channel responses and store results: ranking
basis_funcs = NaN(180,180);
for b = 1:180
    basis_funcs(:,b) = make_basis_function(x,b);
end
results = ranking_perms(all_chan_resp, basis_funcs, real_labels, shuffled_labels, nr_perms, test_condition); 
output.samples = results;


end

