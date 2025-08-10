function [sample_b,sample_h, sample_C, sample_u,sample_L,rec] = sampler_update_b_h_c_jointly( ...
    sample_b,sample_h, sample_C, sample_u,sample_L,rec, ...
    t,params)


for rep = 1:sum(rand(5*params.M*2,1)<0.5)

    propos_b = sample_b;
    propos_h = sample_h;
    propos_C = sample_C;

    m = randi(params.M); 

    %Update b(m)
    propos_b(m) = ~sample_b(m);

    if rand<0.5 

        temp_b = sample_b;
        temp_b(m)=false; 

        idx = find(temp_b); 
        time_other_active=t(idx); 

        smaller_idx = find(time_other_active<t(m));

        if isempty(smaller_idx) 
            propos_u = get_stimulus(propos_C,propos_h,t,propos_b,params.t,params.tau_exp);
            propos_L = get_log_like(propos_u,params);

            log_a = propos_L-sample_L ...
                +(propos_b(m) - sample_b(m))*params.b_prior_log_p1_m_log_p0;
        else

            %update with adjustment
            [~,I] = max(time_other_active(smaller_idx)); 
            m_prev = idx(I); 

            if propos_b(m) 
                propos_h(m_prev) = sample_h(m_prev) - sample_h(m);
            else
                propos_h(m_prev) = sample_h(m_prev) + sample_h(m);
            end

            if propos_h(m_prev)<0
                log_a = -inf;
            else

                propos_u = get_stimulus(propos_C,propos_h,t,propos_b,params.t,params.tau_exp);
                propos_L = get_log_like(propos_u,params);

                log_a = propos_L-sample_L ...
                    +(propos_b(m) - sample_b(m))*params.b_prior_log_p1_m_log_p0...
                    - (params.h_prior_phi+1)*log(propos_h(m_prev)/sample_h(m_prev))...
                    - (params.h_prior_phi-1)*params.h_prior_ref/propos_h(m_prev)...
                    + (params.h_prior_phi-1)*params.h_prior_ref/sample_h(m_prev);

            end
        end

    else %update next step

        temp_b = sample_b;
        temp_b(m)=false; 

        idx = find(temp_b); 
        time_other_active=t(idx); 

        bigger_idx = find(time_other_active>t(m));

        if isempty(bigger_idx) 

            if propos_b(m) 
                propos_C = sample_C - sample_h(m);
            else
                propos_C = sample_C + sample_h(m);
            end

            if propos_C<0
                log_a = -inf;
            else

                propos_u = get_stimulus(propos_C,propos_h,t,propos_b,params.t,params.tau_exp);
                propos_L = get_log_like(propos_u,params);

                log_a = propos_L-sample_L ...
                    + (propos_b(m) - sample_b(m))*params.b_prior_log_p1_m_log_p0...
                    + (params.C_prior_phi-1)*log(propos_C/sample_C)...
                    + params.C_prior_phi*(sample_C-propos_C)/params.C_prior_ref...
                    + log(sample_C/propos_C);
            end

        else %adjust the h_next

            [~,I] = min(time_other_active(bigger_idx)); 
            m_next = idx(I); 

            if propos_b(m) 
                propos_h(m_next) = sample_h(m_next) - sample_h(m);
            else
                propos_h(m_next) = sample_h(m_next) + sample_h(m);
            end

            if propos_h(m_next)<0
                log_a = -inf;
            else

                propos_u = get_stimulus(propos_C,propos_h,t,propos_b,params.t,params.tau_exp);
                propos_L = get_log_like(propos_u,params);

                log_a = propos_L-sample_L ...
                    +(propos_b(m) - sample_b(m))*params.b_prior_log_p1_m_log_p0...
                    - (params.h_prior_phi+1)*log(propos_h(m_next)/sample_h(m_next))...
                    - (params.h_prior_phi-1)*params.h_prior_ref/propos_h(m_next)...
                    + (params.h_prior_phi-1)*params.h_prior_ref/sample_h(m_next);

            end
        end


    end 


    if ~get_sanity_check(log_a)
        keyboard
    end

    % carry out acceptance test
    if log_a>=0 || rand < exp(log_a)
        sample_b = propos_b;
        sample_h = propos_h;
        sample_C = propos_C;
        sample_u = propos_u;
        sample_L = propos_L;

        rec(1) = rec(1) + 1;
    end 
    rec(2) = rec(2) + 1;

end 