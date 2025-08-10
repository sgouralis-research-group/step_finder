function u = get_stimulus(h_bck,h_stp,t_stp,b_stp,t,tau_exp)

u = h_bck*tau_exp + sum( h_stp(b_stp) .* get_G(t_stp(b_stp),t,tau_exp) , 1 );
