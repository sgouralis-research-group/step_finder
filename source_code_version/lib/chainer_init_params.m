function params = chainer_init_params(opts)


%% set-up

% units
params.units_meas = opts.units_meas; 
params.units_stim = opts.units_stim; 
params.units_time = opts.units_time; 

% sizes
params.M = opts.M; 
params.N = numel(opts.w); 

% parameters
params.t_min = double( opts.t_min ); 
params.t_max = double( opts.t_max ); 

params.tau_exp = double( opts.tau_exp ); 

params.wM = double( opts.wM ); 
params.wV = double( opts.wV ); 
params.wG = double( opts.wG ); 
params.wF = double( opts.wF ); 

% data
params.t =   double( reshape(opts.t,1,params.N) ); 
params.W = ( double( reshape(opts.w,1,params.N) ) - params.wM )/params.wG; 


%% sanity checks
if any(diff(params.t)<=0)
    error('Timepoints must be sorted')
end

if params.t_min>params.t(1  ) ...
|| params.t_max<params.t(end)
    error('Timepoints must remain inside [t_min,t_max]')
end


%% priors

% background
params.C_prior_phi = 2;
params.C_prior_ref = (params.W(end)/params.tau_exp);

% steps
params.h_prior_phi = 3;
params.h_prior_ref = ((params.W(1)-params.W(end))/(2*params.tau_exp));

% time
params.t_prior_min = params.t_min; 
params.t_prior_max = params.t_max; 

% loads
log_b_prior_gamma = 0; 

if params.M <= exp( log_b_prior_gamma )
    error('Inconsistent BNP approximation. Adjust M or \gamma')
end

b_prior_log_p1 = log_b_prior_gamma - log(params.M);
b_prior_log_p0 = log1p(-exp(b_prior_log_p1));
params.b_prior_log_p1_m_log_p0 = b_prior_log_p1 - b_prior_log_p0;

%% MCMC Parameters
params.c_propos_sigma = 500; 
params.c_propos_a = 20;      
params.h_propos_sigma = 100; 
params.h_propos_a = 20;       
params.t_propos_sigma = 5; 
params.a_sig = 1; 
