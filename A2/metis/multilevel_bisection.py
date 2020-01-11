import networkx as nx
import nxmetis
import csv
import matplotlib.pyplot as plt

G = nx.Graph()
reader = csv.reader(open('../dataset/data.csv'))
for row in reader:
    G.add_edge(row[0], row[1], weight=row[2])

print(nxmetis.partition(G, 2, recursive=True))
nx.draw(G, with_labels=True)
plt.show()
