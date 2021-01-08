; created by Lada Adamic (see copyright below)
; for the purposes of SI708/CSCS608

globals
[
  num-blue
  num-red
]



;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Runtime Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

to clear-opinion
  ask turtles [
    set color white
  ]
end

to update
  ifelse bilingual? [
     ask turtles [
      if any? link-neighbors with [color = blue or color = red] [
        let payoff-a a * count link-neighbors with [color = blue or color = green]
        let payoff-b b * count link-neighbors with [color = red or color = green]
        let payoff-ab (max (list a b) * count link-neighbors with [color = green]) + a * count link-neighbors with [color = blue] +  b * count link-neighbors with [color = red] - c
        let max-payoff max (list payoff-a payoff-b payoff-ab)
        if (max-payoff = payoff-a) [set color blue]
        if (max-payoff = payoff-b) [set color red]
        if (max-payoff = payoff-ab) [set color green]
      ]
    ]
  ]
  [
    ask turtles [
       if any? link-neighbors with [color = blue or color = red] [
         let payoff-a a * count link-neighbors with [color = blue]
         let payoff-b b * count link-neighbors with [color = red]
         set color blue
         if (payoff-a < payoff-b) [
           set color red
         ]
         if ((payoff-a = payoff-b) and (random 100 < 50)) [
           set color red
         ]
       ]
    ]
  ]
  do-plotting
end

to select-blue
  let current-point nobody

  if mouse-down? [
  let x round mouse-xcor
  let y round mouse-ycor
  ;; if we don't have a point yet, pick the closest one
  if current-point = nobody [
    set current-point min-one-of turtles [distancexy x y]
  ]
  ask current-point [
    set color blue
    set size 2
  ]
  ]
end

to select-red
  let current-point nobody

  if mouse-down? [
  let x round mouse-xcor
  let y round mouse-ycor
  ;; if we don't have a point yet, pick the closest one
  if current-point = nobody [
    set current-point min-one-of turtles [distancexy x y]
  ]
  ask current-point [
    set color red
    set size 2]
  ]
end



to alloc-opinion
  ask turtles [
    ifelse (random 100 < init-prob-blue) [
      set color blue
    ] [ set color red]
  ]
  ask links [
    set color white
   ]
  set num-blue count turtles with [color = blue]
  set num-red count turtles with [color = red]
  clear-all-plots
end

;;;;;;;;;;;;;;;;;;;;;;;
;;; Edge Operations ;;;
;;;;;;;;;;;;;;;;;;;;;;;

;; connects the two turtles
to make-edge [node1 node2]
  ask node1 [
    ifelse (node1 = node2)
    [
      show "error: self-loop attempted"
    ]
    [
      create-link-with node2 [ set color green ]
     ]
  ]
end

;;;;;;;;;;;;;;;;
;;; Plotting ;;;
;;;;;;;;;;;;;;;;

to do-plotting
     ;; plot the number of infected individuals at each step
     set-current-plot "Tally"
     set-current-plot-pen "num-blue"

     set num-blue count turtles with [color = blue]
     plot num-blue

      set-current-plot-pen "num-red"

     set num-red count turtles with [color = red]
     plot num-red

           set-current-plot-pen "num-green"

     set num-red count turtles with [color = green]
     plot num-red
end

;;;;;;;;;;;;;;
;;; Layout ;;;
;;;;;;;;;;;;;;
;; resize-turtles, change back and forth from size based on degree to a size of 1
to resize-nodes
  ifelse not any? turtles with [size > 1]
  [
    ;; a node is a circle with diameter determined by
    ;; the SIZE variable; using SQRT makes the circle's
    ;; area proportional to its degree
    ask turtles [ set size 3 / 4 * ln (count link-neighbors + 0.5)]
  ]
  [
    ask turtles [ set size 1 ]
  ]
end

;; spring layout of infection tree while in tree mode
;; otherwise, layout all nodes and links
to do-layout
  repeat 5 [layout-spring turtles links 0.2 4 4]
  display
end


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to setup19_4
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  set-default-shape turtles "circle"
  ;; make the initial network of two turtles and an edge

  crt 18 [
    set color white
    set size 3
  ]

  ask turtle 0 [die]
make-edge turtle 1 turtle 2
make-edge turtle 1 turtle 3
make-edge turtle 2 turtle 3
make-edge turtle 2 turtle 6
make-edge turtle 4 turtle 6
make-edge turtle 4 turtle 7
make-edge turtle 6 turtle 9
make-edge turtle 7 turtle 9
make-edge turtle 5 turtle 7
make-edge turtle 4 turtle 5
make-edge turtle 5 turtle 8
make-edge turtle 7 turtle 8
make-edge turtle 7 turtle 10
make-edge turtle 8 turtle 14
make-edge turtle 8 turtle 10
make-edge turtle 9 turtle 10
make-edge turtle 13 turtle 14
make-edge turtle 10 turtle 12
make-edge turtle 9 turtle 11
make-edge turtle 11 turtle 12
make-edge turtle 11 turtle 15
make-edge turtle 12 turtle 15
make-edge turtle 15 turtle 16
make-edge turtle 16 turtle 17
make-edge turtle 13 turtle 17
make-edge turtle 14 turtle 17
make-edge turtle 12 turtle 13
make-edge turtle 12 turtle 16
make-edge turtle 13 turtle 14
make-edge turtle 13 turtle 16

