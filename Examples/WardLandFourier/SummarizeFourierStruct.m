%% Summarize results from Fourier analysis stored in a "Fourier Struct".
%   @param fourierStruct "Fourier Struct" as from WardLandToFourierStruct()
%   @param fig optional figure handle to plot into
%   @param fontSize optional fontSize the plot.
%   @param lineProps optional cell array of line() function arguments
%
% @details
% Summarizes in a single plot the results of spatial frequency analysis
% stored in the given @a fourierStruct, as returned from
% AnalyzeFourierStruct().
%
% @details
% If @a lineProps is provided, it must be a cell array of cell arrays of
% property-value paris, with one element for each element of the given @a
% fourierStruct.  The arrays of property-value pairs will be passed to the
% line() function when plotting data for each fourierStruct.
%
% @details
% Returns the given @a fourierStruct with each element (maybe) updated.
% Also returns a figure handle for the new plot.
%
% @details
% Usage:
%   [fourierStruct, fig] = SummarizeFourierStruct(fourierStruct, fig, fontSize, lineProps)
%
% @ingroup WardLand
function [fourierStruct, fig] = SummarizeFourierStruct(fourierStruct, fig, fontSize, lineProps)

if nargin < 2 || isempty(fig)
    fig = figure();
end
figure(fig);

if nargin < 3 || isempty(fontSize)
    fontSize = 14;
end

% figure out a common y-lim for amplitude plots
results = [fourierStruct.results];
amplitudes = [results.amplitudes];
commonYLim = log([min(amplitudes) max(amplitudes)]);

nTodo = numel(fourierStruct);
plotColors = lines(nTodo);
hold('on');
for ii = 1:nTodo
    
    % choose line properties for the frequency distribution
    if nargin < 4 || isempty(lineProps)
        lineArgs = {'LineWidth', 2, 'Color', plotColors(ii,:)};
    else
        lineArgs = lineProps{ii};
    end
    
    plot(fourierStruct(ii).results.frequencies, ...
        log(fourierStruct(ii).results.amplitudes), ...
        lineArgs{:});
end
hold('off');

ylim(commonYLim);
set(gca(), 'FontSize', fontSize);
ylabel('log(fft amplitude)')
xlabel('frequency')

plotNames = {fourierStruct.name};
legend(plotNames, 'Location', 'Best');
