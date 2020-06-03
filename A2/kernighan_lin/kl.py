import subprocess
import time

import networkx as nx

from collections import defaultdict
from itertools import accumulate, islice
from operator import itemgetter

import pydot
from networkx.algorithms.community.community_utils import is_partition
from networkx.utils import not_implemented_for, py_random_state


def compute_delta(graph, A, B, weight):
    """
    Helper to compute initial swap deltas for a pass.

    :param graph: graph
    :param A: partition A
    :param B: partition B
    :param weight: Edge data key to use as weight. If None, the weights are all set to one.
    :return:
    """
    delta = defaultdict(float)
    for u, v, d in graph.edges(data=True):
        w = d.get(weight, 1)
        if u in A:
            if v in A:
                delta[u] -= w
                delta[v] -= w
            elif v in B:
                delta[u] += w
                delta[v] += w
        elif u in B:
            if v in A:
                delta[u] += w
                delta[v] += w
            elif v in B:
                delta[u] -= w
                delta[v] -= w
    return delta


def update_delta(delta, graph, A, B, u, v, weight):
    """
    Helper to update swap deltas during single pass.

    :param delta:
    :param graph: graph
    :param A: partition A
    :param B: partition B
    :param u:
    :param v:
    :param weight: Edge data key to use as weight. If None, the weights are all set to one.
    :return:
    """
    for _, nbr, d in graph.edges(u, data=True):
        w = d.get(weight, 1)
        if nbr in A:
            delta[nbr] += 2 * w
        if nbr in B:
            delta[nbr] -= 2 * w
    for _, nbr, d in graph.edges(v, data=True):
        w = d.get(weight, 1)
        if nbr in A:
            delta[nbr] -= 2 * w
        if nbr in B:
            delta[nbr] += 2 * w
    return delta


def kernighan_lin_pass(graph, A, B, weight):
    """
    Do a single iteration of Kernighan–Lin algorithm.

    :param graph: graph
    :param A: partition A
    :param B: partition B
    :param weight: Edge data key to use as weight. If None, the weights are all set to one.
    :return: list of (g_i,u_i,v_i) for i node pairs u_i,v_i.
    """
    multigraph = graph.is_multigraph()
    delta = compute_delta(graph, A, B, weight)
    swapped = set()
    gains = []
    while len(swapped) < len(graph):
        gain = []
        for u in A - swapped:
            for v in B - swapped:
                try:
                    if multigraph:
                        w = sum(d.get(weight, 1) for d in graph[u][v].values())
                    else:
                        w = graph[u][v].get(weight, 1)
                except KeyError:
                    w = 0
                gain.append((delta[u] + delta[v] - 2 * w, u, v))
        if len(gain) == 0:
            break
        maxg, u, v = max(gain, key=itemgetter(0))
        swapped |= {u, v}
        gains.append((maxg, u, v))
        delta = update_delta(delta, graph, A - swapped, B - swapped, u, v, weight)

    return gains


@py_random_state(4)
@not_implemented_for('directed')
def kernighan_lin_bisection(graph, partition=None, max_iter=10, weight='weight', seed=None):
    """
    Partition a graph into two blocks using the Kernighan–Lin algorithm.

    This algorithm paritions a network into two sets by iteratively swapping pairs of nodes to reduce the edge cut
    between the two sets.

    :param graph: graph
    :param partition: Pair of iterables containing an initial partition. If not specified,
    a random balanced partition is used.
    :param max_iter: Maximum number of times to attempt swaps to find an improvemement before giving up.
    :param weight: Edge data key to use as weight. If None, the weights are all set to one.
    :param seed: Indicator of random number generation state. Only used if partition is None.
    :type partition: tuple
    :type max_iter: int
    :type seed: integer, random_state, or None (default)
    :returns: A pair of sets of nodes representing the bipartition.
    :rtype: tuple
    :raises: NetworkXError if partition is not a valid partition of the nodes of the graph.
    """
    # If no partition is provided, split the nodes randomly into a balanced partition.
    if partition is None:
        nodes = list(graph)
        seed.shuffle(nodes)
        h = len(nodes) // 2
        partition = (nodes[:h], nodes[h:])

    # Make a copy of the partition as a pair of sets.
    try:
        A, B = set(partition[0]), set(partition[1])
    except:
        raise ValueError('partition must be two sets')
    if not is_partition(graph, (A, B)):
        raise nx.NetworkXError('partition invalid')

    for i in range(max_iter):
        # `gains` is a list of triples of the form (g, u, v) for each
        # node pair (u, v), where `g` is the gain of that node pair.
        gains = kernighan_lin_pass(graph, A, B, weight)
        csum = list(accumulate(g for g, u, v in gains))
        max_cgain = max(csum)
        if max_cgain <= 0:
            break
        # Get the node pairs up to the index of the maximum cumulative
        # gain, and collect each `u` into `anodes` and each `v` into
        # `bnodes`, for each pair `(u, v)`.
        index = csum.index(max_cgain)
        nodesets = islice(zip(*gains[:index + 1]), 1, 3)
        anodes, bnodes = (set(s) for s in nodesets)
        A |= bnodes
        A -= anodes
        B |= anodes
        B -= bnodes

    return A, B


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
    G = nx.read_edgelist("../dataset/dataset.csv", delimiter=",", data=[("weight", int)], nodetype=int)
    start = time.time()
    main(G)
    end = time.time()
    print("Elapsed time: %.10f seconds." % (end - start))
