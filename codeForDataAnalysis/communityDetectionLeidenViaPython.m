function [commVec,Q] = communityDetectionLeidenViaPython(A, resolution_param, commVec, mode, disableRandomSeed)
% input arguments:
%  - A                  : adjacency matrix
%  - resolution_param   : resolution parameter       
%  - commVec            : initial community indices of nodes as vector
%  - mode               : choose between CPM measure and modularity measure
%  - disableRandomSeed  : disable the randomness of the community detection 
% 
% output arguments:
%  - commVec            : community indices of nodes as vector
%  - Q                  : quality score (modularity)
   
  if disableRandomSeed==true
      disableSeed = 1;
  elseif disableRandomSeed==false
      disableSeed = 0;
  else
      error('Only true or false allowed!')
  end

  commVec = uint8(commVec-1);
  switch mode
     case 'CPM'
         partition = pyrunfile("LeidenAlgorithmCPM.py","output",A=A,resolution_param=resolution_param, p0=commVec, disableRandomSeed = disableSeed);
     case 'Modularity'
        output    = pyrunfile("LeidenAlgorithmModularity.py","output",A=A,resolution_param=resolution_param, p0=commVec, disableRandomSeed = disableSeed);
        output    = cell(output);
        partition = output{1};
        resProfil = output{2};   % resolution profile, for information on the influence of different resolution parameters
     otherwise
        warning('Unknown mode for Leiden algorithm!');
  end

  % get community indices
  commVec = partition.membership;
  Q       = partition.q;
  commVec = cell(commVec);
  commVec  = cellfun(@double,commVec) +1;

end