
%% wave digital model of Morrs-Lecar model
% solve implicit relationship
for i = 1:ni
   bp3   = gamma(1,:).*bC + gamma(2,:).*ap2 + gamma(3,:).*ap3 - ap3;
   % calculate incident wave of memristors acting as gap junctions
   u     = 1/2*(ap3 + bp3);
   v     = u*N;
   dzEl  = (1-zEl>0).*(zEl>0).*(SEl.*(v - UElp>0) + SEl.*(-v+UEln>0) - SElret);     % anti-parallel connection of two memristors
   zEl   = zEl + T/ni .* dzEl;                                                      % gap junctions state
   WEl   = WElmin + zEl.*(WElmax - WElmin);                                         % memductance of gap junctions
   What  = NModified.*WEl*NModified';
   S     = (GEl+What)\(GEl-What);                                                   % scattering matrix of resistors for gap junctions
   ap3   = bp3*S;
   % calculate reflected wave of memristive voltage source
   bp2   = gamma(1,:).*bC  + gamma(2,:).*ap2 + gamma(3,:).*ap3 - ap2;
   % calculate incident wave of memristive voltage source
   dzK   = (1/2.*(1+tanh((u-UK1)./UK2)) - zK).*FK.*cosh((u-UK1)./(2.*UK2));
   zK    = zK + T/ni .* dzK;                                  % potassium state
   WK    = zK .* GK1;                                         % potassium memductance
   GNa   = GNa1.*1/2.*(1+tanh((u-UNa1)./UNa2));               % sodium conductance
   M     = 1./(WK + GNa + GL);                                % total memristance
   rho   = (M-RM)./(M+RM);                                    % reflection coefficient
   en    = M.*(EK.*WK + ENa.*GNa + jApp + EL.*GL);               % voltage after source transformation
   ap2   = en + rho .* (bp2-en);                              % reflected wave
end

% update delay elements
ap1 = bC;
bp1 = gamma(1,:).*bC + gamma(2,:).*ap2 + gamma(3,:).*ap3 - bC;
bC  = bp1;

%% wave digital model of integrator circuit
% calculate calcium current as input signal
iCa  = -GCa1.*1/2.*(1+tanh((u-UCa1)./UCa2)).*(u-ECa);

% wave flow diagram for calculating calcium concentration
bpI3 = gammaI(1,1)*aCI + gammaI(2,1)*etaCaInfCorrected;
apI3 = 2 .* RpIn .* iCa + bpI3;
bpI1 = gammaI(1,1)*aCI + gammaI(2,1)*etaCaInfCorrected + gammaI(3,1)*apI3 - aCI;

% update delay elements
apI1 = aCI;
aCI  = bpI1;

%% log data - convert waves to voltages and currents
if sampleCounter == sampleFactor
   u_logging(loggingCounter,:)      = u;                    % membrane potentials
   etaCa_logging(loggingCounter,:)  = 1/2*(apI1 + bpI1);    % calcium concentration
   zEl_logging(loggingCounter,:)    = zEl;
   sampleCounter                    = 0;
   loggingCounter                   = loggingCounter + 1;
end