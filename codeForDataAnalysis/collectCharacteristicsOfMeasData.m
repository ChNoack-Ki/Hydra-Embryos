function [numberOfComms,commSizes,frequencies,totalNeurons,maxCommSize,corrCoeffs,freqCVs,distances] = collectCharacteristicsOfMeasData(animalNumbers,maxNumberOfStages)
   % this functions collects the number of communities, community sizes, and frequency data for all present measurement data
   %
   % input arguments:
   %  - animalNumbers      : names of data file that should be processed, e.g. {'H1','H2'}
   %  - maxNumberOfStages  : maximum amount of analyzed time periods for all measurement data to be processed
   %
   % output arguments:
   %  - numberOfComms      : all community counts per analyzed time periods
   %  - commSizes          : all community sizes per analyzed time periods
   %  - frequencies        : firing rates of all tracked neurons per analyzed time periods
   %  - totalNeurons       : total amount of neurons per analyzed time periods
   %  - maxCommSize        : size of largest community per analyzed time periods
   %  - corrCoeffs         : all correlation coefficients per analyzed time periods
   %  - freqCVs            : coefficients of variation for frequencies per analyzed time periods
   %  - distances          : all distances between neurons per analyzed time periods

   numberOfComms  = cell(length(animalNumbers),1);
   commSizes      = cell(length(animalNumbers),1);
   frequencies    = cell(length(animalNumbers),1);
   totalNeurons   = cell(length(animalNumbers),1);
   corrCoeffs     = cell(length(animalNumbers),1);
   freqCVs        = cell(length(animalNumbers),1);
   distances      = cell(length(animalNumbers),1);
   for k = 1:length(animalNumbers)
      [numberOfStages, output] = analyseData(animalNumbers{k}, 'true', 'full output');
      close all;
      numberOfComms{k}      = output{numberOfStages+1};
      commSizes{k}          = output(numberOfStages+2:2*numberOfStages+1);
      frequencies{k}        = output(2*numberOfStages+2:3*numberOfStages+1);
      corrCoeffs{k}         = output(3*numberOfStages+2:4*numberOfStages+1);
      freqCVs{k}            = output{4*numberOfStages+2};
      distances{k}          = output(4*numberOfStages+3:end);
      totalNeurons{k}       = cellfun(@sum,commSizes{k});

      % force equal number of stages
      if numberOfStages<maxNumberOfStages
         commNumber                                         = numberOfComms{k};
         commNumber(numberOfStages+1:maxNumberOfStages)     = nan;
         numberOfComms{k}                                   = commNumber;

         commSize                                           = commSizes{k};
         commSize(numberOfStages+1:maxNumberOfStages)       = {nan};
         commSizes{k}                                       = commSize;

         frequency                                          = frequencies{k};
         frequency(numberOfStages+1:maxNumberOfStages)      = {nan};
         frequencies{k}                                     = frequency;

         neuronAmount                                       = totalNeurons{k};
         neuronAmount(numberOfStages+1:maxNumberOfStages)   = nan;
         totalNeurons{k}                                    = neuronAmount;

         corrCoeff                                          = corrCoeffs{k};
         corrCoeff(numberOfStages+1:maxNumberOfStages)      = {nan};
         corrCoeffs{k}                                      = corrCoeff;

         cvs                                                = freqCVs{k};
         cvs(numberOfStages+1:maxNumberOfStages)            = nan;
         freqCVs{k}                                         = cvs;

         distance                                           = distances{k};
         distance(numberOfStages+1:maxNumberOfStages)       = {nan};
         distances{k}                                       = distance;
      end

      % force equal lengths of stage data
      commSize           = commSizes{k};
      lComm = cellfun('size',commSize,2);
      for m = 1:length(commSize)
         comm = commSize{m};
         if lComm(m) < max(lComm)
            comm(lComm(m)+1:max(lComm)) = nan;
         end
         commSize{m} = comm';
      end
      commSizes{k} = cell2mat(commSize);

      frequency           = frequencies{k};
      lFreq = cellfun('size',frequency,2);
      for m = 1:length(frequency)
         freq = frequency{m};
         if lFreq(m) < max(lFreq)
            freq(lFreq(m)+1:max(lFreq)) = nan;
         end
         frequency{m} = freq';
      end
      frequencies{k} = cell2mat(frequency);

      corrCoeff           = corrCoeffs{k};
      lCoeff = cellfun('size',corrCoeff,2);
      for m = 1:length(corrCoeff)
         coeff = corrCoeff{m};
         if lCoeff(m) < max(lCoeff)
            coeff(lCoeff(m)+1:max(lCoeff)) = nan;
         end
         corrCoeff{m} = single(coeff');
      end
      corrCoeffs{k} = cell2mat(corrCoeff);

      distance           = distances{k};
      lDist = cellfun('size',distance,2);
      for m = 1:length(distance)
         dist = distance{m};
         if lDist(m) < max(lDist)
            dist(lDist(m)+1:max(lDist)) = nan;
         end
         distance{m} = single(dist');
      end
      distances{k} = cell2mat(distance);
   end

   % force equal dimensions of cell arrays via NaN-padding
   lComm = cellfun('size',commSizes,1);
   for k = 1:length(commSizes)
      commSize = commSizes{k};
      if lComm(k) < max(lComm)
         commSize(lComm(k)+1:max(lComm),:) = nan;
      end
      commSizes{k} = commSize;
   end

   lFreq = cellfun('size',frequencies,1);
   for k = 1:length(frequencies)
      frequency = frequencies{k};
      if lFreq(k) < max(lFreq)
         frequency(lFreq(k)+1:max(lFreq),:) = nan;
      end
      frequencies{k} = frequency;
   end

   lCoeff = cellfun('size',corrCoeffs,1);
   for k = 1:length(corrCoeffs)
      corrCoeff = corrCoeffs{k};
      if lCoeff(k) < max(lCoeff)
         corrCoeff(lCoeff(k)+1:max(lCoeff),:) = nan;
      end
      corrCoeffs{k} = corrCoeff;
   end

   lDist = cellfun('size',distances,1);
   for k = 1:length(distances)
      distance = distances{k};
      if lDist(k) < max(lDist)
         distance(lDist(k)+1:max(lDist),:) = nan;
      end
      distances{k} = distance;
   end

%    lDist = cellfun('size',distance,1);
%    for m = 1:length(distance)
%       dist = distance{m};
%       if lDist(m) < max(lDist)
%          dist(lDist(m)+1:max(lDist)) = nan;
%       end
%       distance{m} = single(dist');
%    end
%    distances{k} = cell2mat(distance);

   % save largest community size
   maxCommSize   = cell(length(animalNumbers),1);
   for k = 1:length(animalNumbers)
      commSize       = commSizes{k};
      maxCommSize{k} = commSize(1,:);
   end

   % convert to double matrices
   numberOfComms  = cell2mat(numberOfComms);
   commSizes      = cell2mat(commSizes);
   frequencies    = cell2mat(frequencies);
   totalNeurons   = cell2mat(totalNeurons);
   maxCommSize    = cell2mat(maxCommSize);
   corrCoeffs     = cell2mat(corrCoeffs);
   freqCVs        = cell2mat(freqCVs);
   distances      = cell2mat(distances);
end