# PROJECT: GHOSTBUSTERS

Esta práctica se apoya en una plataforma que recrea el videojuego clásico [Pac-Man](http://ai.berkeley.edu/tracking.html).
Se utiliza una versión muy simplificada del juego para poder desarrollar sistemas de control automáticos y explorar 
algunas capacidades del Aprendizaje por Refuerzo. En particular, en esta práctica se aplica el algoritmo `Q-learning` 
para construir un agente que funcione de forma automática en la mayor variedad de mapas posibles. El objetivo 
del agente es maximizar la puntuación obtenida.

Ejecutar el juego mediante el siguiente comando:

```bash
python busters.py
```

Para poder ver todas las opciones de inicio disponibles hay que introducir el siguiente comando:

```bash
python busters.py --help
usage:
    USAGE:      python busters.py <options>
    EXAMPLE:    python busters.py --layout bigHunt
                  - starts an interactive game on a big board

Options:
  -h, --help            show this help message and exit
  -n GAMES, --numGames=GAMES
                        the number of GAMES to play [Default: 1]
  -l LAYOUT_FILE, --layout=LAYOUT_FILE
                        the LAYOUT_FILE from which to load the map layout
                        [Default: oneHunt]
  -p TYPE, --pacman=TYPE
                        the agent TYPE in the pacmanAgents module to use
                        [Default: BustersKeyboardAgent]
  -a AGENTARGS, --agentArgs=AGENTARGS
                        Comma seperated values sent to agent. e.g.
                        "opt1=val1,opt2,opt3=val3"
  -g TYPE, --ghosts=TYPE
                        the ghost agent TYPE in the ghostAgents module to use
                        [Default: StaticGhost]
  -q, --quietTextGraphics
                        Generate minimal output and no graphics
  -k NUMGHOSTS, --numghosts=NUMGHOSTS
                        The maximum number of ghosts to use [Default: 4]
  -z ZOOM, --zoom=ZOOM  Zoom the size of the graphics window [Default: 1.0]
  -f, --fixRandomSeed   Fixes the random seed to always play the same game
  -s, --showGhosts      Renders the ghosts in the display (cheating)
  -t FRAMETIME, --frameTime=FRAMETIME
                        Time to delay between frames; <0 means keyboard
                        [Default: 0.1]
```

Ejecutar un agente que controla a Pac-Man de forma automática. Para ello:

```bash
python busters.py -p RLAgent
```

- en lab1:
```bash
python busters.py -p RLAgent -k 1 -l lab1.lay -n 100
```

- en lab2:
```bash
python busters.py -p RLAgent -k 2 -l lab2.lay -n 100
```
  
- en lab3:
```bash
python busters.py -p RLAgent -k 3 -l lab3.lay -n 100
```