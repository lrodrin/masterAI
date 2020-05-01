import subprocess

import networkx as nx
import csv
import nxmetis
import pydot


def create_cluster(name, Graph, partition):
    c = pydot.Cluster(name)  # cluster name
    for i in range(len(partition) - 1):
        e = pydot.Edge(pydot.Node(partition[i]), pydot.Node(partition[i + 1]))  # new edge
        c.add_edge(e)

    Graph.add_subgraph(c)


# create graph
Graph = nx.Graph()
reader = csv.reader(open('../dataset/data_no_edges.csv'))
for row in reader:
    Graph.add_edge(row[0], row[1])

# multilevel bisection algorithm
nnodes, partition = (nxmetis.partition(Graph, 2))
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
