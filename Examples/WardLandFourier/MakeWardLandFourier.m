%% Locate WardLand renderings and do spatial frequency analysis.
%
% This script performs spatial frequency analysis on luminance images from
% WardLand recipes.
%
% You should run this script after you've already executed some WardLand
% renderings, as with ExecuteWardLandReferenceRecipes.
%
% You can edit some parameters at the top of this script to change things
% like where to look for rendering data.
%
% @ingroup WardLand

%% Overall Setup.
clear;
clc;

% locate the renderings
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');

% choose which WardLand conditions to analyze
lineColors = lines(100);
todo = struct( ...
    'conditionName', {'ward', 'boring', 'mask-1', 'ward'}, ...
    'blurred', {false, false, false, true}, ...
    'conditionTitle', [], ...
    'plotColor', {lineColors(1,:), lineColors(2,:), lineColors(3,:), lineColors(4,:)});

% keep track of renderings and analysis found under each todo item.
allRenderings = [];

% for sRGB conversion
toneMapFactor = 100;
isScale = true;

% for frequency distributions
nBands = 25;
amplitudeLimits = [-18 0];

% for all plots
fontSize = 14;

%% For each todo item, plot sRGB, luminance, fft, and freq. distribution.
nTodo = numel(todo);
for tt = 1:nTodo
    % choose which condition to analyze
    conditionName = todo(tt).conditionName;
    blurred = todo(tt).blurred;
    renderings = FindFiles(hints.workingFolder, [conditionName '\.mat$']);
    nRecipes = numel(renderings);
    
    % give a name for this todo item
    if (blurred)
        conditionTitle = ['blurred ' conditionName];
    else
        conditionTitle = conditionName;
    end
    todo(tt).conditionTitle = conditionTitle;
    
    % keep track of all renderings and analyses encountered
    if isempty(allRenderings)
        allRenderings = cell(nTodo, nRecipes);
    end
    
    % analyze and plot this condition
    figure('Name', conditionTitle);
    position = get(gcf(), 'Position');
    set(gcf(), 'Position', [position(1:2) 1080 720]);
    for ii = 1:nRecipes
        %% Calulate with data.
        data = load(renderings{ii});
        
        % get sRGB and XYZ
        [sRGB, XYZ] = MultispectralToSRGB( ...
            data.multispectralImage, data.S, toneMapFactor, isScale);
        luminance = XYZ(:,:,2);
        
        % blur the image as a test of intuition
        if (blurred)
            filter = fspecial('gaussian', 10, 3);
            luminance = imfilter(luminance, filter, 'same');
        end
        
        % get Fourier transform
        fourierTransform = fft2(luminance);
        fourierMean = fourierTransform(1,1);
        fourierCentered = fftshift(fourierTransform);
        fourierNormalized = fourierCentered ./ fourierMean;
        
        % get the frequency distribution
        [amplitudes, frequencies] = FourierDistribution(fourierNormalized, nBands);
        
        % keep track of all renderings and analyses encountered
        rendering.recipeName = data.hints.recipeName;
        rendering.conditionTitle = conditionTitle;
        rendering.amplitudes = amplitudes;
        rendering.frequencies = frequencies;
        allRenderings{tt}{ii} = rendering;
        
        
        %% Plot the results.
        
        % plot sRGB
        plotOffset = (ii-1)*4;
        subplot(nRecipes, 4, plotOffset + 1);
        imshow(uint8(sRGB));
        
        set(gca(), 'FontSize', fontSize);
        ylabel(data.hints.recipeName)
        if (ii == 1)
            title([conditionTitle ': sRGB']);
        end
        
        % plot Y/luminance
        subplot(nRecipes, 4, plotOffset + 2);
        imshow(luminance ./ max(luminance(:)));
        
        set(gca(), 'FontSize', fontSize);
        if (ii == 1)
            title('Luminance / Y');
        end
        
        % visualize the Fourier transform data
        subplot(nRecipes, 4, plotOffset + 3);
        imshow(log(abs(fourierNormalized)), []);
        
        set(gca(), 'FontSize', fontSize);
        if (ii == 1)
            title('log(fft amplitude)');
        end
        
        % plot frequency distributions
        subplot(nRecipes, 4, plotOffset + 4);
        plot(frequencies, log(amplitudes), ...
            'LineWidth', 2, ...
            'Color', todo(tt).plotColor);
        
        ylim(amplitudeLimits)
        set(gca(), 'FontSize', fontSize);
        if (ii == 1)
            title('frequency distribution');
            ylabel('log(fft amplitude)')
            xlabel('frequency')
        end
    end
end

%% Summarize frequency distributions for each recipe, across todo items.

figure('Name', 'Distribution Comparisons');
position = get(gcf(), 'Position');
set(gcf(), 'Position', [position(1:2) 540 720]);

for ii = 1:nRecipes
    subplot(nRecipes, 1, ii);
    plotNames = cell(1, nTodo);
    hold('on');
    for tt = 1:nTodo
        rendering = allRenderings{tt}{ii};
        plot(rendering.frequencies, log(rendering.amplitudes), ...
            'LineWidth', 2, ...
            'Color', todo(tt).plotColor);
        plotNames{tt} = rendering.conditionTitle;
    end
    hold('off');
    ylim(amplitudeLimits);
    ylabel(rendering.recipeName);
    set(gca(), 'FontSize', fontSize);
    
    if (ii == 1)
        title('frequency distributions');
        xlabel('frequency')
        legend(plotNames, 'Location', 'SouthWest');
    end
end