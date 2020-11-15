import os
import psutil

from time import time

from code.exercise_one.generate_data import createInputFile


def get_process_memory():
    # return the memory usage in MB
    process = psutil.Process(os.getpid())
    return process.memory_info().rss / float(2 ** 20)


def findMissingNumber(ds):
    # data stream length
    n = len(ds)

    # sum of the first N natural numbers, 
    # that is, the sum of the natural numbers from 1 to N
    sum_total = (n + 1) * (n + 2) // 2

    # sum of all the elements of the data stream
    sum_de_ds = sum(ds)

    # subtract first N natural numbers from sum of all the elements of the data stream,
    # the result of the subtraction will be the value of the missing element
    return sum_total - sum_de_ds


if __name__ == '__main__':
    start_time = time()
    start_mem = get_process_memory()
    N = 100000
    x = 99

    # create sequence from 1 to N without x
    createInputFile(N, x)

    # find missing number
    input_ds = list(map(int, open('data.txt', 'r').read().splitlines()))
    print("Missing number: {}".format(findMissingNumber(input_ds)))

    end_time = time() - start_time
    end_mem = get_process_memory()
    print("Memory used in MB: {} \nExecution time in seconds: {:.10f}".format(end_mem - start_mem, end_time))