ask links [set color gray]
repeat 80 [do-layout]
end

to setup-line
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  set-default-shape turtles "circle"
  ;; make the initial network of two turtles and an edge

  crt 20 [
    set color white
    set size 3
  ]

let n 0
while [n < count turtles]
[
  make-edge turtle n turtle ((n + 1) mod count turtles)
  set n n + 1
]

ask links [set color gray]
repeat 80 [  repeat 5 [layout-spring turtles links 0.2 10 4]]
end

to setup19_3
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  set-default-shape turtles "circle"
  ;; make the initial network of two turtles and an edge

  crt 7 [
    set color white
    set size 3
  ]

  ask turtle 0 [die]
make-edge turtle 1 turtle 2
make-edge turtle 1 turtle 3
make-edge turtle 1 turtle 4
make-edge turtle 2 turtle 3
make-edge turtle 3 turtle 4
make-edge turtle 3 turtle 5
make-edge turtle 3 turtle 6
make-edge turtle 2 turtle 5
make-edge turtle 4 turtle 6
make-edge turtle 5 turtle 6

ask links [set color gray]
repeat 80 [  repeat 5 [layout-spring turtles links 0.2 10 4]]
end

to setup-fb
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  set-default-shape turtles "circle"
  ;; make the initial network of two turtles and an edge

  crt 150 [
    set color white
    set size 1.5
  ]
