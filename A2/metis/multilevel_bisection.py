import random
import subprocess
import time
import networkx as nx
import nxmetis
import pydot


def create_cluster(name, Graph, partition):
    c = pydot.Cluster(name)  # cluster name
    for i in range(len(partition) - 1):
        e = pydot.Edge(pydot.Node(partition[i]), pydot.Node(partition[i + 1]))  # new edge
        c.add_edge(e)

    Graph.add_subgraph(c)


# create graph
n = 10
Graph = nx.erdos_renyi_graph(n, 0.7)

for u, v in Graph.edges():
    if u != v:
        Graph[u][v]['label'] = random.randrange(1, 20)

start = time.time()

# multilevel bisection algorithm
Graph.graph['edge_weight_attr'] = 'weight'  # otherwise metis will not recognize a weighted graph
nnodes, partition = nxmetis.partition(Graph, 2, recursive=True)
partition_A = list(map(int, partition[0]))
partition_B = list(map(int, partition[1]))

# print graph partition
print("Partition A: {}".format(set(partition_A)))
print("Partition B: {}".format(set(partition_B)))

# draw graph partition
newGraph = nx.drawing.nx_pydot.to_pydot(Graph)  # convert nx.Graph to dot format
create_cluster('A', newGraph, partition_A)
create_cluster('B', newGraph, partition_B)
newGraph.write('mb.dot')
subprocess.call(["dot", "-Tpng", "mb.dot", "-o", "mb.png"])

end = time.time()
print("Elapsed time: %.4f seconds." % (end - start))
