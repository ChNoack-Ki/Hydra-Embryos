% model parameters

%% biological parameters
% calcium imaging parameters
alpha         = 1e3*10;                                  % calcium-concentration-to-current conversion factor
tau           = 0.79;                                    % calcium decay rate
etaCaInf      = 50e-9;                                   % resting calcium concentration

%% electrical parameters
% calcium channel resistance and integrator circuit for calcium concentration
CI                = 1/alpha;
RI                = tau/CI;
ICaMin            = 0.233e-12;
GCa1              = 4.6e-9;
ECa               = 111e-3;
UCa1              = -1e-3;
UCa2              = 12e-3;
etaCaInfCorrected = etaCaInf - RI*ICaMin;
% Morris-Lecar model
C                 = 2e-6*4+5e-6*rand(1,nN);
GL                = 2e-5;
EL                = -70e-3;
GNa1              = 20e-3;
ENa               = 50e-3;
UNa1              = 5e-3;
UNa2              = 13e-3;
GK1               = 20e-3;
EK                = -90e-3;
UK1               = 0e-3;
UK2               = 10e-3;
FK                = 6.67;
% memristors as gap junctions
WElmin            = 1e-9;
WElmax            = 1e-5;
SEl               = 0.19*2;
SElret            = 0.19*1e-2;
UElp              = 50e-3;
UEln              = -150e-3;

%% wave digital parameters
% Morris-Lecar model
RC       = T./(2*C);
RM       = 1./(0.5*(GK1 + GNa1 + GL));
REl      = 1./WElmax;
Rp       = [RC;RM*ones(1,nN);REl*ones(1,nN)];
gamma    = 2./sum(1./Rp)./Rp;
GEl      = eye(nN)/REl;
% integrator circuit for calcium concentration
RCI      = T./(2*CI);
R        = RI;
RpI      = [RCI;R];
RpIn     = 1./(sum(1./RpI)); 
gammaI   = [RpIn./RpI; 1];