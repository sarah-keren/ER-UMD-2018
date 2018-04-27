(define (problem p14)
                   (:domain vacuum-no-fuel)
                   (:objects x1 x2 x3 x4 x5 x6 x7 x8 y1 y2 y3 y4 - location 
		              d1 d2 d3 - dirt)
(:init 
(prox x8 x7)(prox x7 x6)(prox x6 x5)(prox x5 x4)(prox x4 x3)(prox x3 x2)(prox x2 x1)
(prox x1 x2)(prox x2 x3)(prox x3 x4)(prox x4 x5)(prox x5 x6)(prox x6 x7)(prox x7 x8)
(prox y1 y2)(prox y2 y3)(prox y3 y4)
(prox y4 y3)(prox y3 y2)(prox y2 y1)

(robot-at x1 y1)

;Kitchen island
(occupied x3 y2)
(occupied x3 y3)
(occupied x3 y4)
(occupied x3 y4)
;Arm-charis
(occupied x6 y4)
(occupied x7 y3)
(occupied x8 y3)

(dirt-at d1 x1 y2)
(dirt-at d2 x4 y3)
(dirt-at d3 x8 y2)

)

(:goal (and  (dirt-in-robot d1)(dirt-in-robot d2)(dirt-in-robot d3))) (:goal-reward 100) (:metric maximize (reward)))