make-edge turtle 123 turtle 55
make-edge turtle 123 turtle 119
make-edge turtle 123 turtle 85
make-edge turtle 123 turtle 56
make-edge turtle 105 turtle 86
make-edge turtle 105 turtle 89
make-edge turtle 105 turtle 149
make-edge turtle 105 turtle 124
make-edge turtle 105 turtle 78
make-edge turtle 105 turtle 58
make-edge turtle 105 turtle 92
make-edge turtle 105 turtle 1
make-edge turtle 105 turtle 79
make-edge turtle 105 turtle 76
make-edge turtle 105 turtle 125
make-edge turtle 64 turtle 122
make-edge turtle 64 turtle 75
make-edge turtle 64 turtle 70
make-edge turtle 64 turtle 25
make-edge turtle 64 turtle 96
make-edge turtle 64 turtle 22
make-edge turtle 64 turtle 141
make-edge turtle 64 turtle 26
make-edge turtle 64 turtle 77
make-edge turtle 64 turtle 60
make-edge turtle 64 turtle 81
make-edge turtle 64 turtle 76
make-edge turtle 64 turtle 135
make-edge turtle 4 turtle 100
make-edge turtle 4 turtle 112
make-edge turtle 109 turtle 73
make-edge turtle 109 turtle 37
make-edge turtle 109 turtle 35
make-edge turtle 109 turtle 48
make-edge turtle 109 turtle 43
make-edge turtle 39 turtle 38
make-edge turtle 39 turtle 29
make-edge turtle 39 turtle 51
make-edge turtle 39 turtle 30
make-edge turtle 39 turtle 42
make-edge turtle 39 turtle 117
make-edge turtle 39 turtle 120
make-edge turtle 39 turtle 50
make-edge turtle 39 turtle 65
make-edge turtle 39 turtle 36
make-edge turtle 39 turtle 32
make-edge turtle 39 turtle 148
make-edge turtle 39 turtle 31
make-edge turtle 39 turtle 37
make-edge turtle 39 turtle 34
make-edge turtle 39 turtle 45
make-edge turtle 39 turtle 147
make-edge turtle 90 turtle 62
make-edge turtle 90 turtle 122
make-edge turtle 90 turtle 80
make-edge turtle 90 turtle 91
make-edge turtle 100 turtle 138
make-edge turtle 100 turtle 112
make-edge turtle 1 turtle 144
make-edge turtle 1 turtle 103
make-edge turtle 1 turtle 139
make-edge turtle 1 turtle 21
make-edge turtle 1 turtle 58
make-edge turtle 1 turtle 131
make-edge turtle 1 turtle 142
make-edge turtle 1 turtle 143
make-edge turtle 127 turtle 119
make-edge turtle 127 turtle 134
make-edge turtle 127 turtle 126
make-edge turtle 127 turtle 114
make-edge turtle 127 turtle 35
make-edge turtle 127 turtle 93
make-edge turtle 127 turtle 88
make-edge turtle 127 turtle 54
make-edge turtle 47 turtle 140
make-edge turtle 47 turtle 51
make-edge turtle 47 turtle 8
make-edge turtle 47 turtle 67
make-edge turtle 47 turtle 42
make-edge turtle 47 turtle 20
make-edge turtle 47 turtle 145
make-edge turtle 47 turtle 98
make-edge turtle 47 turtle 94
make-edge turtle 47 turtle 50
make-edge turtle 47 turtle 73
make-edge turtle 47 turtle 61
make-edge turtle 47 turtle 11
make-edge turtle 47 turtle 41
make-edge turtle 47 turtle 43
make-edge turtle 47 turtle 148
make-edge turtle 47 turtle 46
make-edge turtle 47 turtle 37
make-edge turtle 47 turtle 31
make-edge turtle 47 turtle 35
make-edge turtle 47 turtle 34
make-edge turtle 47 turtle 118
make-edge turtle 47 turtle 116
make-edge turtle 47 turtle 108
make-edge turtle 47 turtle 48
make-edge turtle 47 turtle 147
make-edge turtle 74 turtle 118
make-edge turtle 74 turtle 41
make-edge turtle 149 turtle 18
make-edge turtle 149 turtle 89
make-edge turtle 149 turtle 2
make-edge turtle 149 turtle 145
make-edge turtle 149 turtle 78
make-edge turtle 149 turtle 124
make-edge turtle 149 turtle 92
make-edge turtle 149 turtle 125
make-edge turtle 89 turtle 124
make-edge turtle 89 turtle 78
make-edge turtle 89 turtle 131
make-edge turtle 89 turtle 95
make-edge turtle 89 turtle 6
make-edge turtle 59 turtle 103
make-edge turtle 66 turtle 19
make-edge turtle 66 turtle 61
make-edge turtle 66 turtle 146
make-edge turtle 66 turtle 147
make-edge turtle 66 turtle 45
make-edge turtle 66 turtle 50
make-edge turtle 53 turtle 107
make-edge turtle 53 turtle 32
make-edge turtle 53 turtle 56
make-edge turtle 20 turtle 73
make-edge turtle 20 turtle 68
make-edge turtle 20 turtle 140
make-edge turtle 20 turtle 11
make-edge turtle 20 turtle 8
make-edge turtle 20 turtle 41
make-edge turtle 20 turtle 42
make-edge turtle 20 turtle 148
make-edge turtle 20 turtle 31
make-edge turtle 20 turtle 102
make-edge turtle 20 turtle 34
make-edge turtle 20 turtle 118
make-edge turtle 20 turtle 50
make-edge turtle 20 turtle 48
make-edge turtle 58 turtle 29
make-edge turtle 58 turtle 86
make-edge turtle 58 turtle 23
make-edge turtle 58 turtle 104
make-edge turtle 58 turtle 21
make-edge turtle 58 turtle 111
make-edge turtle 58 turtle 124
make-edge turtle 58 turtle 142
make-edge turtle 58 turtle 143
make-edge turtle 58 turtle 76
make-edge turtle 58 turtle 132
make-edge turtle 58 turtle 125
make-edge turtle 58 turtle 9
make-edge turtle 58 turtle 14
make-edge turtle 58 turtle 57
make-edge turtle 58 turtle 32
make-edge turtle 58 turtle 2
make-edge turtle 58 turtle 113
make-edge turtle 58 turtle 27
make-edge turtle 58 turtle 72
make-edge turtle 58 turtle 6
make-edge turtle 98 turtle 65
make-edge turtle 98 turtle 140
make-edge turtle 98 turtle 51
make-edge turtle 98 turtle 41
make-edge turtle 98 turtle 42
make-edge turtle 98 turtle 111
make-edge turtle 98 turtle 148
make-edge turtle 98 turtle 40
make-edge turtle 98 turtle 31
make-edge turtle 98 turtle 94
make-edge turtle 98 turtle 44
make-edge turtle 84 turtle 103
make-edge turtle 84 turtle 97
make-edge turtle 84 turtle 9
make-edge turtle 112 turtle 138
make-edge turtle 35 turtle 73
make-edge turtle 35 turtle 134
make-edge turtle 35 turtle 41
make-edge turtle 35 turtle 42
make-edge turtle 35 turtle 43
make-edge turtle 35 turtle 148
make-edge turtle 35 turtle 37
make-edge turtle 35 turtle 34
make-edge turtle 35 turtle 93
make-edge turtle 35 turtle 50
make-edge turtle 35 turtle 48
make-edge turtle 35 turtle 44
make-edge turtle 108 turtle 67
make-edge turtle 108 turtle 50
make-edge turtle 108 turtle 43
make-edge turtle 81 turtle 122
make-edge turtle 81 turtle 75
make-edge turtle 81 turtle 70
make-edge turtle 81 turtle 22
make-edge turtle 81 turtle 141
make-edge turtle 81 turtle 26
make-edge turtle 81 turtle 60
make-edge turtle 81 turtle 76
make-edge turtle 81 turtle 135
make-edge turtle 22 turtle 141
make-edge turtle 22 turtle 135
make-edge turtle 52 turtle 55
make-edge turtle 139 turtle 114
make-edge turtle 139 turtle 126
make-edge turtle 139 turtle 134
make-edge turtle 111 turtle 29
make-edge turtle 111 turtle 140
make-edge turtle 111 turtle 23
make-edge turtle 111 turtle 51
make-edge turtle 111 turtle 49
make-edge turtle 111 turtle 104
make-edge turtle 111 turtle 21
make-edge turtle 111 turtle 124
make-edge turtle 111 turtle 142
make-edge turtle 111 turtle 94
make-edge turtle 111 turtle 143
make-edge turtle 111 turtle 132
make-edge turtle 111 turtle 9
make-edge turtle 111 turtle 57
make-edge turtle 111 turtle 14
make-edge turtle 111 turtle 2
make-edge turtle 111 turtle 16
make-edge turtle 111 turtle 5
make-edge turtle 111 turtle 113
make-edge turtle 111 turtle 31
make-edge turtle 111 turtle 118
make-edge turtle 111 turtle 83
make-edge turtle 33 turtle 118
make-edge turtle 33 turtle 140
make-edge turtle 50 turtle 29
make-edge turtle 50 turtle 140
make-edge turtle 50 turtle 51
make-edge turtle 50 turtle 8
make-edge turtle 50 turtle 67
make-edge turtle 50 turtle 42
make-edge turtle 50 turtle 145
make-edge turtle 50 turtle 117
make-edge turtle 50 turtle 94
make-edge turtle 50 turtle 73
make-edge turtle 50 turtle 28
make-edge turtle 50 turtle 146
make-edge turtle 50 turtle 41
make-edge turtle 50 turtle 43
make-edge turtle 50 turtle 148
make-edge turtle 50 turtle 46
make-edge turtle 50 turtle 37
make-edge turtle 50 turtle 31
make-edge turtle 50 turtle 102
make-edge turtle 50 turtle 34
make-edge turtle 50 turtle 118
make-edge turtle 50 turtle 19
make-edge turtle 50 turtle 147
make-edge turtle 50 turtle 45
make-edge turtle 50 turtle 48
make-edge turtle 50 turtle 44
make-edge turtle 132 turtle 29
make-edge turtle 132 turtle 23
make-edge turtle 132 turtle 51
make-edge turtle 132 turtle 2
make-edge turtle 132 turtle 5
make-edge turtle 132 turtle 21
make-edge turtle 132 turtle 113
make-edge turtle 132 turtle 72
make-edge turtle 132 turtle 9
make-edge turtle 9 turtle 25
make-edge turtle 9 turtle 23
make-edge turtle 9 turtle 104
make-edge turtle 9 turtle 97
make-edge turtle 9 turtle 110
make-edge turtle 9 turtle 103
make-edge turtle 9 turtle 2
make-edge turtle 9 turtle 121
make-edge turtle 9 turtle 5
make-edge turtle 9 turtle 118
make-edge turtle 9 turtle 63
make-edge turtle 9 turtle 72
make-edge turtle 9 turtle 83
make-edge turtle 24 turtle 23
make-edge turtle 24 turtle 69
make-edge turtle 24 turtle 135
make-edge turtle 14 turtle 57
make-edge turtle 14 turtle 23
make-edge turtle 14 turtle 142
make-edge turtle 14 turtle 104
make-edge turtle 14 turtle 83
make-edge turtle 146 turtle 65
make-edge turtle 146 turtle 36
make-edge turtle 146 turtle 28
make-edge turtle 146 turtle 61
make-edge turtle 146 turtle 67
make-edge turtle 146 turtle 46
make-edge turtle 146 turtle 102
make-edge turtle 146 turtle 116
make-edge turtle 146 turtle 19
make-edge turtle 146 turtle 147
make-edge turtle 146 turtle 45
make-edge turtle 0 turtle 144
make-edge turtle 0 turtle 115
make-edge turtle 0 turtle 72
make-edge turtle 0 turtle 5
make-edge turtle 16 turtle 51
make-edge turtle 16 turtle 32
make-edge turtle 16 turtle 41
make-edge turtle 16 turtle 148
make-edge turtle 16 turtle 31
make-edge turtle 16 turtle 34
make-edge turtle 16 turtle 94
make-edge turtle 16 turtle 72
make-edge turtle 16 turtle 44
make-edge turtle 43 turtle 68
make-edge turtle 43 turtle 140
make-edge turtle 43 turtle 51
make-edge turtle 43 turtle 8
make-edge turtle 43 turtle 42
make-edge turtle 43 turtle 145
make-edge turtle 43 turtle 117
make-edge turtle 43 turtle 73
make-edge turtle 43 turtle 11
make-edge turtle 43 turtle 41
make-edge turtle 43 turtle 148
make-edge turtle 43 turtle 37
make-edge turtle 43 turtle 31
make-edge turtle 43 turtle 34
make-edge turtle 43 turtle 102
make-edge turtle 43 turtle 118
make-edge turtle 43 turtle 48
make-edge turtle 43 turtle 44
make-edge turtle 116 turtle 61
make-edge turtle 116 turtle 46
make-edge turtle 116 turtle 37
make-edge turtle 116 turtle 102
make-edge turtle 116 turtle 7
make-edge turtle 116 turtle 94
make-edge turtle 77 turtle 122
make-edge turtle 77 turtle 26
make-edge turtle 77 turtle 70
make-edge turtle 77 turtle 25
make-edge turtle 77 turtle 96
make-edge turtle 77 turtle 97
make-edge turtle 77 turtle 60
make-edge turtle 87 turtle 107
make-edge turtle 87 turtle 133
make-edge turtle 87 turtle 88
make-edge turtle 17 turtle 122
make-edge turtle 49 turtle 122
make-edge turtle 49 turtle 29
make-edge turtle 49 turtle 140
make-edge turtle 49 turtle 51
make-edge turtle 49 turtle 32
make-edge turtle 49 turtle 117
make-edge turtle 49 turtle 118
make-edge turtle 49 turtle 97
make-edge turtle 49 turtle 44
make-edge turtle 104 turtle 57
make-edge turtle 104 turtle 23
make-edge turtle 104 turtle 2
make-edge turtle 104 turtle 5
make-edge turtle 104 turtle 72
make-edge turtle 104 turtle 83
make-edge turtle 145 turtle 68
make-edge turtle 145 turtle 11
make-edge turtle 145 turtle 48
make-edge turtle 120 turtle 117
make-edge turtle 120 turtle 29
make-edge turtle 120 turtle 140
make-edge turtle 120 turtle 147
make-edge turtle 120 turtle 32
make-edge turtle 93 turtle 134
make-edge turtle 93 turtle 88
make-edge turtle 93 turtle 54
make-edge turtle 15 turtle 113
make-edge turtle 15 turtle 34
make-edge turtle 15 turtle 23
make-edge turtle 15 turtle 51
make-edge turtle 15 turtle 94
make-edge turtle 15 turtle 2
make-edge turtle 143 turtle 29
make-edge turtle 143 turtle 142
make-edge turtle 143 turtle 44
make-edge turtle 143 turtle 5
make-edge turtle 60 turtle 122
make-edge turtle 60 turtle 75
make-edge turtle 60 turtle 70
make-edge turtle 60 turtle 25
make-edge turtle 60 turtle 96
make-edge turtle 60 turtle 141
make-edge turtle 60 turtle 26
make-edge turtle 60 turtle 76
make-edge turtle 60 turtle 135
make-edge turtle 125 turtle 86
make-edge turtle 125 turtle 2
make-edge turtle 125 turtle 78
make-edge turtle 125 turtle 124
make-edge turtle 125 turtle 92
make-edge turtle 125 turtle 76
make-edge turtle 133 turtle 119
make-edge turtle 133 turtle 107
make-edge turtle 133 turtle 106
make-edge turtle 133 turtle 88
make-edge turtle 122 turtle 62
make-edge turtle 122 turtle 75
make-edge turtle 122 turtle 25
make-edge turtle 122 turtle 96
make-edge turtle 122 turtle 8
make-edge turtle 122 turtle 141
make-edge turtle 122 turtle 26
make-edge turtle 122 turtle 80
make-edge turtle 122 turtle 76
make-edge turtle 122 turtle 129
make-edge turtle 122 turtle 135
make-edge turtle 122 turtle 70
make-edge turtle 122 turtle 91
make-edge turtle 122 turtle 2
make-edge turtle 71 turtle 131
make-edge turtle 11 turtle 37
make-edge turtle 11 turtle 34
make-edge turtle 32 turtle 38
make-edge turtle 32 turtle 29
make-edge turtle 32 turtle 51
make-edge turtle 32 turtle 30
make-edge turtle 32 turtle 42
make-edge turtle 32 turtle 21
make-edge turtle 32 turtle 117
make-edge turtle 32 turtle 97
make-edge turtle 32 turtle 129
make-edge turtle 32 turtle 36
make-edge turtle 32 turtle 103
make-edge turtle 32 turtle 148
make-edge turtle 32 turtle 5
make-edge turtle 32 turtle 31
make-edge turtle 32 turtle 27
make-edge turtle 32 turtle 118
make-edge turtle 32 turtle 147
make-edge turtle 32 turtle 44
make-edge turtle 2 turtle 86
make-edge turtle 2 turtle 128
make-edge turtle 2 turtle 23
make-edge turtle 2 turtle 30
make-edge turtle 2 turtle 117
make-edge turtle 2 turtle 124
make-edge turtle 2 turtle 78
make-edge turtle 2 turtle 26
make-edge turtle 2 turtle 13
make-edge turtle 2 turtle 135
make-edge turtle 2 turtle 18
make-edge turtle 2 turtle 69
make-edge turtle 2 turtle 99
make-edge turtle 2 turtle 57
make-edge turtle 2 turtle 5
make-edge turtle 2 turtle 121
make-edge turtle 2 turtle 113
make-edge turtle 2 turtle 92
make-edge turtle 2 turtle 95
make-edge turtle 2 turtle 72
make-edge turtle 2 turtle 115
make-edge turtle 2 turtle 6
make-edge turtle 37 turtle 10
make-edge turtle 37 turtle 140
make-edge turtle 37 turtle 51
make-edge turtle 37 turtle 8
make-edge turtle 37 turtle 42
make-edge turtle 37 turtle 117
make-edge turtle 37 turtle 94
make-edge turtle 37 turtle 73
make-edge turtle 37 turtle 41
make-edge turtle 37 turtle 102
make-edge turtle 37 turtle 34
make-edge turtle 37 turtle 48
make-edge turtle 37 turtle 44
make-edge turtle 34 turtle 10
make-edge turtle 34 turtle 140
make-edge turtle 34 turtle 51
make-edge turtle 34 turtle 8
make-edge turtle 34 turtle 42
make-edge turtle 34 turtle 117
make-edge turtle 34 turtle 94
make-edge turtle 34 turtle 73
make-edge turtle 34 turtle 148
make-edge turtle 34 turtle 31
make-edge turtle 34 turtle 118
make-edge turtle 72 turtle 57
make-edge turtle 72 turtle 23
make-edge turtle 72 turtle 5
make-edge turtle 72 turtle 113
make-edge turtle 72 turtle 83
make-edge turtle 45 turtle 29
make-edge turtle 45 turtle 140
make-edge turtle 45 turtle 51
make-edge turtle 45 turtle 67
make-edge turtle 45 turtle 117
make-edge turtle 45 turtle 40
make-edge turtle 45 turtle 7
make-edge turtle 45 turtle 94
make-edge turtle 45 turtle 65
make-edge turtle 45 turtle 61
make-edge turtle 45 turtle 28
make-edge turtle 45 turtle 148
make-edge turtle 45 turtle 113
make-edge turtle 45 turtle 31
make-edge turtle 45 turtle 102
make-edge turtle 45 turtle 147
make-edge turtle 6 turtle 18
make-edge turtle 6 turtle 57
make-edge turtle 6 turtle 99
make-edge turtle 6 turtle 124
make-edge turtle 6 turtle 78
make-edge turtle 6 turtle 92
make-edge turtle 6 turtle 95
make-edge turtle 38 turtle 140
make-edge turtle 38 turtle 51
make-edge turtle 38 turtle 42
make-edge turtle 38 turtle 31
make-edge turtle 38 turtle 117
make-edge turtle 38 turtle 118
make-edge turtle 3 turtle 95
make-edge turtle 3 turtle 130
make-edge turtle 3 turtle 101
make-edge turtle 75 turtle 70
make-edge turtle 75 turtle 25
make-edge turtle 75 turtle 141
make-edge turtle 75 turtle 26
make-edge turtle 75 turtle 76
make-edge turtle 75 turtle 135
make-edge turtle 86 turtle 124
make-edge turtle 96 turtle 26
make-edge turtle 96 turtle 70
make-edge turtle 96 turtle 25
make-edge turtle 128 turtle 23
make-edge turtle 128 turtle 135
make-edge turtle 23 turtle 29
make-edge turtle 23 turtle 137
make-edge turtle 23 turtle 117
make-edge turtle 23 turtle 124
make-edge turtle 23 turtle 142
make-edge turtle 23 turtle 110
make-edge turtle 23 turtle 135
make-edge turtle 23 turtle 69
make-edge turtle 23 turtle 103
make-edge turtle 23 turtle 57
make-edge turtle 23 turtle 113
make-edge turtle 8 turtle 10
make-edge turtle 8 turtle 140
make-edge turtle 8 turtle 51
make-edge turtle 8 turtle 42
make-edge turtle 8 turtle 117
make-edge turtle 8 turtle 94
make-edge turtle 8 turtle 73
make-edge turtle 8 turtle 148
make-edge turtle 8 turtle 31
make-edge turtle 8 turtle 48
make-edge turtle 8 turtle 44
make-edge turtle 67 turtle 73
make-edge turtle 67 turtle 140
make-edge turtle 67 turtle 117
make-edge turtle 67 turtle 102
make-edge turtle 67 turtle 147
make-edge turtle 67 turtle 48
make-edge turtle 42 turtle 29
make-edge turtle 42 turtle 10
make-edge turtle 42 turtle 140
make-edge turtle 42 turtle 51
make-edge turtle 42 turtle 30
make-edge turtle 42 turtle 40
make-edge turtle 42 turtle 117
make-edge turtle 42 turtle 94
make-edge turtle 42 turtle 73
make-edge turtle 42 turtle 65
make-edge turtle 42 turtle 41
make-edge turtle 42 turtle 148
make-edge turtle 42 turtle 31
make-edge turtle 42 turtle 118
make-edge turtle 42 turtle 147
make-edge turtle 42 turtle 48
make-edge turtle 42 turtle 44
make-edge turtle 114 turtle 12
make-edge turtle 114 turtle 134
make-edge turtle 114 turtle 82
make-edge turtle 114 turtle 54
make-edge turtle 26 turtle 25
make-edge turtle 26 turtle 141
make-edge turtle 26 turtle 76
make-edge turtle 26 turtle 110
make-edge turtle 26 turtle 135
make-edge turtle 26 turtle 70
make-edge turtle 26 turtle 69
make-edge turtle 26 turtle 121
make-edge turtle 26 turtle 63
make-edge turtle 97 turtle 103
make-edge turtle 97 turtle 121
make-edge turtle 142 turtle 57
make-edge turtle 142 turtle 21
make-edge turtle 142 turtle 118
make-edge turtle 142 turtle 95
make-edge turtle 76 turtle 70
make-edge turtle 76 turtle 25
make-edge turtle 76 turtle 141
make-edge turtle 76 turtle 124
make-edge turtle 76 turtle 135
make-edge turtle 129 turtle 31
make-edge turtle 129 turtle 140
make-edge turtle 135 turtle 70
make-edge turtle 135 turtle 25
make-edge turtle 135 turtle 141
make-edge turtle 73 turtle 29
make-edge turtle 73 turtle 140
make-edge turtle 73 turtle 51
make-edge turtle 73 turtle 94
make-edge turtle 73 turtle 148
make-edge turtle 73 turtle 31
make-edge turtle 73 turtle 118
make-edge turtle 73 turtle 48
make-edge turtle 73 turtle 44
make-edge turtle 134 turtle 12
make-edge turtle 134 turtle 126
make-edge turtle 134 turtle 82
make-edge turtle 134 turtle 54
make-edge turtle 148 turtle 29
make-edge turtle 148 turtle 10
make-edge turtle 148 turtle 140
make-edge turtle 148 turtle 51
make-edge turtle 148 turtle 30
make-edge turtle 148 turtle 117
make-edge turtle 148 turtle 40
make-edge turtle 148 turtle 94
make-edge turtle 148 turtle 65
make-edge turtle 148 turtle 41
make-edge turtle 148 turtle 31
make-edge turtle 148 turtle 118
make-edge turtle 148 turtle 147
make-edge turtle 148 turtle 44
make-edge turtle 46 turtle 102
make-edge turtle 46 turtle 7
make-edge turtle 121 turtle 25
make-edge turtle 126 turtle 12
make-edge turtle 126 turtle 25
make-edge turtle 31 turtle 10
make-edge turtle 31 turtle 140
make-edge turtle 31 turtle 51
make-edge turtle 31 turtle 30
make-edge turtle 31 turtle 40
make-edge turtle 31 turtle 117
make-edge turtle 31 turtle 94
make-edge turtle 31 turtle 36
make-edge turtle 31 turtle 41
make-edge turtle 31 turtle 118
make-edge turtle 31 turtle 147
make-edge turtle 31 turtle 44
make-edge turtle 92 turtle 18
make-edge turtle 92 turtle 68
make-edge turtle 92 turtle 57
make-edge turtle 92 turtle 124
make-edge turtle 29 turtle 140
make-edge turtle 29 turtle 51
make-edge turtle 29 turtle 30
make-edge turtle 29 turtle 40
make-edge turtle 29 turtle 94
make-edge turtle 29 turtle 36
make-edge turtle 29 turtle 28
make-edge turtle 29 turtle 61
make-edge turtle 29 turtle 57
make-edge turtle 29 turtle 5
make-edge turtle 29 turtle 102
make-edge turtle 29 turtle 118
make-edge turtle 29 turtle 147
make-edge turtle 62 turtle 80
make-edge turtle 62 turtle 91
make-edge turtle 144 turtle 56
make-edge turtle 21 turtle 103
make-edge turtle 21 turtle 51
make-edge turtle 21 turtle 5
make-edge turtle 21 turtle 131
make-edge turtle 21 turtle 94
make-edge turtle 21 turtle 115
make-edge turtle 21 turtle 83
make-edge turtle 80 turtle 91
make-edge turtle 94 turtle 10
make-edge turtle 94 turtle 140
make-edge turtle 94 turtle 51
make-edge turtle 94 turtle 30
make-edge turtle 94 turtle 40
make-edge turtle 94 turtle 117
make-edge turtle 94 turtle 65
make-edge turtle 94 turtle 36
make-edge turtle 94 turtle 61
make-edge turtle 94 turtle 118
make-edge turtle 94 turtle 147
make-edge turtle 94 turtle 44
make-edge turtle 85 turtle 55
make-edge turtle 85 turtle 136
make-edge turtle 85 turtle 119
make-edge turtle 85 turtle 88
make-edge turtle 70 turtle 25
make-edge turtle 70 turtle 141
make-edge turtle 5 turtle 36
make-edge turtle 5 turtle 30
make-edge turtle 5 turtle 115
make-edge turtle 5 turtle 83
make-edge turtle 95 turtle 78
make-edge turtle 95 turtle 79
make-edge turtle 82 turtle 107
make-edge turtle 82 turtle 54
make-edge turtle 63 turtle 110
make-edge turtle 107 turtle 55
make-edge turtle 107 turtle 54
make-edge turtle 107 turtle 88
make-edge turtle 44 turtle 10
make-edge turtle 44 turtle 140
make-edge turtle 44 turtle 51
make-edge turtle 44 turtle 40
make-edge turtle 44 turtle 65
make-edge turtle 44 turtle 61
make-edge turtle 44 turtle 41
make-edge turtle 44 turtle 118
make-edge turtle 44 turtle 48
make-edge turtle 55 turtle 119
make-edge turtle 55 turtle 56
make-edge turtle 140 turtle 10
make-edge turtle 140 turtle 51
make-edge turtle 140 turtle 30
make-edge turtle 140 turtle 117
make-edge turtle 140 turtle 40
make-edge turtle 140 turtle 65
make-edge turtle 140 turtle 36
make-edge turtle 140 turtle 41
make-edge turtle 140 turtle 118
make-edge turtle 140 turtle 147
make-edge turtle 140 turtle 48
make-edge turtle 78 turtle 124
make-edge turtle 78 turtle 131
make-edge turtle 78 turtle 79
make-edge turtle 40 turtle 65
make-edge turtle 40 turtle 51
make-edge turtle 124 turtle 57
make-edge turtle 13 turtle 99
make-edge turtle 65 turtle 61
make-edge turtle 65 turtle 51
make-edge turtle 65 turtle 147
make-edge turtle 18 turtle 68
make-edge turtle 18 turtle 57
make-edge turtle 57 turtle 83
make-edge turtle 48 turtle 51
make-edge turtle 48 turtle 41
make-edge turtle 48 turtle 118
make-edge turtle 147 turtle 51
make-edge turtle 147 turtle 117
make-edge turtle 147 turtle 7
make-edge turtle 147 turtle 36
make-edge turtle 147 turtle 28
make-edge turtle 147 turtle 102
make-edge turtle 147 turtle 19
make-edge turtle 56 turtle 88
make-edge turtle 10 turtle 51
make-edge turtle 10 turtle 41
make-edge turtle 25 turtle 141
make-edge turtle 68 turtle 30
make-edge turtle 51 turtle 30
make-edge turtle 51 turtle 117
make-edge turtle 51 turtle 36
make-edge turtle 51 turtle 61
make-edge turtle 51 turtle 41
make-edge turtle 51 turtle 102
make-edge turtle 51 turtle 118
make-edge turtle 30 turtle 36
make-edge turtle 30 turtle 117
make-edge turtle 117 turtle 36
make-edge turtle 117 turtle 41
make-edge turtle 117 turtle 118
make-edge turtle 7 turtle 102
make-edge turtle 7 turtle 61
make-edge turtle 36 turtle 41
make-edge turtle 61 turtle 102
make-edge turtle 41 turtle 118
make-edge turtle 54 turtle 88
make-edge turtle 112 turtle 62

