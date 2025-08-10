function L = get_log_like(u,params)

v = params.wV/params.wG^2 + params.wF*u;
L = - 0.5 * sum( log(v) + (params.W-u).^2./v );

