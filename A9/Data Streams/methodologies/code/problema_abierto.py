x = 9  # elemento a eliminar en Q
P = [10, 18, 11, 3, 6, 15, 7, 14, 2, 8, 1, 9, 4, 16, 12, 5, 17, 13]  # lista desordenada del 1 al 18
Q = P.copy()
Q.remove(9)  # permutación de P a la que le falta x

for n in Q:  # para cada elemento de Q
    if n in P:  # si está en P, lo borramos
        P.remove(n)

print("Missing number: {}".format(P[0]))
