function [sample_C,sample_h,sample_u,sample_L,rec] = sampler_update_c_h_combined_mess( ...
          sample_C,sample_h,sample_u,sample_L,rec, ...
          t,b,params)

%% update inactive
idx = find(~b); 
sample_h(idx) =(params.h_prior_phi-1)*params.h_prior_ref  ./ randg(params.h_prior_phi,length(idx),1);

%% update active
idx = find(b); 
M = length(idx); 

[~, idx_max] = max(t(idx)); 
last_idx = idx(idx_max);

[~,index] = sort(t(idx)); 
ord_idx = idx(index); 

for rep = 1:sum(rand(5*(M+1)*2,1)<0.5) 

    propos_h = sample_h;
    propos_C = sample_C;

    % pick sampler
    i = randi(M+1);

    % prepare mess
    sample_a = params.a_sig * randn;
    tempor_a = params.a_sig * randn;

    % pick slice
    U_prop = log(rand);
    
    % pick interval
    T = 2*pi*rand;
    T_min = T - 2*pi;
    T_max = T;

    
    if i == M+1 
        
        while true 

            rec(2) = rec(2) + 1;
            
            % get proposal
            propos_a = cos(T)*sample_a + sin(T)*tempor_a;
            propos_C = sample_C*exp(sample_a-propos_a);
            
            % make adjustments and get log_a
            if isempty(idx)
                propos_u = get_stimulus(propos_C,sample_h,t,b,params.t,params.tau_exp);
                propos_L = get_log_like(propos_u,params);
    
                log_a = (sample_a-propos_a) ...
                      + propos_L-sample_L ...
                      + (params.C_prior_phi-1)*log(propos_C/sample_C)...
                      + params.C_prior_phi*(sample_C-propos_C)/params.C_prior_ref;
            else
                propos_h(last_idx) = sample_C-propos_C + sample_h(last_idx);

                if propos_h(last_idx)<0
                    log_a = -inf;
                else
                    propos_u = get_stimulus(propos_C,propos_h,t,b,params.t,params.tau_exp);
                    propos_L = get_log_like(propos_u,params);
    
                    log_a = (sample_a-propos_a) ...
                          + propos_L-sample_L ...
                          + (params.C_prior_phi-1)*log(propos_C/sample_C)...
                          + params.C_prior_phi*(sample_C-propos_C)/params.C_prior_ref...
                          - (params.h_prior_phi+1)*log(propos_h(last_idx)/sample_h(last_idx))...
                          - (params.h_prior_phi-1)*params.h_prior_ref/propos_h(last_idx)...
                          + (params.h_prior_phi-1)*params.h_prior_ref/sample_h(last_idx);
                end
            end

            if ~get_sanity_check(log_a)
                keyboard
            end

            % carry acc test
            if U_prop < log_a
                sample_L = propos_L;
                sample_C = propos_C;
                sample_h = propos_h;
                sample_u = propos_u;

                rec(1) = rec(1) + 1;
                break 
            else
                % update intervals
                if T < 0
                    T_min = T;
                else
                    T_max = T;
                end
                % prepare next proposal
                T = T_min + (T_max-T_min)*rand;
            end 

        end 
   
    else 

        m = ord_idx(i); 

        while true 

            rec(2) = rec(2) + 1;
            
            % get proposal
            propos_a = cos(T)*sample_a + sin(T)*tempor_a;
            propos_h(m) = sample_h(m)*exp(sample_a-propos_a);
    
            % make adjustments and get log_a
            if i==1
                propos_u = get_stimulus(sample_C,propos_h,t,b,params.t,params.tau_exp);
                propos_L = get_log_like(propos_u,params);
    
                log_a = (sample_a-propos_a) ...
                      + propos_L-sample_L ...
                      - (params.h_prior_phi+1)*log(propos_h(m)/sample_h(m))...
                      - (params.h_prior_phi-1)*params.h_prior_ref/propos_h(m)...
                      + (params.h_prior_phi-1)*params.h_prior_ref/sample_h(m);
            else 
                prev_m = ord_idx (i-1);
                propos_h(prev_m) = sample_h(prev_m) + sample_h(m) - propos_h(m);
            
                if propos_h(prev_m)<0
                    log_a = -inf;
                else
                    propos_u = get_stimulus(sample_C,propos_h,t,b,params.t,params.tau_exp);
                    propos_L = get_log_like(propos_u,params);
    
                    log_a = (sample_a-propos_a) ...
                          + propos_L-sample_L ...
                          - (params.h_prior_phi+1)*log(propos_h(m)/sample_h(m))...
                          - (params.h_prior_phi-1)*params.h_prior_ref/propos_h(m)...
                          + (params.h_prior_phi-1)*params.h_prior_ref/sample_h(m)...
                          - (params.h_prior_phi+1)*log(propos_h(prev_m)/sample_h(prev_m))...
                          - (params.h_prior_phi-1)*params.h_prior_ref/propos_h(prev_m)...
                          + (params.h_prior_phi-1)*params.h_prior_ref/sample_h(prev_m);
                end %log(a)
            end  %i==1  

            if ~get_sanity_check(log_a)
                keyboard
            end

            % carry acc test
            if U_prop < log_a
                sample_L = propos_L;
                sample_C = propos_C;
                sample_h = propos_h;
                sample_u = propos_u;

                rec(1) = rec(1) + 1;
                break 
            else
                % update intervals
                if T < 0
                    T_min = T;
                else
                    T_max = T;
                end
                % prepare next proposal
                T = T_min + (T_max-T_min)*rand;
            end

        end 

    end 

end 
