import igraph as ig
import leidenalg as la
import numpy as np
  
# create graph from adjacency matrix
G = ig.Graph.Weighted_Adjacency(A.tolist())

# create resolution profile
optimiser = la.Optimiser()
optimiser.consider_comms=la.ALL_COMMS;
profile = optimiser.resolution_profile(G, la.CPMVertexPartition,
                                       resolution_range=(0,1));

# split graph into subgraphs with negative and positive weights
G_pos = G.subgraph_edges(G.es.select(weight_gt = 0), delete_vertices=False);
G_neg = G.subgraph_edges(G.es.select(weight_lt = 0), delete_vertices=False);
G_neg.es['weight'] = [-w for w in G_neg.es['weight']];

# find partition of subgraphs
if disableRandomSeed==1:
    part_pos = la.ModularityVertexPartition(G_pos, weights='weight', seed=1);
    part_neg = la.ModularityVertexPartition(G_neg, weights='weight', seed=1);
else:
    part_pos = la.ModularityVertexPartition(G_pos, weights='weight');
    part_neg = la.ModularityVertexPartition(G_neg, weights='weight');
    
# optimize partitions

diff = optimiser.optimise_partition_multiplex(
  [part_pos, part_neg],
  layer_weights=[1,-1]);

# plot results
ig.plot(part_pos)

# set output
output = [part_pos, profile];
