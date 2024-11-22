% wave digital simulation of network growth of population N4 of Hydra hatchlings
% author       : Sebastian Jenderny
% last update  : November 19th, 2024

clearvars; clc; close all;

%% paths
externalPackagesPath = fullfile('externalPackages');
analysingCodePath    = fullfile('codeForDataAnalysis');
simulationCodePath   = fullfile('codeForGrowthSimulation');
processedDataPath    = fullfile('..','dataForPaper');
addpath(genpath(externalPackagesPath));
addpath(genpath(simulationCodePath));
addpath(genpath(analysingCodePath));
addpath(genpath(processedDataPath));

%% Hydra hatchling N4 coupling structure
couplingStructure;

%% simulation setup
% simulation parameters
T                 = 0.5e-3;                                    % step size
tEnd              = 220;
t                 = 0:T:tEnd;                                  % time vector
ni                = 2;                                         % number of additional iteration steps for solving implicit relationships
% setup for adding new neurons                                  
active            = nN;
inactive          = nN-1:-1:1;
TnewNeuron        = 2;                                         % time period for adding a new active neuron
% select random input current amplitude for neurons
jMin              = 120e-9;                                    % minimum current required for activity
jActive           = 100e-9*ones(1,nN);
jApp              = zeros(1,nN);
% logger data
sampleFactor      = 80;                                        % only store every nth value
u_logging         = zeros(ceil(length(t)/sampleFactor),nN);    % membrane potential of neuron nodes
etaCa_logging     = zeros(ceil(length(t)/sampleFactor),nN);    % calcium concentration of neuron nodes
zEl_logging       = zeros(ceil(length(t)/sampleFactor),nC);    % memristor states of gap junctions

%% parameters
modelParametersHigherFrequencies;

clear A Lp t

%% initialization of incident waves and states
% Morris-Lecar model
su                   = rng('default');
u_logging(1,1:end)   = -69e-3;
bC                   = u_logging(1,1:end);
ap2                  = zeros(1,nN);
ap3                  = zeros(1,nN);
zK                   = zeros(1,nN);
zL                   = zeros(1,nN);
% integrator circuit
aCI                  = 50e-9*ones(1,nN);
% create random coordinates and set initial gap junction memristor states
s2                   = rng('default'); % random seed of coordiantes
[x,y,distances]      = createRandomCoordinates(nN,N);
zEl                  = 0.15*distances';

%% run simulation
tic;
% initialize counters
loggingCounter       = 1;
sampleCounter        = 1;
timeUntilNewNeuron   = TnewNeuron;
edgeCounter          = 0;
% initialize active neurons
jApp(active)         = jMin + jActive(active);
NModified            = 0*N;
% run algorithm
for k = 1:length(0:T:tEnd)
   if ~isempty(inactive)
      if timeUntilNewNeuron <= 0
         % add new neurons
         active                                                                     = [inactive(1),active];
         NModified(active(1):end,end-edgeCounter-length(active)+2:end-edgeCounter)  = N(active(1):end,end-edgeCounter-length(active)+2:end-edgeCounter);
         inactive(1)                                                                = [];
         % update input current and counters
         jApp(active)                  = jMin + jActive(active);
         timeUntilNewNeuron            = TnewNeuron;
         edgeCounter                   = edgeCounter + length(active)-1;
      else
         timeUntilNewNeuron            = timeUntilNewNeuron - T;
      end
   end
   waveDigitalSimulation;
   sampleCounter = sampleCounter + 1;
end
t = 0:T*sampleFactor:tEnd;

disp('Time to simulate:')
simulatedTime = toc;

%% determine frequencies
minPeakDistance            = 0.5/(T*sampleFactor);
minPeakHeight              = 1e-9;
[spkFrequencies]           = calculateSpikeFrequencies(t,etaCa_logging,minPeakDistance,minPeakHeight);
% toc;

%% export results
% determine duration of and pauses between stages of development
duration          = 20;
pause             = 0;
% export results as m-File
exportSimulationData;
% export results as avi
tic;
% exportSimulationAsVideo;
toc;

%% detect communities 
% specific settings are found in analyseData()
s3                         = rng('default'); % disable random seed of community detection
[numberOfStages, output]   = analyseData('SimulatedGrowth', true,'simulation',false);
sortingOrders              = output(1:numberOfStages);
numberOfComms              = output{numberOfStages+1};
allCommSizes               = output(numberOfStages+2:end);

%% plot results
plotResults;

%% remove paths
rmpath(genpath(externalPackagesPath));
rmpath(genpath(analysingCodePath));
rmpath(genpath(simulationCodePath));
rmpath(genpath(processedDataPath));