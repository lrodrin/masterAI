import random

from code.exercise_one.generate_data import createInputFile

N = 5000
# unordered sequence P from 1 to N
P = [n for n in random.sample(range(1, N + 1), N)]

x = 221
# create input TXT file without x
createInputFile(N, x)

# find missing x in Q
Q = open('data.txt', 'r').read().splitlines()
for n in Q:  # for each number inside Q sequence
    if int(n) in P:  # if number is in P
        P.remove(int(n))  # n is removed from P

print("Missing number: {}".format(P[0]))
