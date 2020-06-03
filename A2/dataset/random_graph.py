import random
import subprocess
import networkx as nx

n = 40
G = nx.erdos_renyi_graph(n, 0.7)

for u, v in G.edges():
    if u != v:
        G[u][v]['label'] = random.randrange(1, 20)

nx.nx_pydot.write_dot(G, "%s_dataset.dot" % n)
subprocess.call(["dot", "-Tpng", "%s_dataset.dot" % n, "-o", "%s_dataset.png" % n])