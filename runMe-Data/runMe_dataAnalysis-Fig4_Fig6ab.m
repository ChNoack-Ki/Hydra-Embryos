% author: Sebastian Jenderny
% last update: August 13th, 2024

clearvars; 
clc; close all;

%% paths
externalPackagesPath = fullfile('externalPackages');
processedDataPath    = fullfile('..','dataForPaper');
codePath             = fullfile('codeForDataAnalysis');
addpath(genpath(externalPackagesPath));
addpath(genpath(processedDataPath));
addpath(genpath(codePath));

%% analyse data
animalNumber   = 'H84';
loadOldData    = true; % load already processed data to skip processing and directly analyze data
analyseData(animalNumber, loadOldData, 'measurement');

%% remove paths
rmpath(genpath(externalPackagesPath));
rmpath(genpath(processedDataPath));
rmpath(genpath(codePath));