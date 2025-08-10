function [G] = get_G(t_step, t, tau_exp)
% effective step response

if isempty(t_step)
    G = zeros(size(t));  
else
    G = ( min(t_step, t + 0.5 * tau_exp) - min(t_step, t - 0.5 * tau_exp) ) ...
        .* (t < t_step);
end
