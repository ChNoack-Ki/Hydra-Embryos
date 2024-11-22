function [totalFrequencies] = calculateSpikeFrequencies(t,signal, minPeakDistance, minPeakHeight)
% this function calculates the spike frequencies of the sum signal of all neurons
%
% input arguments:
%  - t                  : time vector
%  - signal             : neuron activity, either membrane potential or calcium concentration
%  - minPeakDistance    : minimum distance between detected spikes
%  - minPeakHeight      : minimum height of a detected spike
%
% output arguments:
%  - totalFrequencies   : spike frequencies of sum signal

  
   %% determine population frequency
   sumSignal         = sum(signal,2);
   [~,indices]       = findpeaks(sumSignal,'MinPeakDistance',minPeakDistance, 'MinPeakHeight',minPeakHeight);
   totalFrequencies  = zeros(1,length(t));
   if ~isempty(indices)
      totalFrequencies(indices(1))     = 1/t(indices(1));
      totalFrequencies(indices(2:end)) = 1./diff(t(indices));
   end
   
end