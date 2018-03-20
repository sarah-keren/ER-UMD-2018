(define (problem p6)
                   (:domain vacuum-no-fuel)
                   (:objects x1 x2 y1 y2 y3 y4 - location 
		              d1 d2  - dirt)
(:init 
(prox x2 x1)
(prox x1 x2)

(prox y1 y2)(prox y2 y3)
(prox y3 y2)(prox y2 y1)
(prox y3 y4)(prox y4 y3)

(robot-at x2 y1)

(occupied x1 y2)
(occupied x1 y3)

(occupied x2 y2)
(occupied x2 y3)


(dirt-at d1 x2 y1)
(dirt-at d2 x2 y4)

)

(:goal (and  (dirt-in-robot d1)(dirt-in-robot d2))) (:goal-reward 100) (:metric maximize (reward)))


