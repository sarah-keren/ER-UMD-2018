;; Authors: Michael Littman and David Weissman
;; Modified by: Blai Bonet

;; Comment: Good plans are those that avoid putting blocks on table since the probability of detonation is higher

(define (domain exploding-blocksworld-design-over-relaxed)
  (:requirements :typing :conditional-effects :probabilistic-effects :equality :rewards)
  (:types block time)
  (:predicates 

	(on ?b1 ?b2 - block)
        (on-table ?b - block)
        (clear ?b - block)
        (holding ?b - block)
        (emptyhand)
        (no-detonated ?b - block)
        (no-destroyed ?b - block) 
        (no-destroyed-table)
        (enabled-safety-put-down ?b - block)
        (safety-put-down)
        (enabled-safety-put-on-block ?b1 - block ?b2 - block)
        (safety-put-on-block ?b1 - block)
        (execution)
	(current-time ?t1 - time)
	(next ?t1 - time ?t2 - time)	
)


  (:action put-down-enabled
   :parameters (?b - block)
   :precondition (and (holding ?b) (no-destroyed-table) (safety-put-down) (execution))
   :effect (and (emptyhand) (on-table ?b) )
  )
  
  (:action put-on-block-enabled
   :parameters (?b1 ?b2 - block)
   :precondition (and (holding ?b1) (clear ?b2) (no-destroyed ?b2) (safety-put-on-block ?b1) (execution))
   :effect (and (emptyhand) (on ?b1 ?b2)  )
  )
  


  (:action pick-up
   :parameters (?b1 ?b2 - block)
   :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2) (no-destroyed ?b1)(execution))
   :effect (and (holding ?b1) (clear ?b2)  )
  )
 
 (:action pick-up-from-table
   :parameters (?b - block)
   :precondition (and (emptyhand) (clear ?b) (on-table ?b) (no-destroyed ?b)(execution))
   :effect (and (holding ?b)  )
  )
  
  (:action put-down
   :parameters (?b - block)
   :precondition (and (holding ?b) (no-destroyed-table)(execution))
   :effect (and (emptyhand) (on-table ?b) 
                (probabilistic 0.4 (when (no-detonated ?b) (and (not (no-destroyed-table)) (not (no-detonated ?b))))))
  )
  
  (:action put-on-block
   :parameters (?b1 ?b2 - block)
   :precondition (and (holding ?b1) (clear ?b2) (no-destroyed ?b2)(execution))
   :effect (and (emptyhand) (on ?b1 ?b2)  
                (probabilistic 0.1 (when (no-detonated ?b1) (and (not (no-destroyed ?b2)) (not (no-detonated ?b1))))))
  )
  

;Design actions

 (:action design-idle
    :parameters ( ?t - time ?tnext - time )
    :precondition (and (not (execution)) (current-time ?t ) (next ?t ?tnext))
    :effect (and (current-time ?tnext ) (not (current-time ?t)))
  )


  (:action design-start-execution
    :parameters ()
    :precondition (and (not (execution)))
    :effect (and (execution))
  )

  (:action design-reduce-uncertainty-put-down
    :parameters (?b - block ?t - time ?tnext - time)
    :precondition (and (not (execution))(next ?t ?tnext) (current-time ?t ))
    :effect (and (enabled-safety-put-down ?b)(safety-put-down) (current-time ?tnext ) (not (current-time ?t )))
  )
  
  (:action design-reduce-uncertainty-put-on-block
    :parameters (?b1 - block ?b2 - block ?t - time ?tnext - time)
    :precondition (and (not (execution))(next ?t ?tnext) (current-time ?t ))
    :effect (and (enabled-safety-put-on-block ?b1 ?b2)(safety-put-on-block ?b1)(current-time ?tnext ) (not (current-time ?t )))
  )
  
)

