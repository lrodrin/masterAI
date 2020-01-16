import networkx as nx
import nxmetis
import csv
import matplotlib.pyplot as plt

G = nx.Graph()
reader = csv.reader(open('../dataset/data_no_weighted_edges.csv'))
for row in reader:
    G.add_edge(row[0], row[1])

print(nxmetis.partition(G, 2))
