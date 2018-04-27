(define (problem p1)
                   (:domain vacuum-no-fuel)
                   (:objects x1 x2 x3 y1 y2 - location 
		      t1 t2 t3 t4 - time	
		              d1 d2  - dirt )

		   
(:init 
(current-time t1) (next t1 t2) (next t2 t3) (next t3 t4)
(prox x3 x2)(prox x2 x1)
(prox x1 x2)(prox x2 x3)
(prox y1 y2)
(prox y2 y1)

(robot-at x1 y1)


(occupied x2 y2)
(occupied x3 y1)
(occupied x2 y2)

(dirt-at d1 x1 y1)



)

(:goal (and  (dirt-in-robot d1))) (:goal-reward 100) (:metric maximize (reward)))


