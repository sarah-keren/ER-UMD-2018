(define (domain vacuum-no-fuel)
  (:requirements :typing :strips :equality :probabilistic-effects :rewards)

  (:types location dirt time)

  (:predicates (robot-at ?x_loc ?y_loc - location)
	       (dirt-at ?dirt - dirt ?x_loc - location ?y_loc - location)
	       (dirt-in-robot ?dirt - dirt)
	       (occupied ?x ?y - location)
	       (current-time ?t1 - time)
	       (next ?t1 - time ?t2 - time)	
	       (enabled-safety-move ?x_from ?y_from ?x_to ?y_to - location)
	       (prox ?coordinate - location ?coordinate_next - location)	
         
  )



  (:action move-robot-x
    :parameters(?x_from - location ?x_to - location ?y - location )
    :precondition (and(robot-at ?x_from ?y)(not(occupied ?x_to ?y))(prox ?x_from ?x_to))
    :effect (and (probabilistic 0.8 (and(not(robot-at ?x_from ?y))(robot-at ?x_to ?y))
;				0.2 (forall (?x_loc - location)(when (and(prox ?x_from ?x_loc)(not(occupied ?x_loc ?y)))(robot-at ?x_loc ?y)))
		)
           )
	    
   )

 

 (:action move-robot-y
    :parameters(?x - location ?y_from - location ?y_to - location)
    :precondition (and(robot-at ?x ?y_from)(not(occupied ?x ?y_to))(prox ?y_from ?y_to))
    :effect (and (probabilistic 0.8 (and(not(robot-at ?x ?y_from))(robot-at ?x ?y_to))
;				0.2 (forall (?y_loc - location)(when (and(prox ?y_from ?y_loc)(not(occupied ?x ?y_loc)))(robot-at ?x ?y_loc)))
		)
           )
	    
   )


  (:action move-robot-y-safely
    :parameters(?x - location ?y_from - location ?y_to - location)
    :precondition (and(robot-at ?x ?y_from)(not(occupied ?x ?y_to))(prox ?y_from ?y_to)
                  (enabled-safety-move ?x ?y_from ?x ?y_to))
    :effect (and (not(robot-at ?x ?y_from))(robot-at ?x ?y_to))        	    
   )


 (:action loaddirt
    :parameters(?x_loc - location ?y_loc - location ?dirt -dirt)
    :precondition (and(robot-at ?x_loc ?y_loc) (dirt-at ?dirt ?x_loc ?y_loc))
    :effect (and(dirt-in-robot ?dirt) (not(dirt-at ?dirt ?x_loc ?y_loc))))


 (:action unloaddirt
    :parameters(?x_loc - location ?y_loc - location ?dirt -dirt)
    :precondition (and(robot-at ?x_loc ?y_loc) (dirt-in-robot ?dirt))
    :effect (and(not(dirt-in-robot ?dirt)) (dirt-at ?dirt ?x_loc ?y_loc)))


  

)


