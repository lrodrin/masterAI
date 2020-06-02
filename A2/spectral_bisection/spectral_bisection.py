import subprocess

import networkx as nx
import numpy as np
import pydot


def import_nodes(filename):
    """
    Import the Graph from the datafile specified by filename and create the adjacency matrix.

    :param filename: filename that contains the Graph
    :type filename: str
    :return: number of nodes, edges and adjacency_matrix
    """
    edges = list()
    nnodes = 0

    with open(filename, "r") as graph:
        for line in graph:
            node1, node2, weight = line.split(',')
            node1 = int(node1)
            node2 = int(node2)
            weight = int(weight)
            edges.append([node1, node2, weight])
            nnodes = max(nnodes, node1, node2)

    nnodes += 1  # We only had the maximum index of the nodes
    adjacency_matrix = np.zeros((nnodes, nnodes))  # Initiate empty matrix

    # Fill the matrix
    for edge in edges:
        # The adjancency matrix is symmetric
        adjacency_matrix[edge[0]][edge[1]] = edge[2]
        adjacency_matrix[edge[1]][edge[0]] = edge[2]

    return nnodes, edges, adjacency_matrix


def degree_nodes(adjacency_matrix, nnodes):
    """
    Compute the degree of each node and returns the list of degrees.

    :param adjacency_matrix: adjacency matrix
    :type adjacency_matrix: ndarray
    :param nnodes: number of nodes
    :type nnodes: int
    :return: list of degrees
    """
    degrees = []
    for i in range(nnodes):
        degrees.append(sum([adjacency_matrix[i][j] for j in range(nnodes)]))

    return degrees


def spectral_bisection(filename):
    """
    The Spectral Bisection Algorithm.

    :param filename: filename that contains the Graph
    :type filename: str
    """
    nnodes, edges, adjacency_matrix = import_nodes(filename)
    # print("Adjacency matrix:\n", adjacency_matrix)

    degrees = degree_nodes(adjacency_matrix, nnodes)

    laplacian_matrix = np.diag(degrees) - adjacency_matrix
    # print("Laplacian matrix:\n", laplacian_matrix)

    eigenvalues, eigenvectors = np.linalg.eigh(laplacian_matrix)

    # Index of the second eigenvalue
    index_fnzev = np.argsort(eigenvalues)[1]

    # Partition on the sign of the eigenvector's coordinates
    partition = [val >= 0 for val in eigenvectors[:, index_fnzev]]

    # Compute the edges in between
    partition_A = [nodeA for (nodeA, nodeCommunity) in enumerate(partition) if nodeCommunity]
    partition_B = [nodeB for (nodeB, nodeCommunity) in enumerate(partition) if not nodeCommunity]

    edges_in_between = []
    for edge in edges:
        node1, node2, weight = edge
        if node1 in partition_A and node2 in partition_B \
                or node1 in partition_B and node2 in partition_A:
            edges_in_between.append(edge)

    return set(partition_A), set(partition_B), adjacency_matrix.astype(int)


def create_cluster(name, Graph, partition):
    c = pydot.Cluster(name)  # cluster name
    for i in range(len(partition) - 1):
        e = pydot.Edge(pydot.Node(partition[i]), pydot.Node(partition[i + 1]))  # new edge
        c.add_edge(e)

    Graph.add_subgraph(c)


def main(filename):
    """
    The Main run function.

    :param filename: filename that contains the Graph
    :type filename: strph without the partition
    """

    # Spectral Bisection algorithm
    partition_A, partition_B, adjacency_matrix = spectral_bisection(filename)

    # print graph partition
    print("Partition A: {}".format(partition_A))
    print("Partition B: {}".format(partition_B))

    # draw graph partition
    Graph = nx.from_numpy_matrix(adjacency_matrix)  # create nx.Graph from adjacency matrix
    newGraph = nx.drawing.nx_pydot.to_pydot(Graph)  # convert nx.Graph to dot format
    create_cluster('A', newGraph, list(partition_A))
    create_cluster('B', newGraph, list(partition_B))
    newGraph.write('sb.dot')
    subprocess.call(["dot", "-Tpng", "sb.dot", "-o", "sb.png"])


if __name__ == '__main__':
    datafile = "../dataset/dataset.csv"
    main(datafile)
