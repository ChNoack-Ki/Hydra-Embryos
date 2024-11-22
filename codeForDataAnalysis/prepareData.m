function animalData = prepareData(animalNumber, showPlots)
% this functions loads calcium imaging recordings, processes them and saves
% them as .mat file
% 
% input arguments:
%  - animalNumber : name for recorded animal, e.g. H54
%  - showPlots    : boolean, determines if plots are shown
%
% output arguments:
%  - animalData   : cell array that, for each measurement stage, contains:
                     % - dFF0             : fluorescence traces
                     % - time             : time vector
                     % - T                : sampling period
                     % - numberOfNeurons  : number of recorded neurons
                     % - spikest          : estimate spike times
                     % - spikeEvents      : estimate spike events
                     % - fittedSignal     : fitted fluorescence traces without drift
                     % - coords           : x- and y coordinates of neurons
                     % - spikeFrequencies : spike frequencies of each neuron


   %% deterime file names for animal recordings 
   directoryName = [animalNumber,'/'];
   fid        = fopen(fullfile(directoryName,'stages.txt'));
   stageNames = textscan(fid,'%s','delimiter',',');
   fclose(fid);
   stageNames = stageNames{1,1};

   %% load data
   animalData = cell(length(stageNames),1);
   for stage = 1:length(stageNames)
      data              = readmatrix([directoryName,stageNames{stage},'_final_file.csv']);
      trackLength       = max(data(:,1));
      numberOfNeurons   = length(data(:,1))/trackLength;

      % load and normalize fluorescence traces
      dFF0              = zeros(trackLength,numberOfNeurons);
      tracksToBeRemoved = [];
      for n = 1:numberOfNeurons
         dFF0(:,n) = data(1 + (n-1)*trackLength:n*trackLength,5);
         if max(dFF0(:,n))==0 || length(find(dFF0(:,n)>0))<2
            numberOfNeurons   = numberOfNeurons-1;
            tracksToBeRemoved = [tracksToBeRemoved, n];
         else
            dFF0(:,n) = dFF0(:,n)./max(dFF0(:,n)); 
         end
      end
      dFF0(:,tracksToBeRemoved) = [];
      FF0 = dFF0 + 1;

      % load coordinate data
      xData                = table2array(readtable([directoryName,'coordinates/',stageNames{stage},'_Position-X.xlsx']));
      yData                = table2array(readtable([directoryName,'coordinates/',stageNames{stage},'_Position-Y.xlsx']));
      x                    = min(xData(:,2:end));
      y                    = min(yData(:,2:end));
      x(tracksToBeRemoved) = [];
      y(tracksToBeRemoved) = [];

      if length(x)>numberOfNeurons
         x(end-(length(x)-numberOfNeurons)) = [];
      end
      if length(y)>numberOfNeurons
         y(end-(length(y)-numberOfNeurons)) = [];
      end
      
      if length(x)<numberOfNeurons
         x(end-(numberOfNeurons-length(x))) = nan;
      end
      if length(y)<numberOfNeurons
         y(end-(numberOfNeurons-length(y))) = nan;
      end
      coords = [x;y];

      % calculate spike times and fit of fluorescence traces
      param                   = tps_mlspikes('par');
      param.dt                = data(2,6)-data(1,6);
      param.a                 = 0.23; % DF/F for one spike
      param.tau               = 1.87; % 0.79; % decay time constant (second)
      param.saturation        = 0.07; % OGB dye saturation
      param.finetune.sigma    = 0.1; % estimation for noise level
      param.drift.parameter   = .04; % estimation for drift level
      param.dographsummary    = false;
      [spikest,fit,drift]     = spk_est(FF0,param);
      fittedSignal            = fit./drift;
      spikeEvents             = zeros(size(dFF0));
      t                       = data(1:trackLength,6);
      for n = 1:numberOfNeurons
         spikeEvents(ismembertol(t,spikest{n}),n)  = 1;%t(ismember(t,spikest{n}));
         fittedSignal(:,n)                         = (fittedSignal(:,n) - 1)/max(fittedSignal(:,n));
      end
      spikeFrequencies        = sum(spikeEvents)/max(t);
      
      %% store data in cell array
      stageData            = cell(9,1);
      stageData{1}         = dFF0;                    % fluorescence traces
      stageData{2}         = data(1:trackLength,6);   % time
      stageData{3}         = data(2,6)-data(1,6);     % sampling period
      stageData{4}         = numberOfNeurons;
      stageData{5}         = spikest;                 % spike times
      stageData{6}         = spikeEvents;             % spike events
      stageData{7}         = fittedSignal;            % fitted fluorescence traces without drift
      stageData{8}         = coords;                  % x- and y coordinates (on first and second row, respectively)
      stageData{9}         = spikeFrequencies;       

      animalData{stage}    = stageData; 

      % plot fluorescence traces
      if showPlots
         figure
         plot(data(1:trackLength,6),fittedSignal)
         title(['Fluorescence Traces of ', animalNumber, '-', num2str(stage)]);
      end

   end

   % save data as .mat file
   save(['animalData',animalNumber,'.mat'], 'animalData');
end
