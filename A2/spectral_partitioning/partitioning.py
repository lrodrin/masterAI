import subprocess

import numpy as np


def import_nodes(nodes_file):
    """
    Import the nodes from the file
    """

    edges = list()
    number_nodes = 0

    # Open the file
    with open(nodes_file, "r") as datafile:
        for line in datafile:
            node1, node2 = line.split()
            node1 = int(node1)
            node2 = int(node2)
            edges.append({node1, node2})
            number_nodes = max(number_nodes, node1, node2)

    number_nodes += 1  # We only had the maximum index of the nodes
    print("Imported {} nodes with {} edges from {}".format(number_nodes, len(edges), nodes_file))

    # Initiate empty matrix
    adjacency_matrix = np.zeros((number_nodes, number_nodes))

    # Fill the matrix
    for node1, node2 in edges:
        # The adjancency matrix is symmetric
        adjacency_matrix[node1][node2] = 1
        adjacency_matrix[node2][node1] = 1

    return number_nodes, edges, adjacency_matrix


def degree_nodes(adjacency_matrix, number_nodes):
    """
    Compute the degree of each node
    Returns the vector of degrees
    """

    d = []
    for i in range(number_nodes):
        d.append(sum([adjacency_matrix[i][j] for j in range(number_nodes)]))

    return d


def print_graph(edges, partition, outputfile):
    """
    Writes a .gv file to use with dot
    """
    with open("graph.gv", "w") as gv:
        gv.write("strict graph communities {")

        for node, community in enumerate(partition):
            gv.write("node{} [color={}];".format(node, "red" if community else "blue"))

        for node1, node2 in edges:
            gv.write("node{} -- node{};".format(node1, node2))

        gv.write("}")
        gv.close()

    subprocess.call(["dot", "-Tpng", "graph.gv", "-o", outputfile])
    print("Wrote {} with the two communities.".format(outputfile))


def algorithm():
    """
    The Spectral Partitioning Algorithm
    """

    print("Computing Adjacency Matrix...")

    number_nodes, edges, adjacency_matrix = import_nodes(args.nodes_file)
    print("Adjacency matrix:\n", adjacency_matrix)

    print("Computing the degree of each node...")
    degrees = degree_nodes(adjacency_matrix, number_nodes)
    print("Degrees: ", degrees)

    print("Computing the Laplacian matrix...")
    laplacian_matrix = np.diag(degrees) - adjacency_matrix
    print("Laplacian matrix:\n", laplacian_matrix)

    print("Computing the eigenvectors and eigenvalues...")
    eigenvalues, eigenvectors = np.linalg.eigh(laplacian_matrix)

    print("Found eigenvalues: ", eigenvalues)

    # Index of the second eigenvalue
    index_fnzev = np.argsort(eigenvalues)[1]

    print("Eigenvector for #{} eigenvalue ({}): ".format(
        index_fnzev, eigenvalues[index_fnzev]), eigenvectors[:, index_fnzev])

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
    print("Partition computed: nbA={} nbB={} (total {}), {} edges in between".format(
        len(nodes_in_A),
        len(nodes_in_B),
        number_nodes,
        len(edges_in_between),
    ))

    return number_nodes, edges, partition


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description="Compute the partition of a "
                                                 "graph using the Spectral Partition Algorithm.")

    parser.add_argument('--nodes-file', '-f', help='the file containing the nodes',
                        default='demo_nodes.txt')
    parser.add_argument('--output-file', '-o', help='the filename of the'
                                                    ' communities PNG graph to be written')

    args = parser.parse_args()

    # Run the algorithm
    number_nodes, edges, partition = algorithm()

    if args.output_file:
        # Print the graph
        print_graph(edges, partition, outputfile=args.output_file)
