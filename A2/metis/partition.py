import networkx as nx
import nxmetis

G1 = nx.complete_graph(10)
print(nxmetis.partition(G1, 2))

import csv

G2 = nx.Graph()

reader = csv.reader(open('graph.csv'))
for row in reader:
    G2.add_edge(row[0], row[1], weight=row[2])

# print(nxmetis.partition(G2, 2))
# print(nxmetis.partition(G2, 2, recursive=True))

# import matplotlib.pyplot as plt
#
# nx.draw(G2, with_labels=True)
# plt.show()
