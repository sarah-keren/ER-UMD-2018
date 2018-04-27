;; Authors: Michael Littman and David Weissman
;; Modified by: Blai Bonet

;; Comment: Good plans are those that avoid putting blocks on table since the probability of detonation is higher

(define (domain exploding-blocksworld-design)
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
   :precondition (and (holding ?b) (no-destroyed-table) (enabled-safety-put-down ?b) (execution))
   :effect (and (emptyhand) (on-table ?b) (not (holding ?b)))
  )
  
  (:action put-on-block-enabled
   :parameters (?b1 ?b2 - block)
   :precondition (and (holding ?b1) (clear ?b2) (no-destroyed ?b2) (enabled-safety-put-on-block ?b1 ?b2) (execution))
   :effect (and (emptyhand) (on ?b1 ?b2) (not (holding ?b1)) (not (clear ?b2)))
  )
  


  (:action pick-up
   :parameters (?b1 ?b2 - block)
   :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2) (no-destroyed ?b1)(execution))
   :effect (and (holding ?b1) (clear ?b2) (not (emptyhand)) (not (on ?b1 ?b2)))
  )
 
 (:action pick-up-from-table
   :parameters (?b - block)
   :precondition (and (emptyhand) (clear ?b) (on-table ?b) (no-destroyed ?b)(execution))
   :effect (and (holding ?b) (not (emptyhand)) (not (on-table ?b)))
  )
  
  (:action put-down
   :parameters (?b - block)
   :precondition (and (holding ?b) (no-destroyed-table)(execution))
   :effect (and (emptyhand) (on-table ?b) (not (holding ?b))
                (probabilistic 0.4 (when (no-detonated ?b) (and (not (no-destroyed-table)) (not (no-detonated ?b))))))
  )
  
  (:action put-on-block
   :parameters (?b1 ?b2 - block)
   :precondition (and (holding ?b1) (clear ?b2) (no-destroyed ?b2)(execution))
   :effect (and (emptyhand) (on ?b1 ?b2) (not (holding ?b1)) (not (clear ?b2))
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

;; Authors: Michael Littman and David Weissman
;; Modified by: Blai Bonet

;; Comment: Good plans are those that avoid putting blocks on table since the probability of detonation is higher

(define (domain exploding-blocksworld)
  (:requirements :typing :conditional-effects :probabilistic-effects :equality :rewards)
  (:types block time)
  (:predicates (on ?b1 ?b2 - block) (on-table ?b - block) (clear ?b - block) (holding ?b - block) (emptyhand) (no-detonated ?b - block) (no-destroyed ?b - block) (no-destroyed-table)
)

  (:action pick-up
   :parameters (?b1 ?b2 - block)
   :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2) (no-destroyed ?b1))
   :effect (and (holding ?b1) (clear ?b2) (not (emptyhand)) (not (on ?b1 ?b2)))
  )
 
 (:action pick-up-from-table
   :parameters (?b - block)
   :precondition (and (emptyhand) (clear ?b) (on-table ?b) (no-destroyed ?b))
   :effect (and (holding ?b) (not (emptyhand)) (not (on-table ?b)))
  )
  
  (:action put-down
   :parameters (?b - block)
   :precondition (and (holding ?b) (no-destroyed-table))
   :effect (and (emptyhand) (on-table ?b) (not (holding ?b))
                (probabilistic 0.4 (when (no-detonated ?b) (and (not (no-destroyed-table)) (not (no-detonated ?b))))))
  )
  
  (:action put-on-block
   :parameters (?b1 ?b2 - block)
   :precondition (and (holding ?b1) (clear ?b2) (no-destroyed ?b2))
   :effect (and (emptyhand) (on ?b1 ?b2) (not (holding ?b1)) (not (clear ?b2))
                (probabilistic 0.1 (when (no-detonated ?b1) (and (not (no-destroyed ?b2)) (not (no-detonated ?b1))))))
  )
  
  
)

;; Authors: Michael Littman and David Weissman
;; Modified by: Blai Bonet

;; Comment: Good plans are those that avoid putting blocks on table since the probability of detonation is higher

