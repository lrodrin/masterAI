# Spark Streaming

## Conteo de palabras en stream

Para ejecutar la pipeline, primero se tiene que abrir un servidor en el que enviar datos. Para ello ejecutar:

```bash
$ nc -l 19999
```

Compilar la aplicación y ejecutar. Comprobar que `execute.sh` la pipeline se ejecutará a un cluster local. Para hacerlo en un cluster remoto, solo habría que cambiar el argumento master.

```bash
$ sbt clean assembly
$ chmod +x execute.sh 
$ ./execute.sh es.dmr.uimp.spark.streaming.NetworkWordCount localhost 19999 
```

## Conteo total de palabras

Esta pipeline funciona igual que el ejemplo anterior, solo se tiene que cambiar la clase `NetworkWordCount` por `StatefulNetworkWordCount`.

```bash
$ nc -l 19999
$ sbt clean assembly
$ ./execute.sh es.dmr.uimp.spark.streaming.StatefulNetworkWordCount localhost 19999 
```
