#!/usr/bin/env python
#coding=utf-8
"""mapper.py"""

import sys

# los datos de entrada vienen por STDIN (standard input)
for line in sys.stdin:
    # quitamos espacios de principio y fin de línea
    line = line.strip()
    # partimos la línea en palabras
    words = line.split()

    for word in words:
        # se escriben los resultados del map a STDOUT (standard output);
        # lo que salga de aquí será la entrada del reducer.py
        # clave-valor separados por tabulador
        # ponemos recuento 1 en cada palabra, para luego acumular los recuentos por palabra
        print('%s\t%s' % (word, 1))
