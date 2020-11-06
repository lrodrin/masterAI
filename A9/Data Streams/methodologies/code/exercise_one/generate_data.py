import random


def createInputFile(N, x):
    """
    Create TXT input file

    :param N: total number of elements in a sequence
    :param x: element to delete in a sequence
    :type N: int
    :type x: int
    """
    if isinstance(N, int) and isinstance(x, int):  # check if N and x are integers
        if 1 <= x <= N:  # check if 1 <= x <= N
            try:
                permutations = random.sample(range(1, N + 1), N)  # generate permutations from 1 to N
                permutations.remove(x)  # remove x from permutations

                # write permutations to TXT file
                with open('data.txt', 'w') as outfile:
                    outfile.write("\n".join(str(item) for item in permutations))

                outfile.close()

            except Exception as e:
                raise Exception("Cannot generate the input file, {}".format(e))
    else:
        raise Exception("N and x must be integer values")
