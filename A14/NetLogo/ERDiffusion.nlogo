globals
[
  num-infected
  tree-mode?            ;; true after killing uninfected nodes / links
  infectious-component  ;; the graph component that includes the infected node
]

turtles-own
[
  infected?          ;; true if agent has been infected
  infection-count    ;; the number of turtles as turtle has infected
  explored?          ;; used to find the infectious component
]


;;;;;;;;;;;;;;;;;;;;;;;
;;; Main Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;

to spread
  ;; infection can't take place while in infection tree mode
  ;; or if every agent has already been infected
  if all? infectious-component [infected?]
    [stop]
  ask turtles with [ infected? = true ]
  [
    ;; infect neighbors
    ask link-neighbors with [ infected? = false]
    [ 
      if ( random-float 1 <= infect-rate )  ;; infect with probability p
      [
        set infected? true
        show-turtle
        set color red + 1
          ;; incremement infection-count of the node doing the infection
        ask myself [set infection-count infection-count + 1]
          ;; color the link with the node doing the infection
        ask link-with myself [set color red - 1 
        set thickness 1
        show-link]
      ]
    ]

    ;; resize node so that the area is proportional to the current number of infections
    set size 2.25 * sqrt (infection-count + 1)
  ]
  
  ;; update the total number of infected agents
  set num-infected count turtles with [infected? = true]
  do-plotting
  tick
end

;; toggle infection tree mode
;; when tree-mode is on, only links responsible for contagion and infected nodes
;; are displayed. tree-mode also affects layout
to toggle-tree
  ifelse tree-mode?
  [
    ask turtles with [not infected?] [show-turtle]
    ask links with [color != red - 1] [show-link]  
    set tree-mode? false
  ]
  [
    ask turtles with [not infected?] [hide-turtle]
    ask links with [color != red - 1] [hide-link]
    set tree-mode? true
  ]
end

;; spring layout of infection tree while in tree mode
;; otherwise, layout all nodes and links
to do-layout
  ifelse tree-mode?
    [repeat 5 [layout-spring (turtles with [infected?]) (links with [color = red - 1]) 0.2 4 0.9]]
    [repeat 5 [layout-spring turtles links 0.2 4 0.9]]
end



;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to generate-topology
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  set-default-shape turtles "outlined circle"
  ;; setup small world topology
  create-turtles num-nodes
    [set explored? false]
  
  ;; generate erdos-renyi random graph
  let num-links ceiling (num-nodes * avg-degree / 2)
  while [count links < num-links]
  [
    ask one-of turtles [ create-link-with one-of other turtles ]
  ]
  
  setup
    
  ;; Layout turtles:
  layout-circle (sort turtles) 20
  repeat 15 [do-layout]
  repeat 55 [do-layout display]
end


to setup
  clear-all-plots
  reset-ticks
  set tree-mode? false

  ask links
    [set color gray + 1.5
      set thickness 0.5]  
  ask turtles
    [reset-node]
  
  ;; infect a single agent
  ask one-of turtles
  [
    set infected? true
    set size 5
    set shape "target"
    set color yellow
    explore
  ]
  set num-infected 1
  set infectious-component turtles with [explored?]
end


to reset-node
    set color gray - 0.75
    set size 2.1
    set infected? false
    set infection-count 0
    set explored? false
end


;; finds all turtles reachable from this turtle
to explore ;; turtle procedure
  if explored? [ stop ]
  set explored? true
  ask link-neighbors [ explore ]
end


to mouse-infect
  if mouse-down?
  [
    let nearest-nodes turtles with [distancexy-nowrap mouse-xcor mouse-ycor < 1.5]
    if any? nearest-nodes
    [
      ask one-of nearest-nodes
      [
        ifelse infected?
        [
          set infected? false
          set color gray - 0.75
          set num-infected num-infected - 1
        ]
        [
          set infected? true
          set color red + 1
          set num-infected num-infected + 1
        ]
      ]
      display
    ] 
  ]
end


;;;;;;;;;;;;;;;;
;;; Plotting ;;;
;;;;;;;;;;;;;;;;

to do-plotting
     ;; plot the number of infected individuals at each step
     set-current-plot "Number infected"
     set-current-plot-pen "inf"
     
     plotxy ticks num-infected
end
@#$#@#$#@
GRAPHICS-WINDOW
295
10
788
524
80
80
3.0
1
10
1
1
1
0
0
0
1
-80
80
-80
80
1
1
1
ticks
30.0

