# bustersAgents.py
# ----------------
# Licensing Information:  You are free to use or extend these projects for
# educational purposes provided that (1) you do not distribute or publish
# solutions, (2) you retain this notice, and (3) you provide clear
# attribution to UC Berkeley.
# 
# Attribution Information: The Pacman AI projects were developed at UC Berkeley.
# The core projects and autograders were primarily created by John DeNero
# (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# Student side autograding was added by Brad Miller, Nick Hay, and
# Pieter Abbeel (pabbeel@cs.berkeley.edu).


import util
import os
import os.path
import numpy as np
from game import Agent
from game import Directions
from keyboardAgents import KeyboardAgent
import inference
import busters

class NullGraphics:
    "Placeholder for graphics"
    def initialize(self, state, isBlue = False):
        pass
    def update(self, state):
        pass
    def pause(self):
        pass
    def draw(self, state):
        pass
    def updateDistributions(self, dist):
        pass
    def finish(self):
        pass

class KeyboardInference(inference.InferenceModule):
    """
    Basic inference module for use with the keyboard.
    """
    def initializeUniformly(self, gameState):
        "Begin with a uniform distribution over ghost positions."
        self.beliefs = util.Counter()
        for p in self.legalPositions: self.beliefs[p] = 1.0
        self.beliefs.normalize()

    def observe(self, observation, gameState):
        noisyDistance = observation
        emissionModel = busters.getObservationDistribution(noisyDistance)
        pacmanPosition = gameState.getPacmanPosition()
        allPossible = util.Counter()
        for p in self.legalPositions:
            trueDistance = util.manhattanDistance(p, pacmanPosition)
            if emissionModel[trueDistance] > 0:
                allPossible[p] = 1.0
        allPossible.normalize()
        self.beliefs = allPossible

    def elapseTime(self, gameState):
        pass

    def getBeliefDistribution(self):
        return self.beliefs


class BustersAgent:
    "An agent that tracks and displays its beliefs about ghost positions."

    def __init__( self, index = 0, inference = "ExactInference", ghostAgents = None, observeEnable = True, elapseTimeEnable = True):
        inferenceType = util.lookup(inference, globals())
        self.inferenceModules = [inferenceType(a) for a in ghostAgents]
        self.observeEnable = observeEnable
        self.elapseTimeEnable = elapseTimeEnable

    def registerInitialState(self, gameState):
        "Initializes beliefs and inference modules"
        import __main__
        self.display = __main__._display
        for inference in self.inferenceModules:
            inference.initialize(gameState)
        self.ghostBeliefs = [inf.getBeliefDistribution() for inf in self.inferenceModules]
        self.firstMove = True

    def observationFunction(self, gameState):
        "Removes the ghost states from the gameState"
        agents = gameState.data.agentStates
        gameState.data.agentStates = [agents[0]] + [None for i in range(1, len(agents))]
        return gameState

    def getAction(self, gameState):
        "Updates beliefs, then chooses an action based on updated beliefs."
        #for index, inf in enumerate(self.inferenceModules):
        #    if not self.firstMove and self.elapseTimeEnable:
        #        inf.elapseTime(gameState)
        #    self.firstMove = False
        #    if self.observeEnable:
        #        inf.observeState(gameState)
        #    self.ghostBeliefs[index] = inf.getBeliefDistribution()
        #self.display.updateDistributions(self.ghostBeliefs)
        return self.chooseAction(gameState)

    def chooseAction(self, gameState):
        "By default, a BustersAgent just stops.  This should be overridden."
        return Directions.STOP

class BustersKeyboardAgent(BustersAgent, KeyboardAgent):
    "An agent controlled by the keyboard that displays beliefs about ghost positions."

    def __init__(self, index = 0, inference = "KeyboardInference", ghostAgents = None):
        KeyboardAgent.__init__(self, index)
        BustersAgent.__init__(self, index, inference, ghostAgents)

    def getAction(self, gameState):
        return BustersAgent.getAction(self, gameState)

    def chooseAction(self, gameState):
        return KeyboardAgent.getAction(self, gameState)

from distanceCalculator import Distancer
from game import Actions
from game import Directions
import random, sys

