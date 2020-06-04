import random
import subprocess
import time
import networkx as nx
import numpy as np
import pydot


def import_nodes(G, n):
    """
    Import the Graph from the datafile specified by filename and create the adjacency matrix.

    :return: number of nodes, edges and adjacency_matrix
    """
    edges = list()
    adjacency_matrix = np.zeros((n, n))  # Initiate empty matrix

    # Fill the matrix
    for u, v in G.edges:
        edges.append([u, v, G[u][v]['label']])
        adjacency_matrix[u][v] = G[u][v]['label']
        adjacency_matrix[v][u] = G[u][v]['label']

    return n, edges, adjacency_matrix


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


def spectral_bisection(G, n):
    """
    The Spectral Bisection Algorithm.
    """
    nnodes, edges, adjacency_matrix = import_nodes(G, n)
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


def main(G, n):
    """
    The Main run function.
    """

    # Spectral Bisection algorithm
    partition_A, partition_B, adjacency_matrix = spectral_bisection(G, n)

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
    n = 10
    G = nx.erdos_renyi_graph(n, 0.7)

    for u, v in G.edges():
        if u != v:
            G[u][v]['label'] = random.randrange(1, 20)

    start = time.time()
    main(G, n)
    end = time.time()
    print("Elapsed time: %.4f seconds." % (end - start))
