package com.company;

import java.util.ArrayList;
import java.util.Collections;

public class Main {

    public static void main(String[] args) {
        int acierto = 0;
        int NUMVALORES = 20;
        int MITAD = NUMVALORES / 2;
        int NINTENTOS = 1000000;
        ArrayList<Integer> ls = new ArrayList<>();
        int i, j;
        for (i = 0; i < NUMVALORES; i++) {
            ls.add(i);
        }
        for (j = 0; j < NINTENTOS; j++) {
            Collections.shuffle(ls);
            // if (ls.get(0) >= MITAD || ls.get(1) >= MITAD) { // k = 2
            System.out.println(ls.get(0));
            if (ls.get(0) >= MITAD || ls.get(1) >= MITAD || ls.get(3) >= MITAD || ls.get(4) >= MITAD) { // k = 4
                acierto++;
            }
            System.out.printf("intentos: %d, aciertos: %d%n", j, acierto);
        }
        System.out.println("probabilidad de error: " + (NINTENTOS - 1. * acierto) / NINTENTOS);
    }
}
