function animalData = loadData(animalNumber, showPlots)
% this functions loads the processed calcium imaging recordings
% 
% input arguments:
%  - animalNumber       : label for specific longterm recording 
%  - showPlots          : boolean, determines if plots are shown
%
% output arguments:
%  - animalData   : cell array that, for each measurement stage, contains:
                     % - {1} : fluorescence traces
                     % - {2} : time vector
                     % - {3} : sampling period
                     % - {4} : number of recorded neurons
                     % - {5} : estimate spike times
                     % - {6} : estimate spike events
                     % - {7} : fitted fluorescence traces without drift
                     % - {8} : x- and y coordinates of neurons
                     % - {9} : spike frequencies of each neuron

   animalData = load(['animalData',animalNumber,'.mat']);
   animalData = animalData.animalData;

%    % update spike frequencies
%    for stage = 1:length(animalData)
%       stageData   = animalData{stage};
%       dFF0        = stageData{1};
%       t           = stageData{2};
%       frequencies = zeros(1,stageData{4});
%       for n = 1:stageData{4}
%          [~,indices] = findpeaks(dFF0(:,n),'MinPeakProminence',0.3);
%          if ~isempty(indices)
%             spikeTimes = t(indices);
%             dT             = [spikeTimes(1);diff(spikeTimes)];
%             frequencies(n) = mean(1./dT);
%          end
%       end
%       stageData{9}      = frequencies; 
%       animalData{stage} = stageData;
%    end
      
   % update spike frequencies
%    for stage = 1:length(animalData)
%       stageData   = animalData{stage};
%       dFF0        = stageData{1};
%       t           = stageData{2};
%       frequencies = [];
%       for n = 1:stageData{4}
%          [~,indices] = findpeaks(dFF0(:,n),'MinPeakProminence',0.9);
%          if ~isempty(indices)
%             spikeTimes = t(indices);
%             dT             = [spikeTimes(1);diff(spikeTimes)];
%             frequencies    = [frequencies (1./dT)'];
%          end
%       end
%       stageData{9}      = frequencies; 
%       animalData{stage} = stageData;
%    end

   % plot fluorescence traces
   if showPlots
      for stage = 1:length(animalData)
         figure
         plot(animalData{stage}{2},animalData{stage}{7})
         title(['Fluorescence Traces of ', animalNumber, '-', num2str(stage)]);
      end
   end

end