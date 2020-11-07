# La longitud de la lista es N-1. Entonces, la suma de todos los N elementos, es decir, la suma de los números de 1 a N
# se puede calcular usando la fórmula n * (n + 1) / 2. Encontramos la suma de todos los elementos de la lista y la
# restamos de la suma de los primeros N números naturales, el resultado de la resta será el valor del elemento faltante.

def findMissingNumber(Q):
    N = len(Q)
    sum_total = (N + 1) * (N + 2) // 2
    sum_de_Q = sum(Q)
    return sum_total - sum_de_Q


Q = [10, 18, 11, 3, 6, 15, 7, 14, 2, 8, 1, 4, 16, 12, 5, 17, 13]
print(findMissingNumber(Q))