ask links [set color white]
repeat 80 [do-layout]
end
@#$#@#$#@
GRAPHICS-WINDOW
340
10
728
399
-1
-1
4.18
1
10
1
1
1
0
0
0
1
-45
45
-45
45
0
0
1
ticks
30.0

BUTTON
6
25
66
58
NIL
setup-fb
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
212
182
331
215
update
update
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
736
10
838
43
layout
do-layout
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
8
219
333
421
Tally
time
n
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"num-blue" 1.0 0 -13345367 true "" ""
"num-red" 1.0 0 -2674135 true "" ""
"num-green" 1.0 0 -10899396 true "" ""

SLIDER
8
63
143
96
a
a
0
10
3.0
1
1
NIL
HORIZONTAL

BUTTON
214
110
330
143
alloc-opinion
alloc-opinion
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
258
287
332
332
# blue
count turtles with [color = blue]
17
1
11

MONITOR
259
333
328
378
# red
count turtles with [color = red]
17
1
11

BUTTON
213
146
330
179
update
update
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
736
99
835
132
NIL
select-blue
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
736
135
831
168
NIL
select-red
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
7
100
144
133
b
b
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
6
137
144
170
c
c
0
10
4.0
1
1
NIL
HORIZONTAL

SWITCH
737
173
853
206
bilingual?
bilingual?
1
1
-1000

