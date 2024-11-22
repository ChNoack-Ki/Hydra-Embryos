clc; clear all; close all;

%% paths
externalPackagesPath = fullfile('externalPackages');
analysingCodePath    = fullfile('codeForDataAnalysis');
processedDataPath    = fullfile('..','dataForPaper');
addpath(genpath(externalPackagesPath));
addpath(genpath(analysingCodePath));
addpath(genpath(processedDataPath));

%% load data
data = xlsread('spikesTemperatureDependency');
total = data(:,11);

%% define temperature sets
normal = total(1:29);
cold = total(30:59);
warm = total(60:end);

%% define different measured time points
% normal
n      = zeros(6,5);
n(1,:) = normal([1,7,13,18,24]);
n(2,:) = normal([2,8,14,19,25]);
n(3,:) = normal([3,9,15,20,26]);
n(4,:) = normal([4,10,16,21,27]);
n(5,:) = normal([5,11,17,22,28]);
n(6,:) = [normal([6,12]); nan; normal([23,29])];
n      = n';
nMean  = mean(n,'omitnan');
nStd   = std(n,'omitnan');
nP     = nMean + nStd;
nM     = nMean - nStd;
% cold
c      = zeros(6,5);
c(1,:) = cold([1,7,13,19,25]);
c(2,:) = cold([2,8,14,20,26]);
c(3,:) = cold([3,9,15,21,27]);
c(4,:) = cold([4,10,16,22,28]);
c(5,:) = cold([5,11,17,23,29]);
c(6,:) = cold([6,12,18,24,30]);
c      = c';
cMean  = mean(c,'omitnan');
cStd   = std(c,'omitnan');
cP     = cMean + cStd;
cM     = cMean - cStd;
% warm
w      = zeros(6,5);
w(1,:) = warm([1,7,13,19,25]);
w(2,:) = warm([2,8,14,20,26]);
w(3,:) = warm([3,9,15,21,27]);
w(4,:) = warm([4,10,16,22,28]);
w(5,:) = warm([5,11,17,23,29]);
w(6,:) = warm([6,12,18,24,30]);
w      = w';
wMean  = mean(w,'omitnan');
wStd   = std(w,'omitnan');
wP     = wMean + wStd;
wM     = wMean - wStd;

%% plot results
timeVector = [0,1.5,3,4.5,6,7.5];
fig = figure;
% normal
h = fill([timeVector, fliplr(timeVector)], [nP, fliplr(nM)], 'black','LineStyle','none');
set(h,'facealpha',.1)
set(gca, 'FontName', 'Arial')
grid on;
hold on;
plot(timeVector,nMean, 'black');
xlabel('Recording in h');
ylabel('Number of Spikes')
xlim([0,7.5])
xticks([0,1.5,3,4.5,6,7.5])
xticklabels({'0','1.5','3','4.5','6','7.5'})
ylim([1,15.5])
yticks([2,4,8,10,14])
% cold
h = fill([timeVector, fliplr(timeVector)], [cP, fliplr(cM)], 'blue','LineStyle','none');
set(h,'facealpha',.1)
hold on;
plot(timeVector,cMean, 'blue');
% warm
h = fill([timeVector, fliplr(timeVector)], [wP, fliplr(wM)], 'red','LineStyle','none');
set(h,'facealpha',.1)
hold on;
plot(timeVector,wMean, 'red');

filePath = fullfile(['results/','manualFrequencyComparison_fullFile.pdf']);
exportgraphics(fig,filePath);

%% remove paths
rmpath(genpath(externalPackagesPath));
rmpath(genpath(analysingCodePath));
rmpath(genpath(processedDataPath));