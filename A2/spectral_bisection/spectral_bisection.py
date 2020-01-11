import argparse

import networkx as nx
import numpy as np

from A2.draw_graphs import draw_graph_partitioned, draw_graph


def import_nodes(filename):
    """
    Import the nodes from the datafile specified by filename
    """
    edges = list()
    nnodes = 0

    # Open the file
    with open(filename, "r") as datafile:
        for line in datafile:
            node1, node2 = line.split(',')
            node1 = int(node1)
            node2 = int(node2)
            edges.append({node1, node2})
            nnodes = max(nnodes, node1, node2)

    nnodes += 1  # We only had the maximum index of the nodes
    # print("Imported {} nodes with {} edges from {}".format(nnodes, len(edges), filename))

    adjacency_matrix = np.zeros((nnodes, nnodes))  # Initiate empty matrix

    # Fill the matrix
    for node1, node2 in edges:
        # The adjancency matrix is symmetric
        adjacency_matrix[node1][node2] = 1
        adjacency_matrix[node2][node1] = 1

    return nnodes, edges, adjacency_matrix


def degree_nodes(adjacency_matrix, nnodes):
    """
    Compute the degree of each node and returns the list of degrees
    """
    d = []
    for i in range(nnodes):
        d.append(sum([adjacency_matrix[i][j] for j in range(nnodes)]))

    return d


def spectral_bisection():
    """
    The Spectral Bisection Algorithm
    """
    nnodes, edges, adjacency_matrix = import_nodes(args.nodes_file)
    # print("Adjacency matrix:\n", adjacency_matrix)

    # print("Computing the degree of each node...")
    degrees = degree_nodes(adjacency_matrix, nnodes)
    # print("Degrees: ", degrees)

    laplacian_matrix = np.diag(degrees) - adjacency_matrix
    print("Laplacian matrix:\n", laplacian_matrix)

    # print("Computing the eigenvectors and eigenvalues...")
    eigenvalues, eigenvectors = np.linalg.eigh(laplacian_matrix)
    # print("Found eigenvalues: ", eigenvalues)

    # Index of the second eigenvalue
    index_fnzev = np.argsort(eigenvalues)[1]
    # print("Eigenvector for #{} eigenvalue ({}): ".format(index_fnzev, eigenvalues[index_fnzev]),
    #       eigenvectors[:, index_fnzev])

    # Partition on the sign of the eigenvector's coordinates
    partition = [val >= 0 for val in eigenvectors[:, index_fnzev]]

    # Compute the edges in between
    nodes_in_A = [nodeA for (nodeA, nodeCommunity) in enumerate(partition) if nodeCommunity]
    nodes_in_B = [nodeB for (nodeB, nodeCommunity) in enumerate(partition) if not nodeCommunity]

    edges_in_between = []
    for edge in edges:
        node1, node2 = edge
        if node1 in nodes_in_A and node2 in nodes_in_B \
                or node1 in nodes_in_B and node2 in nodes_in_A:
            edges_in_between.append(edge)

    # Display the results
    # print("Partition computed: nnodesA={} nnodesB={} (total {}), {} edges in between".format(
    #     len(nodes_in_A),
    #     len(nodes_in_B),
    #     nnodes,
    #     len(edges_in_between),
    # ))

    return set(nodes_in_A), set(nodes_in_B)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Compute the partition of a graph using the Spectral Partition "
                                                 "Algorithm.")

    parser.add_argument('--nodes-file', '-f', help="the file containing the data",
                        default="../dataset/data_no_weighted_edges.csv")
    # parser.add_argument('--output-file', '-o', help='the filename of the communities PNG graph to be written')

    args = parser.parse_args()

    # Run the algorithm
    A, B = spectral_bisection()
    print("Partition A: {}".format(A))
    print("Partition B: {}".format(B))

    # drawing results
    G = nx.read_edgelist("../dataset/data_no_weighted_edges.csv", delimiter=",")
    draw_graph(G, False)
    draw_graph_partitioned(G, A, B)
