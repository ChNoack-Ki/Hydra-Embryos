% author: Sebastian Jenderny
% last update: September 6th, 2024

clearvars; 
clc; close all;

%% paths
externalPackagesPath = fullfile('externalPackages');
processedDataPath    = fullfile('..','dataForPaper');
codePath             = fullfile('codeForDataAnalysis');
addpath(genpath(externalPackagesPath));
addpath(genpath(processedDataPath));
addpath(genpath(codePath));

%% collect characteristics of measurement data
[numberOfCommsNormal,commSizesNormal,frequenciesNormal,totalNeuronsNorm,maxCommNorm,corrCoeffsNorm,freqCVsNorm]  = collectCharacteristicsOfMeasData({'H63','H64','H65','H66','H67'},8);
[numberOfCommsCold,commSizesCold,frequenciesCold,totalNeuronsCold,maxCommCold,corrCoeffsCold,freqCVsCold]        = collectCharacteristicsOfMeasData({'H72','H75','H77','H80','H81'},8);
[numberOfCommsWarm,commSizesWarm,frequenciesWarm,totalNeuronsWarm,maxCommWarm,corrCoeffsWarm,freqCVsWarm]        = collectCharacteristicsOfMeasData({'H82','H83','H84','H85','H86'},8);

%% plot 

% stageVector = [0,1.5,3,4.5,6,7.5,24,240];
stageVector = [0,1.5,3,4.5,6,7.5,9,10.5];

%%% correlation coefficient plot
fig = figure;
% correlation coefficients - normal temperature
meanCoeff   = mean(corrCoeffsNorm,1,'omitnan');
stdCoeff    = std(corrCoeffsNorm,1,'omitnan');
densitiesP = meanCoeff + stdCoeff;
densitiesM = meanCoeff - stdCoeff;
h = fill([stageVector, fliplr(stageVector)], [densitiesP, fliplr(densitiesM)], 'black','LineStyle','none');
set(h,'facealpha',.1)
hold on;
plot(stageVector,meanCoeff, 'black');
xlabel('nth Time Period');
ylabel('correlation coefficients')

% correlation coefficients - cold temperature
meanCoeff   = mean(corrCoeffsCold,1,'omitnan');
stdCoeff    = std(corrCoeffsCold,1,'omitnan');
densitiesP = meanCoeff + stdCoeff;
densitiesM = meanCoeff - stdCoeff;
h = fill([stageVector, fliplr(stageVector)], [densitiesP, fliplr(densitiesM)], 'blue','LineStyle','none');
set(h,'facealpha',.1)
hold on;
plot(stageVector,meanCoeff, 'blue');

% correlation coefficients - warm temperature
meanCoeff   = mean(corrCoeffsWarm,1,'omitnan');
stdCoeff    = std(corrCoeffsWarm,1,'omitnan');
densitiesP = meanCoeff + stdCoeff;
densitiesM = meanCoeff - stdCoeff;
h = fill([stageVector, fliplr(stageVector)], [densitiesP, fliplr(densitiesM)], 'red','LineStyle','none');
set(h,'facealpha',.1)
hold on;
plot(stageVector,meanCoeff, 'red');
legend('normal','', 'cold','', 'warm','')

cleanfigure('targetResolution',100)
matlab2tikz('results/temperatureComparison/corrCoeffComparison.tex');

filePath = fullfile('results/temperatureComparison/corrCoeffComparison.pdf');
exportgraphics(fig,filePath);

%%% frequency plot
fig = figure;
% mean frequency - normal temperature
meanMeanFrequency    = mean(frequenciesNormal,1,'omitnan');
stdMeanFrequency     = std(frequenciesNormal,1,'omitnan');
densitiesP           = meanMeanFrequency + stdMeanFrequency;
densitiesM           = meanMeanFrequency - stdMeanFrequency;
h = fill([stageVector, fliplr(stageVector)], [densitiesP, fliplr(densitiesM)], 'black','LineStyle','none');
set(h,'facealpha',.1)
hold on;
plot(stageVector,meanMeanFrequency, 'black');
xlabel('Recording Number');
ylabel('f in Hz')

% mean frequency - cold temperature
meanMeanFrequency    = mean(frequenciesCold,1,'omitnan');
stdMeanFrequency     = std(frequenciesCold,1,'omitnan');
densitiesP           = meanMeanFrequency + stdMeanFrequency;
densitiesM           = meanMeanFrequency - stdMeanFrequency;
h = fill([stageVector, fliplr(stageVector)], [densitiesP, fliplr(densitiesM)], 'blue','LineStyle','none');
set(h,'facealpha',.1)
hold on;
plot(stageVector,meanMeanFrequency, 'blue');