SLIDER
6
187
208
220
num-nodes
num-nodes
100
500
200
1
1
NIL
HORIZONTAL

SLIDER
6
226
209
259
avg-degree
avg-degree
0.25
5.0
1.05
0.05
1
NIL
HORIZONTAL

PLOT
4
330
281
524
Number infected
time
n
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"inf" 1.0 2 -2674135 true "" ""

BUTTON
6
47
246
80
setup with current topology
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
4
282
177
315
infect-rate
infect-rate
0
1
0.15
0.01
1
NIL
HORIZONTAL

BUTTON
7
94
123
127
spread once
spread
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
129
94
246
127
spread
spread
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
184
282
281
327
NIL
num-infected
17
1
11

BUTTON
170
134
246
167
layout
do-layout\ndisplay
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
8
134
163
167
toggle infection tree
toggle-tree
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
6
10
245
43
setup a new network
generate-topology
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This model is a SI diffusion model on a random graph. SI means that individuals can be in two states - susceptible (meaning they can get the disease) or infected (meaning that they have the disease). Once they have the disease, they stay infected and can continue to infect others.

The original documentation is placed in quotes.  
I've only really modified it to only optionally lay out the network, to have a probability 'p' of an infection spreading over an edge at each time step, and to plot the number of infected individuals over time.

Additionally, this is a diffusion model. After setting up the network with the desired number of nodes (num-nodes), it will infect one node at random. You can then step through the diffusion process either step by step (spread once) or until every node is infected (spread complete). The plot will show the number of nodes infected at each time point. The time monitor will give the current time, and in the case of the 'spread complete' option, how many steps it took until all the nodes are infected. Note that this is the SI  model - nodes are either susceptible or infected and there is no recovery. The 'p' parameter gives the probability that a an infected node will infect a neighbor at each time step.

From here on down is Uri's original, much more organized documentation:

## HOW IT WORKS

The model creates a network of the "numnodes" number of nodes with the given average degree, connecting pairs of nodes at random.  
It then infects one individual at random.

The p slider determines the probability that an infected individual will infect a susceptible contact at every time step. 

## HOW TO USE IT

"The LAYOUT? switch controls whether or not the layout procedure is run.  This procedure attempts to move the nodes around to make the structure of the network easier to see.

The PLOT? switch turns off the plots which speeds up the model.

The RESIZE-NODES button will make all of the nodes take on a size representative of their degree distribution.  If you press it again the nodes will return to equal size.

If you want the model to run faster, you can turn off the LAYOUT? and PLOT? switches and/or freeze the view (using the on/off button in the control strip over the view). The LAYOUT? switch has the greatest effect on the speed of the model.

If you have LAYOUT? switched off, and then want the network to have a more appealing layout, press the REDO-LAYOUT button which will run the layout-step procedure until you press the button again. You can press REDO-LAYOUT at any time even if you had LAYOUT? switched on and it will try to make the network easier to see."

Use the p slider to specify the probability that an infected individual will infect a susceptible contact at every time step.

View the progress of the disease diffusion on the network on the plot showing the cumulative number of individuals infected.

You can also specify the number of nodes and the average degree/node.

## THINGS TO NOTICE

Observe how varying the transmission probability p, and the average degree in the network affects the reach and speed of diffusion.

## EXTENDING THE MODEL

Try to see if you can create the SIS model - nodes recover and return to the 'susceptible state' after either a fixed time period, or with some probability at each time step. In this case you are looking for the conditions (e.g. given value of p or average degree) under which you will observe epidemics - outbreaks that affect a significant fraction of the network, vs. conditions under which the outbreak remains small and contained.

## RELATED MODELS

See other models in the Networks section of the Models Library, such as Giant Component.

See also Network Example, in the Code Examples section.

## COPYRIGHT AND LICENSE

Copyright 2008 Uri Wilensky.
Modified by Lada Adamic 2009.

![CC BY-NC-SA 3.0](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

outlined circle
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 false false -1 -1 301

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.2
@#$#@#$#@
setup
repeat 5 [rewire-one]
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="vary-rewiring-probability" repetitions="5" runMetricsEveryStep="false">
    <go>rewire-all</go>
    <timeLimit steps="1"/>
    <exitCondition>rewiring-probability &gt; 1</exitCondition>
    <metric>average-path-length</metric>
    <metric>clustering-coefficient</metric>
    <steppedValueSet variable="rewiring-probability" first="0" step="0.025" last="1"/>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
