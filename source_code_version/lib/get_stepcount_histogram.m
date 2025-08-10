function get_stepcount_histogram(chain, idx)

f = figure;
f.Units = 'inches'; 
f.Position = [1 3 6 3];

histogram(sum(chain.b(:,idx)), 'BinMethod', 'auto');
xlabel('Total number of steps (B)');
ylabel('Frequency');
title('Posterior over number of steps');
set(gca, 'YColor', 'none');

