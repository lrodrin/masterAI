def missingNumber(sequence):
    """
    """
    sequence.sort()
    last = len(sequence)
    first = 0
    while first < last:
        average = first + (last - first) // 2
        if sequence[average] > average:
            last = average
        else:
            first = average + 1
    return first


print(missingNumber([5, 3, 1, 7, 8, 0, 9, 2, 4]))

# The O(n) solutions are easy , but this is a common interview question and often we look for O(log n) time solution.
# Here is the javascript code. It's basically a modified binary search.
