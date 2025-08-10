function [relabeled_h, relabeled_t] = get_relabel(h_stp,t_stp,b_stp, idx)

relabeled_h = NaN(size(h_stp,1), length(idx));
relabeled_t = NaN(size(h_stp,1), length(idx));

for j = 1: length(idx)
    relabeled_h(b_stp(:,j),j) = h_stp(b_stp(:,j),j); 
    relabeled_t(b_stp(:,j),j) = t_stp(b_stp(:,j),j);
    [relabeled_t(:,j), idx_sort] = sort(relabeled_t(:,j));
    relabeled_h(:,j) = relabeled_h(idx_sort,j);
end


