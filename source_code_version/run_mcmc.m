clear
format compact
clc

%% Add code to the path
addpath('./lib')

%% Load data 
data = readtable('demo_fluorescence_data.txt');

if ~all(ismember({'w_n', 't_n'}, data.Properties.VariableNames))
    error('Selected file must contain ''w_n'' and ''t_n'' columns.');
end

%% Define parameters
opts.units_meas = 'adu';
opts.units_stim = 'pht';
opts.units_time = 'sec';

opts.w = data.w_n;
opts.t = data.t_n;
opts.t_min = min(data.t_n);
opts.t_max = max(data.t_n);

opts.tau_exp = 0.1;      % exposure period
opts.wM = 4350;          % background offset
opts.wV = 1940;          % camera variance
opts.wG = 0.64;          % camera gain
opts.wF = 2;             % 2 = EMCCD, 1 = CMOS
opts.M = 25;             % max number of steps

%% Initialize chain 
chain = chainer_main([], 0, opts, false, false);

%% Expand chain 
batch_size = 100;
flg_status = true; % true = shows progress report in command window
flg_visual = false; % true = shows progress report in separate window
chain = chainer_main(chain, batch_size, [], flg_status, flg_visual);

%% Save result 
save('mcmc_output.mat', 'chain');

%% Plot results 
idx = find(chain.i>=chain.i(end)*0.2); % sets burn-in

get_signal_traces(chain, idx);
get_plot_matrix(chain, idx);
get_stepcount_histogram(chain, idx)

