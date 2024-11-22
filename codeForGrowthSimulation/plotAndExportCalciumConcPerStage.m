% plots for calcium activity
samplesPerPeriod  = simulatedData{3,iter};
animalData        = simulatedData{1,iter};
lastStage         = animalData{length(animalData)};
nN                = lastStage{4};

%% 2D-Surface plot for complete data
% create array for complete calcium data
stageData   = animalData{1};
etaCa       = cell(1,numberOfStages);
t           = cell(1,numberOfStages);
for stage = 1:4
   stageData      = animalData{stage};
   etaStage       = stageData{1};
   [rows,cols]    = size(etaStage);
   if cols<30
      etaStage(:,cols+1:30) = 4.82429655269130e-08;
   end
   etaCa{stage}   = etaStage;
   t{stage}       = stageData{2};
end
etaCa = cell2mat(etaCa');
t     = cell2mat(t);

% create plot
% n              = nN:-1:1;
% [tMesh,nMesh]  = meshgrid(t, n);
% figure;
% h(1)           = surface(tMesh',nMesh',etaCa*1e9, 'EdgeColor', 'None'); 
% colormap(slanCM('viridis'))
% title('Calcium Concentration of Neuron Bodys')
% xlabel('$t$ in s')
% ylabel('Neuron Indices')
% c2                = colorbar;
% c2.Label.String   = '$\eta$ in nM';

figure
imagesc(etaCa'*1e9);
colormap(slanCM('viridis'))
title('Calcium Concentration of Neuron Bodys')
xlabel('$t$ in s')
ylabel('Neuron Indices')
c2                = colorbar;
c2.Label.String   = '$\eta$ in nM';

% export figure
nameOfAnimal = 'simulatedGrowth';
filePath = fullfile(['results/',nameOfAnimal,'/tikz/activity/',nameOfAnimal,'_completeActivity.tex']);
cleanfigure('targetResolution',10)
matlab2tikz(filePath);

%% 2D-Surface plot
for k = 1:numberOfStages
   % stage data
   stageData      = animalData{k};
   etaCa_logging  = stageData{1};
   t              = stageData{2};
   nActiveNeurons = stageData{4};
%    n              = nN:-1:nN-nActiveNeurons+1;%
   n = 1:nActiveNeurons;
   commSizes      = allCommSizes{k};
   sortingOrder   = sortingOrders{k};
   % resort data with respect to detected communities
   eta = etaCa_logging(:,n);
%    eta   = etaCa_logging(:,n(sortingOrders{k}));
   tPlot = t;
%    eta   = etaCa_logging(1:k*samplesPerPeriod + (k-1)*samplesPerPause,n(sortingOrders{k}));
%    tPlot = t(1:k*samplesPerPeriod + (k-1)*samplesPerPause);
   % create plot
   [tMesh,nMesh] = meshgrid(tPlot, n);
   figure;
   set(gca, 'FontName', 'Arial')
   colormap(slanCM('viridis'))
   %h(1) = surface(tMesh',nMesh',eta*1e9, 'EdgeColor', 'None', 'FaceAlpha', 1);   % calcium concentration
   imagesc(eta'*1e9)
%    title('Calcium Concentration of Neuron Bodys')
   xlabel('t in s')
   ylabel('Neurons')
   ylim([1-0.1,nActiveNeurons+0.1])
   yticks([1,nActiveNeurons])
   xticks([1,500])
   xticklabels({tPlot(1),ceil(tPlot(end))});
   c2                = colorbar;
   c2.Label.String   = '\eta in nM';
   c2.Position       = c2.Position + [0.05,0,0,0];
   ax                = gca;
   ax.Position       = ax.Position - [0 0 .1 0];
%    set(c2,'Position',pos+[0.25,0,0,0]);
%    hold on;
   % highlight communities: draw rectangles and add neurons indices as text
%    startCoord     = 1;
%    for commNumber=1:numberOfComms(k)
%       txt = string((flip(sortingOrder(startCoord:startCoord+commSizes(commNumber)-1))));
%       if commNumber==numberOfComms(k)
%          rectangle('Position', [tPlot(1) startCoord tPlot(end)-tPlot(1) commSizes(commNumber)-1],'EdgeColor', 'red', 'LineWidth', 2);
%       else
%          rectangle('Position', [tPlot(1) startCoord tPlot(end)-tPlot(1) commSizes(commNumber)],'EdgeColor', 'red', 'LineWidth', 2);
%       end
%       startCoord = startCoord + commSizes(commNumber);
%       uistack(h(1),'bottom');
%    end
%    hold off;

   nameOfAnimal = 'simulatedGrowth';
   nameOfRecording = [nameOfAnimal,'-',num2str(k)];
   filePath = fullfile(['results/',nameOfAnimal,'/',nameOfRecording,'activity.pdf']);
   exportgraphics(gca,filePath);
end