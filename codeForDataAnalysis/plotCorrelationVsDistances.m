%% correlation coefficients vs distances
maxDist     = ceil(max(distances,[],'all')/100)*100;
distStep    = 20;
distVector  = 0:distStep:maxDist-distStep;
steps       = maxDist/distStep;
means       = zeros(steps,length(stageVector));
stds        = zeros(steps,length(stageVector));
for stage = 1:length(stageVector)
   opacity = 0.2+0.1*stage;
   fig                     = figure;
   %% normal
   for step = 1:steps
      idx1              = find(distances(:,stage)<distStep*step);
      idx2              = find(distances(:,stage)>=distStep*(step-1));
      means(step,stage) = mean(corrCoeffs(intersect(idx1,idx2),stage),1,'omitnan');
      stds(step,stage)  = std(corrCoeffs(intersect(idx1,idx2),stage),1,'omitnan');
   end
   xVector                 = distVector;
   xVector(isnan(means(:,stage)))   = [];
   yMean                   = means(:,stage);
   yMean(isnan(means(:,stage)))     = [];
   yStd                    = stds(:,stage);
   yStd(isnan(stds(:,stage)))       = [];
   densitiesP              = (yMean + yStd)';
   densitiesM              = (yMean - yStd)'; 
   hold on;
   h                       = fill([xVector, fliplr(xVector)], [densitiesP, fliplr(densitiesM)], 'black','LineStyle','none');
   set(h,'facealpha',.1)
   plot(xVector,yMean, 'Color',[0 0 0]);

   %% cold
   for step = 1:steps
      idx1              = find(distancesC(:,stage)<distStep*step);
      idx2              = find(distancesC(:,stage)>=distStep*(step-1));
      means(step,stage) = mean(corrCoeffsC(intersect(idx1,idx2),stage),1,'omitnan');
      stds(step,stage)  = std(corrCoeffsC(intersect(idx1,idx2),stage),1,'omitnan');
   end
   xVector                 = distVector;
   xVector(isnan(means(:,stage)))   = [];
   yMean                   = means(:,stage);
   yMean(isnan(means(:,stage)))     = [];
   yStd                    = stds(:,stage);
   yStd(isnan(stds(:,stage)))       = [];
   densitiesP              = (yMean + yStd)';
   densitiesM              = (yMean - yStd)'; 
   h                       = fill([xVector, fliplr(xVector)], [densitiesP, fliplr(densitiesM)], 'blue','LineStyle','none');
   set(h,'facealpha',.1)
   plot(xVector,yMean, 'Color',[0 0 1]);

   %% warm
   for step = 1:steps
      idx1              = find(distancesW(:,stage)<distStep*step);
      idx2              = find(distancesW(:,stage)>=distStep*(step-1));
      means(step,stage) = mean(corrCoeffsW(intersect(idx1,idx2),stage),1,'omitnan');
      stds(step,stage)  = std(corrCoeffsW(intersect(idx1,idx2),stage),1,'omitnan');
   end
   xVector                 = distVector;
   xVector(isnan(means(:,stage)))   = [];
   yMean                   = means(:,stage);
   yMean(isnan(means(:,stage)))     = [];
   yStd                    = stds(:,stage);
   yStd(isnan(stds(:,stage)))       = [];
   densitiesP              = (yMean + yStd)';
   densitiesM              = (yMean - yStd)'; 
   h                       = fill([xVector, fliplr(xVector)], [densitiesP, fliplr(densitiesM)], 'red','LineStyle','none');
   set(h,'facealpha',.1)
   plot(xVector,yMean, 'Color',[1 0 0]);

   %% axis style and export
   xlabel('nth Time Period');
   ylabel('correlation coefficients')
   cleanfigure('targetResolution',100)
   matlab2tikz(['results/temperatureComparison/distanceAnalysis/corrVsDistance-',num2str(stage),'.tex']);
end