'''Random PacMan Agent'''
class RandomPAgent(BustersAgent):

    def registerInitialState(self, gameState):
        BustersAgent.registerInitialState(self, gameState)
        self.distancer = Distancer(gameState.data.layout, False)
        
    ''' Example of counting something'''
    def countFood(self, gameState):
        food = 0
        for width in gameState.data.food:
            for height in width:
                if(height == True):
                    food = food + 1
        return food
    
    ''' Print the layout'''  
    def printGrid(self, gameState):
        table = ""
        ##print(gameState.data.layout) ## Print by terminal
        for x in range(gameState.data.layout.width):
            for y in range(gameState.data.layout.height):
                food, walls = gameState.data.food, gameState.data.layout.walls
                table = table + gameState.data._foodWallStr(food[x][y], walls[x][y]) + ","
        table = table[:-1]
        return table
        
    def chooseAction(self, gameState):
        move = Directions.STOP
        legal = gameState.getLegalActions(0) ##Legal position from the pacman
        move_random = random.randint(0, 3)
        if   ( move_random == 0 ) and Directions.WEST in legal:  move = Directions.WEST
        if   ( move_random == 1 ) and Directions.EAST in legal: move = Directions.EAST
        if   ( move_random == 2 ) and Directions.NORTH in legal:   move = Directions.NORTH
        if   ( move_random == 3 ) and Directions.SOUTH in legal: move = Directions.SOUTH
        return move
        
class GreedyBustersAgent(BustersAgent):
    "An agent that charges the closest ghost."

    def registerInitialState(self, gameState):
        "Pre-computes the distance between every two points."
        BustersAgent.registerInitialState(self, gameState)
        self.distancer = Distancer(gameState.data.layout, False)

    def chooseAction(self, gameState):
        """
        First computes the most likely position of each ghost that has
        not yet been captured, then chooses an action that brings
        Pacman closer to the closest ghost (according to mazeDistance!).

        To find the mazeDistance between any two positions, use:
          self.distancer.getDistance(pos1, pos2)

        To find the successor position of a position after an action:
          successorPosition = Actions.getSuccessor(position, action)

        livingGhostPositionDistributions, defined below, is a list of
        util.Counter objects equal to the position belief
        distributions for each of the ghosts that are still alive.  It
        is defined based on (these are implementation details about
        which you need not be concerned):

          1) gameState.getLivingGhosts(), a list of booleans, one for each
             agent, indicating whether or not the agent is alive.  Note
             that pacman is always agent 0, so the ghosts are agents 1,
             onwards (just as before).

          2) self.ghostBeliefs, the list of belief distributions for each
             of the ghosts (including ghosts that are not alive).  The
             indices into this list should be 1 less than indices into the
             gameState.getLivingGhosts() list.
        """
        pacmanPosition = gameState.getPacmanPosition()
        legal = [a for a in gameState.getLegalPacmanActions()]
        livingGhosts = gameState.getLivingGhosts()
        livingGhostPositionDistributions = \
            [beliefs for i, beliefs in enumerate(self.ghostBeliefs)
             if livingGhosts[i+1]]
        return Directions.EAST