BUTTON
69
25
139
58
NIL
setup19_4
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
151
65
323
98
init-prob-blue
init-prob-blue
0
100
83.0
1
1
NIL
HORIZONTAL

BUTTON
141
25
207
58
setup19_3
setup19_3
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
209
25
286
58
setup-line
setup-line
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
12
177
197
247
a = payoff for playing A (blue)\nb = payoff for playing B (red)\nc = cost of playing AB
11
0.0
1

BUTTON
738
48
854
81
NIL
clear-opinion
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

This is a model of nodes choosing between two options A (blue) and B (red). The two options have different payoffs. If a node chooses A, then it receives a payoff of a * (number of its neighbors who have also chosen A), similar for B. If BILINGUAL? is on, then a node can choose to be bilingual, but must pay a one-time cost of c in order to do so. Then it can reap the payoffs for both friends who chose A and friends who chose B. A and B could be e.g. calling plans, IM chat clients, even sports that nodes are coordinating their choices around.

## HOW IT WORKS

There are 4 different topologies, Lada's Facebook network from 2008, two examples from Chapter 19 of Easley and Kleinberg, and finally a ring lattice. You can setup each in turn to see the effect of topology on cascades. 

## HOW TO USE IT
To randomly initialize opinions with INIT-PROB-BLUE being blue, click on ALLOC OPINION.

Then set the payoffs for blue (A) and red (B), as well as a cost c for being bilingual if BILINGUAL? is on.

Click on UPDATE to see nodes update their opinions to maximize their utility.

To seed just a select few nodes with red and blue choices:
Click on SELECT-RED and click on the nodes you will seed with the red opinion. Click on SELECT-RED again to stop the selection process. Do the same with SELECT-BLUE. 

Then run the model, using either simple or complex contagion. You can slow things down by moving the speed slider up top.


## MAKING IT INTO A GAME

Challenge a friend. Have them pick two red nodes, and you pick two blue nodes. Update the nodes' choices. Whose opinion wins out?

## CREDITS AND REFERENCES
This model is based on Easley & Kleinberg, Networks, Crowds, and Markets, Ch. 19: cascades in networks. http://www.cs.cornell.edu/home/kleinber/networks-book/
This model was created by Lada Adamic 2007-2012.  
Feel free to use it and modify it as you like with or without attribution.
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
NetLogo 6.2.0
@#$#@#$#@
set layout? false
setup repeat 175 [ go ]
repeat 35 [ layout ]
@#$#@#$#@
@#$#@#$#@
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
