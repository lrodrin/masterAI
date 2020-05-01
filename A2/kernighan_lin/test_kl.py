import os
import subprocess

import networkx as nx
import pydot

from kernighan_lin.kl import kernighan_lin_bisection


def create_cluster(name, Graph, partition):
    c = pydot.Cluster(name)  # cluster name
    for i in range(len(partition) - 1):
        e = pydot.Edge(pydot.Node(partition[i]), pydot.Node(partition[i + 1]))  # new edge
        c.add_edge(e)

    Graph.add_subgraph(c)


def main(Graph):
    """

    :param Graph: initial graph without the partition
    :type Graph: nx.Graph
    """

    # kernighan_lin algorithm
    partition_A, partition_B = kernighan_lin_bisection(Graph)

    # print graph partition
    print("Partition A: {}".format(partition_A))
    print("Partition B: {}".format(partition_B))

    # draw graph partition
    newGraph = nx.drawing.nx_pydot.to_pydot(Graph)  # convert nx.Graph to dot format
    create_cluster('A', newGraph, list(partition_A))
    create_cluster('B', newGraph, list(partition_B))
    newGraph.write('kl.dot')
    subprocess.call(["dot", "-Tpng", "kl.dot", "-o", "kl.png"])


if __name__ == '__main__':
    # data_edges dataset
    # G = nx.read_edgelist("../dataset/data__edges.csv", delimiter=",", data=[("weight", int)], nodetype=int)
    # main(G)

    # data_no_edges dataset
    G2 = nx.read_edgelist("../dataset/data_no_edges.csv", delimiter=",", nodetype=int)
    main(G2)
