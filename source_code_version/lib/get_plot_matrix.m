function get_plot_matrix(chain, idx)

C = chain.C(idx);
h = chain.h(:,idx);
t = chain.t(:,idx);
b = chain.b(:,idx);

%% Relabel
[relabeled_h, relabeled_t] = get_relabel(h,t,b,idx);

%% Get rid of outliers for plotting histograms
[~, outlierIdx_t] = rmoutliers(relabeled_t', 'mean'); 
[~, outlierIdx_h] = rmoutliers(relabeled_h', 'mean');
[~, outlierIdx_C] = rmoutliers(C', 'mean');

combinedOutlierIdx = outlierIdx_t | outlierIdx_h | outlierIdx_C; 

relabeled_h_clean = relabeled_h(:, ~combinedOutlierIdx);
relabeled_t_clean = relabeled_t(:, ~combinedOutlierIdx);
C_clean = C(~combinedOutlierIdx);


%% Thin data for scatter plots
thinning_factor = round(size(idx,2)./160);
thin_t = relabeled_t_clean(:, 1:thinning_factor:end);
thin_h = relabeled_h_clean(:, 1:thinning_factor:end);
thin_C = C_clean(1:thinning_factor:end);

%%
B = mode(sum(b));
%%
figure;

[~,AX,~,H,HAx] = plotmatrix([thin_t(1:B,:)', thin_h(1:B,:)', thin_C']);


%% Formatting
num_vars = 2 * B + 1;

%% Define Colors for Histograms
histogramColors = [repmat({'#77AC30'}, 1, B), ... 
                   repmat({'#EDB120'}, 1, B), ... 
                   {'#A2142F'}];             

for i = 1:length(H)
    if i <= length(histogramColors)
        H(i).FaceColor = histogramColors{i};
    else
        H(i).FaceColor = '#7E2F8E'; 
    end
    H(i).NumBins = 10;
end


%% Assign x-labels and y-labels
param_names_t = arrayfun(@(x) sprintf('t^{%d}_{stp}', x), 1:B, 'UniformOutput', false);
param_names_h = arrayfun(@(x) sprintf('h^{%d}_{stp}', x), 1:B, 'UniformOutput', false);
param_name_C = {'c_{bck}'};
all_param_names = [param_names_t, param_names_h, param_name_C];

for i = 1:num_vars
    xlabel(AX(end, i), all_param_names{i}, 'Interpreter', 'tex');
end

for i = 1:num_vars
    ylabel(AX(i, 1), all_param_names{i}, 'Interpreter', 'tex');
end

%% Remove Tick Labels
for i = 1:numel(AX)
    set(AX(i), 'XTick', [], 'YTick', []);  % Remove tick marks and tick labels
end

%% Delete Top Right Half of the Plot (since it is symmetric)
for i = 1:num_vars
    for j = i+1:num_vars
        delete(AX(i, j));
    end
end



%% Remove Top and Right Borders from Histograms
for i = 1:length(HAx)
    set(HAx(i), 'Box', 'off');                  
    set(HAx(i), 'XColor', 'none', 'YColor', 'none'); 
    set(HAx(i), 'TickDir', 'out'); 
    set(HAx(i), 'LineWidth', 1);   
end

%% Explicitly Remove Top and Right Borders of Diagonal Histograms
for i = 1:num_vars
    set(AX(i, i), 'Box', 'off');                  
    set(AX(i, i), 'XColor', 'none', 'YColor', 'none'); 
    set(AX(i, i), 'TickDir', 'out');              
end

%% Remove Box from the Last Diagonal Plot (Bottom Right)
set(AX(num_vars, num_vars), 'Box', 'off');
set(AX(num_vars, num_vars), 'XColor', 'none', 'YColor', 'none'); 


