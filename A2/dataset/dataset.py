import subprocess

import networkx as nx

# create graph
Graph = nx.read_edgelist("../dataset/dataset.csv", delimiter=",", data=[("label", int)], nodetype=int)

# draw graph
newGraph = nx.drawing.nx_pydot.to_pydot(Graph)  # convert nx.Graph to dot format
newGraph.write('dataset.dot')
subprocess.call(["dot", "-Tpng", "dataset.dot", "-o", "dataset.png"])