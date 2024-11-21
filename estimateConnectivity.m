function estimate = estimateConnectivity(data, minNumberOfNeurons, method, signalType, useCompleteData, showPlots, nameOfRecording)
% this functions estimates the connectivity of calcium-imaging recordings.
% 
% input arguments:
%  - data               : recorded data
%  - minNumberOfNeurons : minimum number of neurons of all recordings
%  - method             : 'correlation'
%  - signalType         : options: 'spikes', 'raw dFF0', 'normalized dFF0'
%  - showPlots          : boolean, determines if plots are shown
%  - useCompleteData    : decide to use all neurons instead of a subset that ensures a consistent number of neurons for all analyzed stages
%  - nameOfRecording    : name of processed recording
%
% output arguments:
%  - estimate           : matrix for connectivity estimation

   %% pick random tracks
   trackNumbersList = 1:data{4};
   tracks = zeros(minNumberOfNeurons,1);
   for k = 1:minNumberOfNeurons
      idx                  = randi([1,length(trackNumbersList)]);
      tracks(k)            = trackNumbersList(idx);
      trackNumbersList(idx) = [];
   end

   switch signalType
      case 'spikes'
         signal = data{6};
      case 'raw dFF0'
         signal = data{1};
      case 'normalized dFF0'
         signal = data{7};
      otherwise
         error('Unknown signal type!')
   end

  if ~ useCompleteData
   signal = signal(:,tracks);
  end

   %% calculate estimate
   switch method
      case 'correlation'
         estimate = corrcoef(signal);
      otherwise
         error('Unknown estimation method!')
   end

   %% plot estimation
   if showPlots
      figure
      imagesc(estimate);
      colorbar;
      title(['Connectivity Estimation of ', nameOfRecording])
   end

end