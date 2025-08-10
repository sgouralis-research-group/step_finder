function [sample_t,sample_u,sample_L,rec] = sampler_update_t_slice_sampler( ...
          sample_t,sample_u,sample_L,rec, ...
          C,h,b,params)

%% update inactive
idx = find(~b);
sample_t(idx) = params.t_prior_min + (params.t_prior_max-params.t_prior_min) *rand(length(idx),1);


%% Update active
idx = find(b);
M = length(idx);

for rep = 1:sum(rand(5*M*2,1)<0.5) 

     m = idx(randi(M));

    % pick slice
    log_U_prop = log(rand);

    % get interval
    t_min = params.t_prior_min;
    t_max = params.t_prior_max;

    while true

        rec(2) = rec(2) + 1; 

        propos_t = sample_t;

        % make proposal
        propos_t(m) = t_min + (t_max-t_min)*rand;

        % get acceptance
        propos_u = get_stimulus(C,h,propos_t,b,params.t,params.tau_exp);
        propos_L = get_log_like(propos_u,params);
        log_a = propos_L-sample_L;
        
        if ~get_sanity_check(log_a)
           keyboard
        end

        % carry acc test
        if log_U_prop < log_a 
            sample_t = propos_t;
            sample_u = propos_u;
            sample_L = propos_L;

            rec(1) = rec(1) + 1; 
            break 
        else
            
            if propos_t(m) < sample_t(m)
                t_min = propos_t(m);
            else
                t_max = propos_t(m);
            end
        end 
        
    end 

end 

