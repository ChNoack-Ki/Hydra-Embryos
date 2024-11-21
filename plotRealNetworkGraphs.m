% prepare graph data
coords         = animalData{k}{8};
sortedCoords   = coords(:,sortingOrder);
n              = length(coords)-1;
zEl_logging    = animalData{k}{10};
zEl_stage      = zEl_logging(end,:);


% create graph
cols = 1:n;
rows = 1:n;
cols = cols(sortingOrder);
rows = rows(sortingOrder);
fig = figure;
hold on;
counter  = 1;
for start = 1:length(coords)-2
   for target = start+1:length(coords)-1
      row = rows(start);
      col = cols(target);
      linearIdx = (row-1)*n - (row-1)*(row)/2 +col-1 -(row-1);
      if zEl_stage(linearIdx)>0.2
         opacity = 1*zEl_stage(linearIdx);
         opacity(opacity>1)=1;
         color = [0.3 0.3 0.3 opacity];
         width = 6*zEl_stage(linearIdx);
         line(coords(1,[start,target]),coords(2,[start,target]),'Color',color, 'LineWidth',width);
      end
   end
end

% plot position of communities
C = {[1 0 0], [0 0 1], 	[0 1 0], [0 1 1], [1 0 1], [1 1 0], [0 0.4470 0.7410], [0.6350 0.0780 0.1840], [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330], [0.4940 0.1840 0.5560], [0.9290 0.6940 0.1250], [0.8500 0.3250 0.0980]};
neuronCounter = 0;
for commNumber=1:max(commVec)
   commSize = commSizes(commNumber);
%    if commNumber == 1
      scatter(sortedCoords(1,neuronCounter+1:neuronCounter+commSize),sortedCoords(2,neuronCounter+1:neuronCounter+commSize),50,C{commNumber},'filled');
%    else
%       scatter(sortedCoords(1,neuronCounter+1:neuronCounter+commSize),sortedCoords(2,neuronCounter+1:neuronCounter+commSize),20,C{commNumber},'filled');
%    end
   neuronCounter = neuronCounter + commSize;
end

% set axis styles
set(gca, 'FontName', 'Arial')
fontsize(fig, 16, "points")
xlabel('x in um')
ylabel('y in um')
xmin = min(sortedCoords(1,:));
ymin = min(sortedCoords(2,:));
xmax = max(sortedCoords(1,:));
ymax = max(sortedCoords(2,:));
xlim([xmin xmax])
ylim([ymin ymax])
xticks([xmin,xmax]);
yticks([ymin,ymax]);
xticklabels({num2str(round(xmin*500)),num2str(round(xmax*500))});
yticklabels({num2str(round(ymin*500)),num2str(round(ymax*500))});
% if length(sortingOrder)>=1
%    xticks([round(min(sortedCoords(1,:))*100),round(max(sortedCoords(1,:))*100)]);
%    yticks([round(min(sortedCoords(2,:))*100),round(max(sortedCoords(2,:))*100)]);
% else
%    xticks([]);
%    yticks([]);
% end
set(gca, 'YDir','reverse')
% axis off

% export figure as pdf
strings = split(nameOfRecording, '-');
nameOfAnimal = strings{1};
filePath = fullfile(['results/',nameOfAnimal,'/',nameOfRecording,'_realNetwork.pdf']);
exportgraphics(gca,filePath, 'ContentType', 'vector');