(define (domain exploding-blocksworld-design-relaxed)
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
   :precondition (and (holding ?b) (no-destroyed-table) (enabled-safety-put-down ?b) (execution))
   :effect (and (emptyhand) (on-table ?b) )
  )
  
  (:action put-on-block-enabled
   :parameters (?b1 ?b2 - block)
   :precondition (and (holding ?b1) (clear ?b2) (no-destroyed ?b2) (enabled-safety-put-on-block ?b1 ?b2) (execution))
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

;; Authors: Michael Littman and David Weissman
;; Modified by: Blai Bonet

;; Comment: Good plans are those that avoid putting blocks on table since the probability of detonation is higher

(define (domain exploding-blocksworld-design-over)
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
   :effect (and (emptyhand) (on-table ?b) (not (holding ?b)))
  )
  
  (:action put-on-block-enabled
   :parameters (?b1 ?b2 - block)
   :precondition (and (holding ?b1) (clear ?b2) (no-destroyed ?b2) (safety-put-on-block ?b1 ) (execution))
   :effect (and (emptyhand) (on ?b1 ?b2) (not (holding ?b1)) (not (clear ?b2)))
  )
  


  (:action pick-up
   :parameters (?b1 ?b2 - block)
   :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2) (no-destroyed ?b1)(execution))
   :effect (and (holding ?b1) (clear ?b2) (not (emptyhand)) (not (on ?b1 ?b2)))
  )
 
 (:action pick-up-from-table
   :parameters (?b - block)
   :precondition (and (emptyhand) (clear ?b) (on-table ?b) (no-destroyed ?b)(execution))
   :effect (and (holding ?b) (not (emptyhand)) (not (on-table ?b)))
  )
  
  (:action put-down
   :parameters (?b - block)
   :precondition (and (holding ?b) (no-destroyed-table)(execution))
   :effect (and (emptyhand) (on-table ?b) (not (holding ?b))
                (probabilistic 0.4 (when (no-detonated ?b) (and (not (no-destroyed-table)) (not (no-detonated ?b))))))
  )
  
  (:action put-on-block
   :parameters (?b1 ?b2 - block)
   :precondition (and (holding ?b1) (clear ?b2) (no-destroyed ?b2)(execution))
   :effect (and (emptyhand) (on ?b1 ?b2) (not (holding ?b1)) (not (clear ?b2))
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

(define (problem p2)
  (:domain exploding-blocksworld)
  (:objects b1 b2 b3 b4 - block)
  (:init (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2)
  (:domain exploding-blocksworld)
  (:objects b1 b2 b3 b4 - block)
  (:init (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-0-design)
  (:domain exploding-blocksworld-design)
  (:objects t1 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-0-design-relaxed)
  (:domain exploding-blocksworld-design-relaxed)
  (:objects t1 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-0-design-over)
  (:domain exploding-blocksworld-design-over)
  (:objects t1 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-0-design-over-relaxed)
  (:domain exploding-blocksworld-design-over-relaxed)
  (:objects t1 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-0-design-tip)
  (:domain exploding-blocksworld-design)
  (:objects t1 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-1-design)
  (:domain exploding-blocksworld-design)
  (:objects t1 t2 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-1-design-relaxed)
  (:domain exploding-blocksworld-design-relaxed)
  (:objects t1 t2 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-1-design-over)
  (:domain exploding-blocksworld-design-over)
  (:objects t1 t2 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-1-design-over-relaxed)
  (:domain exploding-blocksworld-design-over-relaxed)
  (:objects t1 t2 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-1-design-tip)
  (:domain exploding-blocksworld-design)
  (:objects t1 t2 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-2-design)
  (:domain exploding-blocksworld-design)
  (:objects t1 t2 t3 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-2-design-relaxed)
  (:domain exploding-blocksworld-design-relaxed)
  (:objects t1 t2 t3 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-2-design-over)
  (:domain exploding-blocksworld-design-over)
  (:objects t1 t2 t3 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-2-design-over-relaxed)
  (:domain exploding-blocksworld-design-over-relaxed)
  (:objects t1 t2 t3 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-2-design-tip)
  (:domain exploding-blocksworld-design)
  (:objects t1 t2 t3 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-3-design)
  (:domain exploding-blocksworld-design)
  (:objects t1 t2 t3 t4 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-3-design-relaxed)
  (:domain exploding-blocksworld-design-relaxed)
  (:objects t1 t2 t3 t4 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-3-design-over)
  (:domain exploding-blocksworld-design-over)
  (:objects t1 t2 t3 t4 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-3-design-over-relaxed)
  (:domain exploding-blocksworld-design-over-relaxed)
  (:objects t1 t2 t3 t4 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-3-design-tip)
  (:domain exploding-blocksworld-design)
  (:objects t1 t2 t3 t4 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-4-design)
  (:domain exploding-blocksworld-design)
  (:objects t1 t2 t3 t4 t5 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-4-design-relaxed)
  (:domain exploding-blocksworld-design-relaxed)
  (:objects t1 t2 t3 t4 t5 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-4-design-over)
  (:domain exploding-blocksworld-design-over)
  (:objects t1 t2 t3 t4 t5 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-4-design-over-relaxed)
  (:domain exploding-blocksworld-design-over-relaxed)
  (:objects t1 t2 t3 t4 t5 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-4-design-tip)
  (:domain exploding-blocksworld-design)
  (:objects t1 t2 t3 t4 t5 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-5-design)
  (:domain exploding-blocksworld-design)
  (:objects t1 t2 t3 t4 t5 t6 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-5-design-relaxed)
  (:domain exploding-blocksworld-design-relaxed)
  (:objects t1 t2 t3 t4 t5 t6 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-5-design-over)
  (:domain exploding-blocksworld-design-over)
  (:objects t1 t2 t3 t4 t5 t6 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-5-design-over-relaxed)
  (:domain exploding-blocksworld-design-over-relaxed)
  (:objects t1 t2 t3 t4 t5 t6 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-5-design-tip)
  (:domain exploding-blocksworld-design)
  (:objects t1 t2 t3 t4 t5 t6 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-6-design)
  (:domain exploding-blocksworld-design)
  (:objects t1 t2 t3 t4 t5 t6 t7 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)(next t6 t7)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-6-design-relaxed)
  (:domain exploding-blocksworld-design-relaxed)
  (:objects t1 t2 t3 t4 t5 t6 t7 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)(next t6 t7)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-6-design-over)
  (:domain exploding-blocksworld-design-over)
  (:objects t1 t2 t3 t4 t5 t6 t7 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)(next t6 t7)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-6-design-over-relaxed)
  (:domain exploding-blocksworld-design-over-relaxed)
  (:objects t1 t2 t3 t4 t5 t6 t7 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)(next t6 t7)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p2-6-design-tip)
  (:domain exploding-blocksworld-design)
  (:objects t1 t2 t3 t4 t5 t6 t7 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)(next t6 t7)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2)
 (no-detonated b1) (no-destroyed b1) (no-detonated b2) (no-destroyed b2) (no-detonated b3) (no-destroyed b3) (no-detonated b4) (no-destroyed b4) (no-destroyed-table))
  (:goal (and (emptyhand) (on-table b1) (on b2 b4) (on b3 b1) (on-table b4) (clear b2) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
