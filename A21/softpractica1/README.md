# PROJECT 3: REINFORCEMENT LEARNING

In this project, you will implement value iteration and Q-learning. You will test your agents first on Gridworld (from class), then apply them to a simulated robot controller (Crawler) and Pacman.

## Gridworld

GridWorld in manual control mode, which uses the arrow keys:

```bash
python gridworld.py -m -n 0
```

adding noise,

```bash
python gridworld.py -m -n 0.3
```

GridWorld without manual control mode, which uses the agent type `q` and `100` iterations:

```bash
python gridworld.py -a q -k 100 -n 0
```

adding noise,

```bash
python gridworld.py -a q -k 100 -n 0.3
```
