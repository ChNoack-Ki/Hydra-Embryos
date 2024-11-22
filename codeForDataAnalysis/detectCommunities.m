function [sortingOrder, numberOfComms,commSizes,Q,commVec] = detectCommunities(conMat,method,maxIter,coords,showCommunities, showGraphs, nameOfRecording, resolution_param, disableRandomSeed)
% this functions detects communities of calcium-imaging recordings of neurons based on the Luovain or Leiden algorithm.
% 
% input arguments:
%  - conMat             : estimated connectivity matrix (either correlation matrix or adjancency matrix)
%  - method             : for correlation approach, choose 'Louvain', 'LeidenCPM', or 'LeidenModularity'
%  - maxIter            : number of iterations for community detection algorithm
%  - coords             : coordinates of recorded neurons
%  - showCommunities    : boolean, determines if detected communities are shown
%  - showGraphs         : boolean, determines if network graph is shown
%  - nameOfRecording    : name of processed recording
%  - resolution_param   : resolution parameter for Louvain and LeidenCPM
%  - disableRandomSeed  : optional boolean, choose to disable random seed of community detection
%
% output arguments:
%  - sortingOrder       : new sorting order of neuron indices
%  - numberOfComms      : number of detected communities
%  - commSizes          : sizes of detected communities
%  - Q                  : quality score
%  - commVec            : assignment of neurons to detected communities

   %% detect communities
   commVec = 1:length(conMat);   % initial community affiliation vector
   switch method
      case 'Louvain'
         mode  = 'negative_sym';    % handle correlation matrices
         for k = 1:maxIter
            [commVec,Q]     = community_louvain(conMat,resolution_param,commVec, mode);
         end
      case 'LeidenCPM'
         % handle correlation matrices
         conMat(conMat<0) = 0;
         for k = 1:maxIter
            [commVec,Q]  = communityDetectionLeidenViaPython(conMat,resolution_param, commVec, 'CPM', disableRandomSeed);
         end
      case 'LeidenModularity'
         for k = 1:maxIter
            [commVec,Q]  = communityDetectionLeidenViaPython(conMat,resolution_param, commVec, 'Modularity', disableRandomSeed);
         end
      otherwise
         error('Unknown community detection method!');
   end
   
   %% sort connectivity matrix for all communities
   % ensure that community vector only contains elements of [1, length(commVec)]
   commVecCopy    = commVec;
   for commNumber = 1:length(commVec)
      if ~isempty(commVecCopy)
         arg = commVec==min(commVecCopy);
         commVec(arg)       = commNumber;
         commVecCopy(commVecCopy==min(commVecCopy))   = [];
      end
   end
   numberOfCommsFull  = length(unique(commVec));

   % determine size of communities and new indices of neuron recordings
   sortingOrderFull  = zeros(length(conMat),1);
   commSizesFull     = zeros(max(commVec),1);
   counter           = 1;
   for commNumber = 1:numberOfCommsFull
      for neuronNumber = 1:length(conMat)
         if commVec(neuronNumber)==commNumber
            sortingOrderFull(counter)  = neuronNumber;
            counter                    = counter + 1;
            commSizesFull(commNumber)  = commSizesFull(commNumber) + 1;
         end
      end
   end

   % reorder connectivity matrix and coordinates
   sortedConMatFull = conMat(sortingOrderFull,sortingOrderFull);
   sortedCoordsFull = coords(:,sortingOrderFull);

   %% sort connectivity matrix for community sizes >1
   % remove single neurons as communities
   numbers                       = 1:max(commVec);
   removedNeurons                = find(ismember(commVec,numbers(accumarray(commVec(:), 1) == 1)));
   commVecNew                    = commVec;
   commVecNew(removedNeurons)    = [];
   numberOfComms                 = length(unique(commVecNew));
   conMatNew                     = conMat;
   conMatNew(:,removedNeurons)   = [];
   conMatNew(removedNeurons,:)   = [];
   coordsNew                     = coords;
   coordsNew(:,removedNeurons)   = [];

   % determine size of communities and new indices of neuron recordings
   sortingOrder   = zeros(length(conMat)-length(removedNeurons),1);
   commSizes   = zeros(max(commVecNew),1);
   counter     = 1;
   for commNumber = 1:numberOfComms
      for neuronNumber = 1:length(conMat)-length(removedNeurons)
         if commVecNew(neuronNumber)==commNumber
            sortingOrder(counter)    = neuronNumber;
            counter               = counter + 1;
            commSizes(commNumber) = commSizes(commNumber) + 1;
         end
      end
   end

   % reorder connectivity matrix and coordinates
   sortedConMat = conMatNew(sortingOrder,sortingOrder);
   sortedCoords = coordsNew(:,sortingOrder);

   % set different output if mode of analysis is 'simulation'
   analysisMode = split(nameOfRecording,'-');
   if strcmp(analysisMode{1},'SimulatedGrowth')
      commSizes    = commSizesFull;
      sortingOrder = sortingOrderFull;
   end
   
   %% plot results
   if showCommunities
      figure
      colormap(slanCM('viridis'))
      imagesc(sortedConMatFull)
      cbh = colorbar; 
      cbh.Ticks = [0,1];
      set(gca, 'FontName', 'Arial')
      xlabel('Neurons');
      ylabel('Neurons');
      if length(sortingOrder)>=1
         xticks([1,length(sortingOrder)]);
         yticks([1,length(sortingOrder)]);
      else
         xticks([]);
         yticks([]);
      end
      %title(['Community-Detection of ', nameOfRecording, ', ', num2str(max(commVec)), ' groups, Q=', num2str(Q)])
      hold on;
      % draw rectangles to highlight communities
      startCoord = 0.5; 
      for commNumber=1:max(commVecNew)
         if commSizes(commNumber)>1
            rectangle('Position', [startCoord startCoord commSizes(commNumber) commSizes(commNumber)],'EdgeColor', 'red', 'LineWidth', 2);
         end
         startCoord = startCoord + commSizes(commNumber);
      end
      hold off;
      strings = split(nameOfRecording, '-');
      nameOfAnimal = strings{1};
      filePath = fullfile(['results/',nameOfAnimal,'/',nameOfRecording,'_comDet.pdf']);
      exportgraphics(gca,filePath);
   end

   if showGraphs
      % prepare graph data
      sortedConMatFull                                                     = sortedConMatFull - eye(size(sortedConMatFull));
      sortedConMatFull(sortedConMatFull<0*max(sortedConMatFull,[],'all'))  = 0;
      % create graph
      figure;
      hold on;
      % plot connections within and between communities
      for start = 1:length(sortedCoordsFull)
         for target = 1:length(sortedCoordsFull)
            if sortedConMatFull(start,target) > 0%0.75
               color = [0.3 0 0 0.5*sortedConMatFull(start,target).^2];
               width = 2*sortedConMatFull(start,target).^2;
               line(sortedCoordsFull(1,[start,target]),sortedCoordsFull(2,[start,target]),'Color',color, 'LineWidth',width);
            end
         end
      end
      % plot position of communities
      C = {[1 0 0], [0 0 1], 	[0 1 0], [0 1 1], [1 0 1], [1 1 0], [0 0.4470 0.7410], [0.6350 0.0780 0.1840], [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330], [0.4940 0.1840 0.5560], [0.9290 0.6940 0.1250], [0.8500 0.3250 0.0980]};
      neuronCounter = 0;
      for commNumber=1:max(commVec)
         commSize = commSizesFull(commNumber);
         if commNumber == 1
         scatter(sortedCoordsFull(1,neuronCounter+1:neuronCounter+commSize),sortedCoordsFull(2,neuronCounter+1:neuronCounter+commSize),50,C{commNumber},'filled');
         else
            scatter(sortedCoordsFull(1,neuronCounter+1:neuronCounter+commSize),sortedCoordsFull(2,neuronCounter+1:neuronCounter+commSize),20,C{commNumber},'filled');
         end
         neuronCounter = neuronCounter + commSize;
      end

      set(gca, 'FontName', 'Arial')
      xlabel('x in um');
      ylabel('y in um');
      if length(sortingOrderFull)>=1
         xticks([round(min(sortedCoordsFull(1,:))),round(max(sortedCoordsFull(1,:)))]);
         yticks([round(min(sortedCoordsFull(2,:))),round(max(sortedCoordsFull(2,:)))]);
      else
         xticks([]);
         yticks([]);
      end
%       xticks([]);
%       yticks([]);
      set(gca, 'YDir','reverse')
%       axis off
      % export figures as pdf
      strings = split(nameOfRecording, '-');
      nameOfAnimal = strings{1};
      filePath = fullfile(['results/',nameOfAnimal,'/',nameOfRecording,'_network.pdf']);
      exportgraphics(gca,filePath, 'ContentType', 'vector');
   end

end