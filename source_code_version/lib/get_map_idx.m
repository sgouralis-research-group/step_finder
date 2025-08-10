function map_idx = get_map_idx(chain, idx)

sum_post = sum(chain.P,1)+chain.L; 
posterior = sum_post(idx); 
[~, map_idx] = max(posterior); 