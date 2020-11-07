import random


def main(k):
    acierto = 0
    num_valores = 20
    mitad = num_valores / 2
    num_intentos = 1000000
    ls = list()

    for i in range(0, num_valores):
        ls.append(i)

    for j in range(0, num_intentos):
        random.shuffle(ls)
        if k == 2:
            if ls[0] >= mitad or ls[1] >= mitad:
                acierto += 1
        elif k == 4:
            if ls[0] >= mitad or ls[1] >= mitad or ls[2] >= mitad or ls[4] >= mitad:
                acierto += 1

        print("intentos: {}, aciertos: {}".format(j, acierto))

    print("probabilidad de error {}".format((num_intentos - 1. * acierto) / num_intentos))


if __name__ == '__main__':
    main(2)  # k = 2
    main(4)  # k = 4
