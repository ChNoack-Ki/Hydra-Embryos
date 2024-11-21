%% 2D-plot with color-changing circles as neuron body activity
tic;
maxFrames = 2000;
coordExport = coords;
coordExport(:,1) = [];
coordExport = single(coordExport);
etaCa_logging = single(etaCa_logging);

u                    = u_logging((k-1)*samplesPerPeriod + (k-1)*samplesPerPause + 1:k*samplesPerPeriod + (k-1)*samplesPerPause,:);
nActiveNeurons       = length(find(max(u)>-20e-3));
nIdx                 = nN:-1:nN-nActiveNeurons+1;

% record frames as video
v                 = VideoWriter('networkGrowth.avi');
v.FrameRate       = 20;
open(v);
f3 = figure(3);
Mov(maxFrames+1)  = struct('cdata',[],'colormap',[]);
counter           = 1;

%plot frames
counter1=0;
counter2=0;
counter3=0;
counter4=0;
minVal = min(etaCa_logging(1:end-1,:),[],'all');
for k = 1:ceil(length(t)/maxFrames):length(t)
   % determine active neurons

   scatter(coordExport(1,:),coordExport(2,:),20,etaCa_logging(k,nIdx),'filled');
   % set axis styles
   colormap(gray(256));
   set(gca, 'YDir','reverse')
   set(gca,'Color',[0 0 0])
   set(gca, 'FontName', 'Arial')
   set(f3,'Position',[0 0 400 300]);
   set(f3,'PaperSize',[4 3],'PaperPosition',[0 0 4 3]);
   fontsize(f3, 16, "points")
   xlabel('x in um')
   ylabel('y in um')
   xmin = min(coordExport(1,:));
   ymin = min(coordExport(2,:));
   xmax = max(coordExport(1,:));
   ymax = max(coordExport(2,:));
   xlim([xmin-0.1 xmax+0.1])
   ylim([ymin-0.1 ymax+0.1])
   xticks([xmin,xmax]);
   yticks([ymin,ymax]);
   xticklabels({num2str(round(xmin*500)),num2str(round(xmax*500))});
   yticklabels({num2str(round(ymin*500)),num2str(round(ymax*500))});
%    title(['Calcium Activity at t=',num2str(t(k)),'s']);
   caxis([minVal, max(etaCa_logging,[],'all')]);
   % export figures as pdf
   if t(k)>=37.32 && counter1==0
      filePath = fullfile(['results/','SimulatedGrowth','/videoSnippets/','snippet1.pdf']);
      exportgraphics(gca,filePath, 'ContentType', 'vector');
      counter1=1;
   end
   if t(k)>=39.6 && counter2==0
      filePath = fullfile(['results/','SimulatedGrowth','/videoSnippets/','snippet2.pdf']);
      exportgraphics(gca,filePath, 'ContentType', 'vector');
      counter2=1;
   end
   if t(k)>=198 && counter3==0
      filePath = fullfile(['results/','SimulatedGrowth','/videoSnippets/','snippet3.pdf']);
      exportgraphics(gca,filePath, 'ContentType', 'vector');
      counter3=1;
   end
   if t(k)>=200.16 && counter4==0
      filePath = fullfile(['results/','SimulatedGrowth','/videoSnippets/','snippet4.pdf']);
      exportgraphics(gca,filePath, 'ContentType', 'vector');
      counter4=1;
   end
   % store frame
   Mov(counter)   = getframe;
   frame          = getframe(gcf);
   writeVideo(v,frame);
   clf('reset');
   counter        = counter + 1;
end
close(v);