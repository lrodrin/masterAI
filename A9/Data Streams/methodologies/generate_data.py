import random

N = int(input("Enter N value: "))
x = int(input("Enter x value (1 <= x <= N): "))

if isinstance(N, int) and isinstance(x, int):  # check if N and x are integers
    if 1 <= x <= N:  # check if 1 <= x <= N
        permutations = random.sample(range(1, N+1), N)  # generate permutations from 1 to N
        permutations.remove(x)  # remove x from permutations
        print(permutations)
else:
    raise Exception("N and x must be integer values")
