function [numberOfStages, outputArg] = analyseData(animalNumber,loadOldData, mode, disablePlots)
% this functions analyses calcium-imaging recordings with respect to a community detection.
% 
% input arguments:
%  - animalNumber       : name of data file that should be processed
%  - loadOldData        : boolean, choose to load previously pre-processed version of selected data. Fails if no previous version exists. If set to false, selected data is freshly pre-processed
%  - mode               : 'measurement' or 'simulation'
%  - disablePlots       : optional boolean, choose to disable plots
%
% output arguments:
%  - numberOfStages     : optional, number of analyzed stages
%  - outputArg          : optional, includes:
%                          - new sorting orders of neuron indices 
%                          - average number of detected communities
%                          - average sizes of detected communities

   %% setup python - only required for Leiden algorithm
%    setenv('path',['C:\Users\' getenv('USERNAME') '\Anaconda3\Library\bin;', getenv('path')]);
   setenv('path',['C:\Users\' getenv('USERNAME') '\Anaconda3\Library\bin;', winqueryreg('HKEY_CURRENT_USER', 'Environment', 'Path')]);

   %% settings
   if ~exist('disablePlots', 'var') || ~disablePlots
      % choose which results to show
      showFluorescenceTraces     = false;
      showConnectivityEstimates  = false;
      showDetectedCommunities    = true;
      showNetworkGraphs          = true;
      showFrequencyAnalysis      = false;
   else
      % all plots disabled
      showFluorescenceTraces     = false;
      showConnectivityEstimates  = false;
      showDetectedCommunities    = false;
      showNetworkGraphs          = false;
      showFrequencyAnalysis      = false;
   end
   
   % adjust community detection
   useCompleteData            = true;                    % choose to consider all tracks or only a subset. In the latter case, the number of neurons remains consistent throughout the analysis
   estimationMethod           = 'correlation';           
   signalType                 = 'normalized dFF0';       % choose between 'raw dFF0', 'normalized dFF0', and 'spikes'
   commDetectionMethod        = 'LeidenCPM';             % choose between 'Louvain', 'LeidenCPM', 'LeidenModularity'
   maxIter                    = 1;                       % determines how often one animal stage is processed for randomly picked fluorescence tracks
   comDetIter                 = 1;                       % number of repetitions of community detection algorithm
   resolution                 = 0.96;                    % resolution parameter for Leiden CPM (standard:0.96) and Louvain (standard:1)

   %% predefined modes for settings
   switch mode
   case 'measurement'
      getOutput         = false;
      getfullOutputData = false;
      disableRandomSeed = true; % disable random seed of commmunity detection
   case 'simulation'
      getOutput         = true;
      getfullOutputData = false;
      disableRandomSeed = true; % disable random seed of commmunity detection
   case 'full output'
      getOutput                  = true;
      getfullOutputData          = true;
      showFrequencyAnalysis      = true;
      showDetectedCommunities    = false;
      showNetworkGraphs          = false;
      disableRandomSeed          = true; % disable random seed of commmunity detection
   otherwise
      error('mode does not exist!')
   end


   %% load data
   tic;
   if loadOldData
      animalData = loadData(animalNumber, showFluorescenceTraces);
   else
      animalData = prepareData(animalNumber, showFluorescenceTraces);
   end
   disp('Time to prepare data:')
   toc;

   %% process data
   tic;
   % determine minimum number of neurons in recordings
   neuronNumbers = zeros(1,length(animalData));
   for k = 1:length(animalData)
      data             = animalData{k};
      neuronNumbers(k) = data{4};
   end
   minNumberOfNeurons = min(neuronNumbers);

   % evaluate average number and size of communities
   avgNumbersOfComms = zeros(1,length(animalData));
   avgCommSizes      = zeros(1,length(animalData));
   sortingOrders     = cell(1,length(animalData));
   allCommSizes      = cell(1,length(animalData));
   allNumberOfComms  = zeros(1,length(animalData));
   allCorrCoeffs     = cell(1,length(animalData));
   allDistances      = cell(1,length(animalData));
   for k = 1:length(animalData)
      avgNumberOfComms = 0;
      avgCommSize      = 0;
      nameOfRecording  = [animalNumber, '-', num2str(k)];
      for m = 1:maxIter
         % estimate connectivity
         estimate    = estimateConnectivity(animalData{k}, minNumberOfNeurons, estimationMethod, signalType, useCompleteData, showConnectivityEstimates, nameOfRecording);
         % correct NaNs
         estimate(isnan(estimate))=0;
         % detect communities
         [sortingOrder, numberOfComms,commSizes,Q,commVec] = detectCommunities(estimate,commDetectionMethod,comDetIter,animalData{k}{8},showDetectedCommunities, showNetworkGraphs, nameOfRecording, resolution, disableRandomSeed);
         avgNumberOfComms                          = avgNumberOfComms + numberOfComms;
         avgCommSize                               = avgCommSize + sum(commSizes)/length(commSizes);
         % show real network graphs
         if showNetworkGraphs && strcmp(mode,'simulation')
            plotRealNetworkGraphs
         end
      end
      allNumberOfComms(k)  = numberOfComms;
      avgNumbersOfComms(k) = avgNumberOfComms/maxIter;
      avgCommSizes(k)      = avgCommSize/maxIter;
      sortingOrders{k}     = sortingOrder;
      allCommSizes{k}      = commSizes';
      allCorrCoeffs{k}     = estimate(tril(true(size(estimate)),-1))';
      coeffs = allCorrCoeffs{k};
      % determine distances
      coords      = animalData{k}{8};
      x           = coords(1,1:end);
      y           = coords(2,1:end);
      % remove potential first NaN entries
      if anynan(x)
         x = x(2:end);
      end
      if anynan(y)
         y = y(2:end);
      end
      distances   = zeros(length(x));
      for pos=1:length(x)
         distances(pos,:) = sqrt( (x(pos)-x).^2 + (y(pos)-y).^2);
      end
      allDistances{k} = distances(tril(true(size(distances)),-1))';
      dist = allDistances{k};

   end
   disp('Time to analyse data:')
   toc;

   %% plot results
   if showFrequencyAnalysis
      allFrequencies   = cell(1,length(animalData));
      allVarCoeff      = zeros(1,length(animalData));
      for k = 1:length(animalData)
         allFrequencies{k}    = animalData{k}{9};
         allVarCoeff(k)       = mean(allFrequencies{k})./std(animalData{k}{9});
      end

      figure
      subplot(3,1,1)
      plot(1:length(animalData),mean(allFrequencies{k}));
      xlabel('points of recordings')
      ylabel('mean frequency in Hz')
      title(['Mean Spike Frequencies of ', animalNumber])
      subplot(3,1,2)
      plot(1:length(animalData),allVarCoeff);
      xlabel('points of recordings')
      ylabel('Coefficient of Variation')
      title(['Coefficient of Variation of Spike Frequencies of ', animalNumber])
   end

   %% set output variable

   if getOutput
      numberOfStages = length(animalData);
      if getfullOutputData
         outputArg      = [sortingOrders, allNumberOfComms, allCommSizes, allFrequencies, allCorrCoeffs, allVarCoeff, allDistances];
      else
         outputArg      = [sortingOrders, avgNumbersOfComms, allCommSizes];
      end
   end
end