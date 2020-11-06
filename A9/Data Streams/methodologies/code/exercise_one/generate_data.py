import random


def createInputFile(N, x):
    # check if N and x are integers
    if isinstance(N, int) and isinstance(x, int):
        # check if 1 <= x <= N
        if 1 <= x <= N:
            try:
                # generate permutations from 1 to N
                permutations = random.sample(range(1, N + 1), N)

                # remove x from permutations
                permutations.remove(x)

                # write permutations to TXT file
                with open('data.txt', 'w') as outfile:
                    outfile.write("\n".join(str(item) for item in permutations))

                outfile.close()

            except Exception as e:
                raise Exception("Cannot generate the input file, {}".format(e))
    else:
        raise Exception("N and x must be integer values")
