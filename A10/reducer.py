#!/usr/bin/env python
#coding=utf-8
"""reducer.py"""

from operator import itemgetter
import sys

current_word = None
current_count = 0
word = None

# los datos de entrada vienen por STDIN (standard input)
for line in sys.stdin:
    # quitamos espacios de principio y fin de línea
    line = line.strip()

    # cogemos la clave y valor de lo que nos envía mapper.py
    word, count = line.split('\t', 1)

    # count debe ser un entero (no una cadena)
    try:
        count = int(count)
    except ValueError:
        # si count no era un número, ignoramos la línea
        # otra opción sería parar con un error
        continue

    # Hadoop nos da los pares clave-valor ordenados por clave
    # así que podemos comprobar cuando hay cambio de palabra
    # si es la misma palabra, acumulamos el recuento
    if current_word == word:
        current_count += count
    else:
        if current_word: # ha habido cambio de palabra (y no es porque no hubiese otra antes)
            # escribimos el resultado a STDOUT
            print('%s\t%s' % (current_word, current_count))
        current_count = count
        current_word = word

# si se nos ha quedado la última, la procesamos
if current_word == word:
    print('%s\t%s' % (current_word, current_count))
