import igraph as ig
import leidenalg as la
import numpy as np
  
# create graph from adjacency matrix
G = ig.Graph.Weighted_Adjacency(A.tolist())

# find partition
#partition = la.find_partition(G, la.CPMVertexPartition,resolution_parameter = resolution_param, max_comm_size=20);
if disableRandomSeed==1:
    partition = la.find_partition(G, la.CPMVertexPartition,resolution_parameter = resolution_param, initial_membership = p0, seed=1);
else:
    partition = la.find_partition(G, la.CPMVertexPartition,resolution_parameter = resolution_param, initial_membership = p0);

# plot results
ig.plot(partition)

# set output arguments
output = partition;


