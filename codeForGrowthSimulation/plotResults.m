% plots for membrane potential and calcium activity

%% 1D-Signal plot
figure;
subplot(3,1,1)
plot(t,u_logging*1e3)
title('Membrane Potential of Neuron Bodys')
xlabel('$t$ in s')
ylabel('$u$ in mV')
legend('N1', 'N2', 'N3', 'N4')
subplot(3,1,2)
plot(t,etaCa_logging*1e9)
title('Calcium Concentration of Neuron Bodys')
xlabel('$t$ in s')
ylabel('$\eta$ in nM')
subplot(3,1,3)
plot(t,zEl_logging)
title('Gap Junction States')
xlabel('$t$ in s')
ylabel('$z_{El}$ in S')

%% 2D-Surface plot for complete data
fig=figure;
imagesc(flipud(etaCa_logging'*1e9));
colormap(slanCM('viridis'))
title('Calcium Concentration of Neuron Bodys')
xlabel('$t$ in s')
ylabel('Neuron Indices')
c2                = colorbar;
c2.Label.String   = '$\eta$ in nM';

% export figure
nameOfAnimal = 'simulatedGrowth';
filePath = fullfile(['results/',nameOfAnimal,'/',nameOfAnimal,'_completeActivity.tex']);
cleanfigure('targetResolution',10)
matlab2tikz(filePath);