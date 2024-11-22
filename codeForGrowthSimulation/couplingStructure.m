% coupling structure for population N4 of Hydra hatchlings

%% adjacency matrix and incidence matrix for point-based neurons
% adjacency matrix
nN = 30;                                            % nN: number of neuron nodes
A  = ones(nN) - eye(nN);
% incidence matrix
N  = incidenceFromAdjacency(A);
% Laplace matrix
Lp = N*N';

%% number of connections
[~,nC] = size(N);                                    % nC: number of connections via gap junctions

%% auxiliary functions

% incidence matrix from adjacency matrix
function N = incidenceFromAdjacency(A)
   n   = size(A,1);
   m   = sum(sum(A ~= 0))/2;
   N   = zeros(n,m);
   ctr = 1;
   for mu = 1:n
      for nu = mu+1:n
         if (A(mu,nu) == 0)
            continue;
         end
         N(mu, ctr) = 1;
         N(nu, ctr) = -1;
         ctr = ctr + 1;
      end
   end
end