% mean frequency - warm temperature
meanMeanFrequency    = mean(frequenciesWarm,1,'omitnan');
stdMeanFrequency     = std(frequenciesWarm,1,'omitnan');
densitiesP           = meanMeanFrequency + stdMeanFrequency;
densitiesM           = meanMeanFrequency - stdMeanFrequency;
h = fill([stageVector, fliplr(stageVector)], [densitiesP, fliplr(densitiesM)], 'red','LineStyle','none');
set(h,'facealpha',.1)
hold on;
plot(stageVector,meanMeanFrequency, 'red');
legend('normal','', 'cold','', 'warm','')

cleanfigure('targetResolution',100)
matlab2tikz('results/temperatureComparison/frequencyComparison.tex');

filePath = fullfile('results/temperatureComparison/frequencyComparison.pdf');
exportgraphics(fig,filePath);

%%% relative variance of frequencies plot
fig = figure;
% mean CV - normal temperature
meanCV    = mean(freqCVsNorm,1,'omitnan');
stdCV     = std(freqCVsNorm,1,'omitnan');
densitiesP           = meanCV + stdCV;
densitiesM           = meanCV - stdCV;
h = fill([stageVector, fliplr(stageVector)], [densitiesP, fliplr(densitiesM)], 'black','LineStyle','none');
set(h,'facealpha',.1)
hold on;
plot(stageVector,meanCV, 'black');
xlabel('Recording Number');
ylabel('CV of Frequencies')

% mean frequency - cold temperature
meanCV    = mean(freqCVsCold,1,'omitnan');
stdCV     = std(freqCVsCold,1,'omitnan');
densitiesP           = meanCV + stdCV;
densitiesM           = meanCV - stdCV;
h = fill([stageVector, fliplr(stageVector)], [densitiesP, fliplr(densitiesM)], 'blue','LineStyle','none');
set(h,'facealpha',.1)
hold on;
plot(stageVector,meanCV, 'blue');

% mean frequency - warm temperature
meanCV    = mean(freqCVsWarm,1,'omitnan');
stdCV     = std(freqCVsWarm,1,'omitnan');
densitiesP           = meanCV + stdCV;
densitiesM           = meanCV - stdCV;
h = fill([stageVector, fliplr(stageVector)], [densitiesP, fliplr(densitiesM)], 'red','LineStyle','none');
set(h,'facealpha',.1)
hold on;
plot(stageVector,meanCV, 'red');
legend('normal','', 'cold','', 'warm','')

cleanfigure('targetResolution',100)
matlab2tikz('results/temperatureComparison/frequencyCVsComparison.tex');

filePath = fullfile('results/temperatureComparison/frequencyCVsComparison.pdf');
exportgraphics(fig,filePath);

%%% ratio plot
fig = figure;
% ratio of largest community size to total amount of neurons - normal temperature
ratio         = maxCommNorm./totalNeuronsNorm;
meanRatio     = mean(ratio,1,'omitnan');
stdRatio      = std(ratio,1,'omitnan');
densitiesP    = meanRatio + stdRatio;
densitiesM    = meanRatio - stdRatio;
h = fill([stageVector, fliplr(stageVector)], [densitiesP, fliplr(densitiesM)], 'k','LineStyle','none');
set(gca, 'FontName', 'Arial')
set(h,'facealpha',.1)
grid on;
hold on;
plot(stageVector,meanRatio, 'k');
xlabel('Recording in h');
ylabel('Average size main community')
xlim([0,10.5])
xticks([0,1.5,3,4.5,6,7.5,9,10.5])
xticklabels({'0','1.5','3','4.5','6','7.5','24','240'})

% ratio of largest community size to total amount of neurons - cold temperature
ratio         = maxCommCold./totalNeuronsCold;
meanRatio     = mean(ratio,1,'omitnan');
stdRatio      = std(ratio,1,'omitnan');
densitiesP    = meanRatio + stdRatio;
densitiesM    = meanRatio - stdRatio;
h = fill([stageVector, fliplr(stageVector)], [densitiesP, fliplr(densitiesM)], 'blue','LineStyle','none');
set(h,'facealpha',.1)
hold on;
plot(stageVector,meanRatio, 'blue');

% ratio of largest community size to total amount of neurons - warm temperature
ratio         = maxCommWarm./totalNeuronsWarm;
meanRatio     = mean(ratio,1,'omitnan');
stdRatio      = std(ratio,1,'omitnan');
densitiesP    = meanRatio + stdRatio;
densitiesM    = meanRatio - stdRatio;
h = fill([stageVector, fliplr(stageVector)], [densitiesP, fliplr(densitiesM)], 'red','LineStyle','none');
set(h,'facealpha',.1)
hold on;
plot(stageVector,meanRatio, 'red');
% legend('normal','', 'cold','', 'warm','')

cleanfigure('targetResolution',100)
matlab2tikz('results/temperatureComparison/ratioComparison.tex');

filePath = fullfile('results/temperatureComparison/ratioComparison.pdf');
exportgraphics(fig,filePath);

%% remove paths
rmpath(genpath(externalPackagesPath));
rmpath(genpath(processedDataPath));
rmpath(genpath(codePath));