%% Summarize image spatial statistics..
%   @param reductions cell array of reductions from AnalyzeSpatialStats()
%
% @details
% Show some handy summary figures for arbitrary but interesting spatial
% summary data as computed from AnalyzeSpatialStats().  @a reductions
% must be a cell array of "reduction" outputs from multiple calls to
% AnalyzeSpatialStats().
%
% @details
% Plots the mean and std of each reduction, across all elements of the
% given @a reductions.
%
% @details
% Returns the handle of the figure used for plotting.
%
% @details
% Usage:
%   fig = SummarizeSpatialStats(reductions)
function fig = SummarizeSpatialStats(reductions)

%% Organize the data for plotting.
allReductions = [reductions{:}];
plotNames = fieldnames(allReductions);
nPlots = numel(plotNames);
for ii = 1:nPlots
    name = plotNames{ii};
    r = [allReductions.(name)];
    
    % mean and std of data
    allRaw = cat(1, r.raw);
    plotData.(name).mean = mean(allRaw, 1);
    plotData.(name).std = std(allRaw, 0, 1);
    
    % range for plotting data
    plotData.(name).low = min([r.low]);
    plotData.(name).high = max([r.high]);
    
    % other plot polish (take the last one)
    plotData.(name).xCoords = r.xCoords;
    plotData.(name).xName = r.xName;
    plotData.(name).yName = r.yName;
    plotData.(name).titleName = r.titleName;
end

%% Plot a summary.
fig = figure();

for ii = 1:nPlots
    name = plotNames{ii};
    pd = plotData.(name);
    
    subplot(nPlots, 1, ii);
    errorbar(pd.xCoords, pd.mean, pd.std);
    
    title(pd.titleName);
    xlabel(pd.xName);
    ylabel(pd.yName);
    
    xlim(pd.xCoords([1 numel(pd.xCoords)]));
    
    if ~isnan(pd.low) && ~isnan(pd.high)
        set(gca(), 'YLim', [pd.low pd.high]);
    end
end

