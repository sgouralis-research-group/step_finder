function sample = chainer_init_sample(params)

%% counter
sample.i = 0;

%% values
sample.C = params.C_prior_ref / params.C_prior_phi * randg(params.C_prior_phi,       1,1);
sample.h =  (params.h_prior_phi-1)*params.h_prior_ref  ./ randg(params.h_prior_phi,params.M,1);
sample.t = params.t_prior_min + (params.t_prior_max-params.t_prior_min) *rand(params.M,1);
sample.b =                 1/( 1+exp(-params.b_prior_log_p1_m_log_p0) ) >rand(params.M,1);

%% book-keeping
sample.u = get_stimulus(sample.C,sample.h,sample.t,sample.b,params.t,params.tau_exp);
sample.L = get_log_like(sample.u,params);

% log-priors
sample.P = get_log_priors(sample.C,sample.h,sample.t,sample.b,params);

% records
sample.rec = repmat([0;realmin;realmin],1,3); 
