function U = get_U(h_bck,h_stp,t_stp,b_stp,t)

U = h_bck + sum (h_stp(b_stp).*(t<t_stp(b_stp)),2);

