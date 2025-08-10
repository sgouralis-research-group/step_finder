function PR = get_log_priors(C,h,t,b,params)

if nargin<1
    PR = 4;
    return
end


if ~isempty(h) && ~isempty(t)
    if (C <= 0) ...
       || any(h <= 0) ...
       || any(t <= params.t_prior_min) ...
       || any(t >= params.t_prior_max)
        error('Prior bounds are violated')
    end
end


%% priors

PR = nan(get_log_priors,1);

% C
PR(1) =      (params.C_prior_phi-1)*log(C/params.C_prior_ref) - params.C_prior_phi/params.C_prior_ref*C  ;

% h
PR(2) = sum( -(params.h_prior_phi+1)*log(h/params.h_prior_ref) - (params.h_prior_phi-1)*params.h_prior_ref./h );

% t
PR(3) = 0;

% b
PR(4) = sum(b)*params.b_prior_log_p1_m_log_p0;
