# Spark Streaming

## Conteo de palabras en stream

Para ejecutar el trabajo, primero se tiene que abrir un servidor en el que enviar datos. Para ello ejecutar:

```bash
$ nc -l 19999
```

Compilar la aplicación y ejecutar. Comprobar que `execute.sh` envia el trabajo a un cluster local. Para enviar este trabajo a un cluster remoto, solo habría que 
cambiar el argumento master.

```bash
$ sbt clean assembly
$ chmod +x execute.sh 
$ ./execute.sh 
```
