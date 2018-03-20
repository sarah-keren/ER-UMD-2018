(define (problem p1)
                   (:domain vacuum-no-fuel)
                   (:objects x1 x2 x3 y1 y2 y3 - location 
		              d1  - dirt)
(:init 
(prox x3 x2)(prox x2 x1)
(prox x1 x2)(prox x2 x3)
(prox y1 y2)(prox y2 y3)
(prox y3 y2)(prox y2 y1)

(robot-at x2 y1)


(occupied x2 y2)
(occupied x3 y3)
(occupied x3 y1)
(dirt-at d1 x2 y1)

)

(:goal (and  (dirt-in-robot d1))) (:goal-reward 100) (:metric maximize (reward)))


