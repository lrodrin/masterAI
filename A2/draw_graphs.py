import matplotlib.pyplot as plt
import networkx as nx


def draw_graph(G, weighted_edges):
    pos = nx.spring_layout(G)
    if weighted_edges:
        G.edges(data=True)
        edge_labels = dict(((u, v), d["weight"]) for u, v, d in G.edges(data=True))
        nx.draw(G, pos, with_labels=True, cmap=plt.get_cmap('viridis'), font_color='white')
        nx.draw_networkx_edge_labels(G, pos, edge_labels=edge_labels)

    else:
        nx.draw(G, pos, with_labels=True, cmap=plt.get_cmap('viridis'), font_color='white')

    plt.show()


def draw_graph_partitioned(G, A, B):
    color_map = list()
    pos = nx.spring_layout(G)
    for node in G:
        if int(node) in A:
            color_map.append('#00b4d9')
        elif int(node) in B:
            color_map.append('darkblue')
    nx.draw(G, pos=pos, node_color=color_map, with_labels=True, cmap=plt.get_cmap('viridis'), font_color='white')
    plt.show()
