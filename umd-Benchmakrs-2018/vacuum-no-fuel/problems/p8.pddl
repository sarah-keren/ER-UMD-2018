(define (problem p8)
                   (:domain vacuum-no-fuel)
                   (:objects x1 x2 x3 x4 y1 y2 y3 y4 - location 
		              d1 d2 d3 - dirt)
(:init 
(prox x4 x3)(prox x3 x2)(prox x2 x1)
(prox x1 x2)(prox x2 x3)(prox x3 x4)
(prox y1 y2)(prox y2 y3)(prox y3 y4)
(prox y4 y3)(prox y3 y2)(prox y2 y1)

(robot-at x1 y1)

;Kitchen island
(occupied x3 y2)
(occupied x3 y3)
(occupied x3 y4)
(occupied x3 y4)

(dirt-at d1 x1 y2)
(dirt-at d2 x4 y3)
(dirt-at d3 x2 y3)
)

(:goal (and  (dirt-in-robot d1)(dirt-in-robot d2)(dirt-in-robot d3))) (:goal-reward 100) (:metric maximize (reward)))