class RLAgent(BustersAgent):

    def registerInitialState(self, gameState):
        BustersAgent.registerInitialState(self, gameState)
        self.distancer = Distancer(gameState.data.layout, False)
	###########################	INSERTA TU CODIGO AQUI  #########################################
	#
	# INSTRUCCIONES:
	# 
	# Dependiendo de las caracteristicas que hayamos seleccionado para representar los estados, 
	# tendremos un numero diferente de filas en nuestra tabla Q. Por ejemplo, imagina que hemos seleccionado
	# como caracteristicas de estado la direccion en la que se encuentra el fantasma mas cercano con respecto
	# a pacman, y si hay una pared en esa direccion. La primera caracteristica tiene 4 posibles valores: el 
	# fantasma esta encima de pacman, por debajo, a la izquierda o a la derecha. La segunda tiene solo dos: hay 
	# una pared en esa direccion o no. El numero de combinaciones posibles seria de 8 y por lo tanto tendriamos 8 estados:
	#
	# nearest_ghost_up, no_wall
	# nearest_ghost_down, no_wall
	# nearest_ghost_right, no_wall
	# nearest_ghost_left, no_wall
	# nearest_ghost_up, wall
	# nearest_ghost_down, wall
	# nearest_ghost_right, wall
	# nearest_ghost_left, wall
	#
	# Entonces, en este caso, estableceriamos que self.nRowsQTable = 8. Este es simplemente un ejemplo, 
	# y es tarea del alumno seleccionar las caracteristicas que van a tener estos estados. Para ello, se puede utilizar
	# la informacion que se imprime en printInfo. La idea es seleccionar unas caracteristicas que representen
	# perfectamente en cada momento la situacion del juego, de forma que pacman pueda decidir que accion ejecutar
	# a partir de esa informacion. Despues, hay que seleccionar unos valores adecuados para los parametros self.alpha, 
	# self.gamma y self.epsilon.
	#
	#################################################################################################
	self.nRowsQTable = 100
	self.alpha = 0
	self.gamma = 0
	self.epsilon = 1
	#################################################################################################
	self.nColumnsQTable = 4
	if os.path.isfile("qtable.txt"):
	        self.table_file = open("qtable.txt", "r+")
		self.q_table = self.readQtable()
	else:
		self.table_file = open("qtable.txt", "w")
		self.q_table = (np.zeros((self.nRowsQTable, self.nColumnsQTable))).tolist()	
		self.writeQtable()
        
    ''' Example of counting something'''
    def countFood(self, gameState):
        food = 0
        for width in gameState.data.food:
            for height in width:
                if(height == True):
                    food = food + 1
        return food

    def printInfo(self, gameState):
        # Dimensiones del mapa
        width, height = gameState.data.layout.width, gameState.data.layout.height
        print "\tWidth: ", width, " Height: ", height
        # Posicion del Pacman
        print "\tPacman position: ", gameState.getPacmanPosition()
        # Acciones legales de pacman en la posicion actual
        print "\tLegal actions: ", gameState.getLegalPacmanActions()
        # Direccion de pacman
        print "\tPacman direction: ", gameState.data.agentStates[0].getDirection()
        # Numero de fantasmas
        print "\tNumber of ghosts: ", gameState.getNumAgents() - 1
        # Fantasmas que estan vivos (el indice 0 del array que se devuelve corresponde a pacman y siempre es false)
        print "\tLiving ghosts: ", gameState.getLivingGhosts()[1:]
        # Posicion de los fantasmas
        print "\tGhosts positions: ", gameState.getGhostPositions()
        # Direciones de los fantasmas
        print "\tGhosts directions: ", [gameState.getGhostDirections().get(i) for i in range(0, gameState.getNumAgents() - 1)]
        # Distancia de manhattan a los fantasmas
        print "\tGhosts distances: ", gameState.data.ghostDistances
        # Puntos de comida restantes
        print "\tPac dots: ", gameState.getNumFood()
        # Distancia de manhattan a la comida mas cercada
        print "\tDistance nearest pac dots: ", gameState.getDistanceNearestFood()
        # Paredes del mapa
        print "\tMap Walls:  \n", gameState.getWalls()
	# Comida en el mapa
	print "\tMap Food:  \n", gameState.data.food
	# Estado terminal
	print "\tGana el juego: ", gameState.isWin()
        # Puntuacion
        print "\tScore: ", gameState.getScore()
    
    def readQtable(self):
	"Read qtable from disc"
	table = self.table_file.readlines()
        q_table = []

        for i, line in enumerate(table):
            row = line.split()
            row = [float(x) for x in row]
            q_table.append(row)

        return q_table       

    def writeQtable(self):
	"Write qtable to disc"
        self.table_file.seek(0)
        self.table_file.truncate()

        for line in self.q_table:
            for item in line:
                self.table_file.write(str(item)+" ")
            self.table_file.write("\n")

    def computePosition(self, state):
	"""
	Compute the row of the qtable for a given state.
	"""
        ###########################	INSERTA TU CODIGO AQUI  #########################################
	#
	# INSTRUCCIONES:
	#
	# Dado un estado state hay que determinar que fila de nuestra tabla Q le corresponde. Siguiendo 
	# con el ejemplo anterior, podriamos hacer que:
	#
	# nearest_ghost_up, no_wall     -> Fila 0
	# nearest_ghost_down, no_wall   -> Fila 1
	# nearest_ghost_right, no_wall  -> Fila 2
	# nearest_ghost_left, no_wall   -> Fila 3
	# nearest_ghost_up, wall        -> Fila 4
	# nearest_ghost_down, wall      -> Fila 5
	# nearest_ghost_right, wall     -> Fila 6
	# nearest_ghost_left, wall      -> Fila 7
	#
	# Como antes, este es solo un ejemplo, y la transformacion dependera del tipo de representacion
	# para los estados hayamos utilizado
	# 
	#################################################################################################
	

    def getQValue(self, state, action):

        """
          Returns Q(state,action)
          Should return 0.0 if we have never seen a state
          or the Q node value otherwise
        """
        position = self.computePosition(state)
        action_column = self.actions[action]

        return self.q_table[position][action_column]


    def computeValueFromQValues(self, state):
        """
          Returns max_action Q(state,action)
          where the max is over legal actions.  Note that if
          there are no legal actions, which is the case at the
          terminal state, you should return a value of 0.0.
        """
     	legalActions = state.getLegalActions(0)
        if len(legalActions)==0:
          return 0
        return max(self.q_table[self.computePosition(state)])

    def computeActionFromQValues(self, state):
        """
          Compute the best action to take in a state.  Note that if there
          are no legal actions, which is the case at the terminal state,
          you should return None.
        """
        legalActions = state.getLegalActions(0)
        if len(legalActions)==0:
          return None

        best_actions = [legalActions[0]]
        best_value = self.getQValue(state, legalActions[0])
        for action in legalActions:
            value = self.getQValue(state, action)
            if value == best_value:
                best_actions.append(action)
            if value > best_value:
                best_actions = [action]
                best_value = value

        return random.choice(best_actions)

    def getAction(self, state):
        """
          Compute the action to take in the current state.  With
          probability self.epsilon, we should take a random action and
          take the best policy action otherwise.  Note that if there are
          no legal actions, which is the case at the terminal state, you
          should choose None as the action.
        """
	legalActions = state.getLegalActions(0)
        action = None

        if len(legalActions) == 0:
             return action

        flip = util.flipCoin(self.epsilon)

        if flip:
		return random.choice(legalActions)
        return self.getPolicy(state)

    def getReward(self, state, nextState):
	"""
          Return a reward value based on the information of state and nextState		
        """
	###########################	INSERTA TU CODIGO AQUI  #########################################
	#
	# INSTRUCCIONES:
	#
	# Ahora mismo el refuerzo que se asigna es siempre 0, pero la idea es utilizar este refuerzo
	# para premiar o castigar a nuestro agente segun se vaya comportando. Por ejemplo, comerse a un
	# fantasma es algo positivo que debemos premiar. Es decir, si pasamos de un estado state con 5
	# fantasmas a un nextState con 4, esto es positivo porque significa que nos hemos comido un 
	# fantasma. Tambien es algo positivo si nextState.isWin() es True porque significa que nos hemos
	# comido todos los fantasmas. Teniendo en cuenta todo esto, disenya tu propia funcion de refuerzo
	# que premie el comportamiento del agente.
	#
	#################################################################################################
	reward = 0
	#################################################################################################
	return reward

    def update(self, state, action, nextState, reward):
        """
          The parent class calls this to observe a
          state = action => nextState and reward transition.
          You should do your Q-Value update here
        """
	print "Started in state:"
	self.printInfo(state)
	print "Took action: ", action
	print "Ended in state:"
	self.printInfo(nextState)
	print "Got reward: ", reward
	print "---------------------------------"
        ###########################	INSERTA TU CODIGO AQUI ##########################################
	#
	# INSTRUCCIONES:
	#
	# Debemos desarrollar este metodo siguiendo un esquema similar al de la practica 1. En este caso,
	# para determinar si nextState es terminal o no, se puede utilizar la funcion nextState.isWin().
	#
	#################################################################################################

	#################################################################################################
	if nextState.isWin():
		# If a terminal state is reached
		self.writeQtable()


    def getPolicy(self, state):
	"Return the best action in the qtable for a given state"
        return self.computeActionFromQValues(state)

    def getValue(self, state):
	"Return the highest q value for a given state"
        return self.computeValueFromQValues(state)

