function get_signal_traces(chain, idx)

C = chain.C(idx);
h = chain.h(:,idx);
t = chain.t(:,idx);
b = chain.b(:,idx);

%% Load t, tau_exp
params = chain.params;
time = params.t;
tau_exp = params.tau_exp;


%% Get the stimulus for each iteration
stimulus = NaN(chain.params.N, length(idx));
for i = 1:length(idx)
    stimulus(:,i) = get_stimulus(C(i),h(:,i),t(:,i),b(:,i),time,tau_exp);
end

%% Find MAP
map_idx = get_map_idx(chain, idx);

C_map = C(map_idx);
h_map = h(b(:,map_idx),map_idx);
t_map = t(b(:,map_idx),map_idx);
%B = sum(b(:,map_idx));

%% Relabel t
[~, relabeled_t] = get_relabel(h,t,b,idx);

%% Plot the stumuli along with the data

t_fine = linspace(chain.params.t_min,chain.params.t_max,100*chain.params.N)';
U_map  =  C_map          + sum( h_map'.*(t_fine<t_map') , 2);

f = figure;
f.Units = 'inches'; 
f.Position = [1 1 6 3];

tiledlayout(4, 1, 'TileSpacing', 'compact' , 'Padding', 'compact');

colors = lines(5);

ax1 = nexttile;
p1 = histogram(relabeled_t(1,:), 'Normalization','count', 'EdgeColor','none', 'FaceColor', colors(1,:)); hold on 
p2 = histogram(relabeled_t(2,:), 'Normalization','count', 'EdgeColor','none', 'FaceColor', colors(2,:)); hold on 
p3 = histogram(relabeled_t(3,:), 'Normalization','count', 'EdgeColor','none', 'FaceColor', colors(5,:)); 
xlims = [params.t_prior_min, params.t_prior_max];
xlim(xlims)
set(ax1, 'YColor', 'none', 'XTickLabel', []);
box off

nexttile([3,1]);
xline(relabeled_t(1,:), 'Color', p1.FaceColor, Layer='bottom'); hold on
xline(relabeled_t(2,:), 'Color', p2.FaceColor, Layer='bottom');
xline(relabeled_t(3,:), 'Color', p3.FaceColor, Layer='bottom');

h2 = plot(time, stimulus,'.c'); 
h1 = plot(time, chain.params.W, '.k');
h3 = line(t_fine, U_map*tau_exp,'color','#EDB120','Linewidth', 2); 
box off
xlabel(['time (',chain.params.units_time,')'])
ylabel(['stimulus (',chain.params.units_stim,')'])
xlim(xlims)
legend([h1, h2(1), h3],{'Data','Stimulus', 'MAP Signal'}, 'location', 'northeast', 'box', 'off', 'fontsize', 8)
