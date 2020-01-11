from collections import defaultdict
from itertools import accumulate, islice
from operator import itemgetter

import networkx as nx
from networkx.algorithms.community.community_utils import is_partition
from networkx.utils import not_implemented_for, py_random_state

import matplotlib.pyplot as plt


def compute_delta(G, A, B, weight):
    """
    Helper to compute initial swap deltas for a pass.

    :param G: graph
    :param A:
    :param B:
    :param weight: Edge data key to use as weight. If None, the weights are all set to one.
    :return:
    """
    delta = defaultdict(float)
    for u, v, d in G.edges(data=True):
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


def update_delta(delta, G, A, B, u, v, weight):
    """
    Helper to update swap deltas during single pass.

    :param delta:
    :param G: graph
    :param A:
    :param B:
    :param u:
    :param v:
    :param weight: Edge data key to use as weight. If None, the weights are all set to one.
    :return:
    """
    for _, nbr, d in G.edges(u, data=True):
        w = d.get(weight, 1)
        if nbr in A:
            delta[nbr] += 2 * w
        if nbr in B:
            delta[nbr] -= 2 * w
    for _, nbr, d in G.edges(v, data=True):
        w = d.get(weight, 1)
        if nbr in A:
            delta[nbr] -= 2 * w
        if nbr in B:
            delta[nbr] += 2 * w
    return delta


def kernighan_lin_pass(G, A, B, weight):
    """
    Do a single iteration of Kernighan–Lin algorithm.

    :param G: graph
    :param A:
    :param B:
    :param weight: Edge data key to use as weight. If None, the weights are all set to one.
    :return: list of  (g_i,u_i,v_i) for i node pairs u_i,v_i.
    """
    multigraph = G.is_multigraph()
    delta = compute_delta(G, A, B, weight)
    swapped = set()
    gains = []
    while len(swapped) < len(G):
        gain = []
        for u in A - swapped:
            for v in B - swapped:
                try:
                    if multigraph:
                        w = sum(d.get(weight, 1) for d in G[u][v].values())
                    else:
                        w = G[u][v].get(weight, 1)
                except KeyError:
                    w = 0
                gain.append((delta[u] + delta[v] - 2 * w, u, v))
        if len(gain) == 0:
            break
        maxg, u, v = max(gain, key=itemgetter(0))
        swapped |= {u, v}
        gains.append((maxg, u, v))
        delta = update_delta(delta, G, A - swapped, B - swapped, u, v, weight)
    return gains


@py_random_state(4)
@not_implemented_for('directed')
def kernighan_lin_bisection(G, partition=None, max_iter=10, weight='weight', seed=None):
    """
    Partition a graph into two blocks using the Kernighan–Lin algorithm.

    This algorithm paritions a network into two sets by iteratively swapping pairs of nodes to reduce the edge cut
    between the two sets.

    :param G: graph
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
        nodes = list(G)
        seed.shuffle(nodes)
        h = len(nodes) // 2
        partition = (nodes[:h], nodes[h:])
    # Make a copy of the partition as a pair of sets.
    try:
        A, B = set(partition[0]), set(partition[1])
    except:
        raise ValueError('partition must be two sets')
    if not is_partition(G, (A, B)):
        raise nx.NetworkXError('partition invalid')
    for i in range(max_iter):
        # `gains` is a list of triples of the form (g, u, v) for each
        # node pair (u, v), where `g` is the gain of that node pair.
        gains = kernighan_lin_pass(G, A, B, weight)
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


if __name__ == '__main__':
    G = nx.read_edgelist("../dataset/data.txt", create_using=nx.Graph(), nodetype=int)

    A, B = kernighan_lin_bisection(G)
    print("Partition A: {}".format(A))
    print("Partition B: {}".format(B))
