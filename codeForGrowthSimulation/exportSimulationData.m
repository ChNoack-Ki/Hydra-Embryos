% store simulation results as cell array and export them as mat-File to make the data 
% available to the existing processing routine

%% split data into single stages that are to be investigated
samplesPerPeriod  = duration/(T*sampleFactor);
samplesPerPause   = pause/(T*sampleFactor);
numberOfStages    = ceil(t(end)/(duration+pause));

%% store data
animalData        = cell(numberOfStages,1);
for k = 1:numberOfStages
   % determine number of active neurons
   u                    = u_logging((k-1)*samplesPerPeriod + (k-1)*samplesPerPause + 1:k*samplesPerPeriod + (k-1)*samplesPerPause,:);
   nActiveNeurons       = length(find(max(u)>-20e-3));
   nIdx                 = nN:-1:nN-nActiveNeurons+1;
   % determine coordinates
   coords               = [[nan;nan] [x(nIdx);y(nIdx)]]; % adjust data to fit the processing routine
   % store data in cell array
   stageData            = cell(9,1);
   stageData{1}         = etaCa_logging((k-1)*samplesPerPeriod + (k-1)*samplesPerPause + 1:k*samplesPerPeriod + (k-1)*samplesPerPause,nIdx);    % fluorescence traces
   stageData{2}         = t((k-1)*samplesPerPeriod + (k-1)*samplesPerPause + 1:k*samplesPerPeriod + (k-1)*samplesPerPause);                     % time
   stageData{3}         = T;                                                                                                                    % sampling period
   stageData{4}         = nActiveNeurons;                                                                                                       % number of active neurons
   stageData{5}         = [];                                                                                                                   % spike times, not set
   stageData{6}         = [];                                                                                                                   % spike events, not set
   stageData{7}         = stageData{1};                                                                                                         % fitted fluorescence traces without drift
   stageData{8}         = coords;                                                                                                               % x- and y coordinates (on first and second row, respectively)
   stageData{9}         = [];                                                                                                                   % spike frequencies, not set
   stageData{10}        = zEl_logging((k-1)*samplesPerPeriod + (k-1)*samplesPerPause + 1:k*samplesPerPeriod + (k-1)*samplesPerPause,:);         % memristor states associated with real connection weights

   % store spike frequencies
   spikeFrequencies     = spkFrequencies((k-1)*samplesPerPeriod + (k-1)*samplesPerPause + 1:k*samplesPerPeriod + (k-1)*samplesPerPause);
   spikeFrequencies     = spikeFrequencies(spikeFrequencies>0);
   stageData{9}         = spikeFrequencies;

   animalData{k}    = stageData;
end

% save data
save(['animalData','SimulatedGrowth','.mat'], 'animalData');