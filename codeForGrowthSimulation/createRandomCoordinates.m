function [x,y,distances] = createRandomCoordinates(nN,N)
   % initialization
   x = zeros(1,nN);
   y = zeros(1,nN);
   distances          = zeros(size(N,2),1);
   isDistanceTooSmall = ones(size(distances));
   minDistance        = 0.1;
   % check if distances between neurons are large enough
   while sum(isDistanceTooSmall)>0
      connectionsToBeCorrected = find(distances<minDistance);
      % find neuron indices to update
      connectionIdxMin = 0;
      connectionIdxMax = nN - 1;
      neuronIdx     = [];
      for k = 1:nN-1
         var = ismember(connectionIdxMin+1:connectionIdxMax,connectionsToBeCorrected);
         if sum(var)
            neuronIdx = [neuronIdx;k];
         end
         connectionIdxMin = connectionIdxMax;
         connectionIdxMax = connectionIdxMax + nN - (k+1);
      end
      % create random coordinates
      x(neuronIdx) = rand(1,length(neuronIdx));
      y(neuronIdx) = rand(1,length(neuronIdx));
      % determine distances
      counter = 1;
      for row = 1:nN
         for col = row+1:nN
            xDiff = (x(row)-x(col))^2;
            yDiff  = (y(row)-y(col))^2;
            distances(counter) = sqrt(xDiff + yDiff);
            counter            = counter + 1;
         end
      end
      % update variable for checking distances
      isDistanceTooSmall(distances>0.1) = 0;
   end
end