(define (domain blocks-domain-design)
  (:requirements :probabilistic-effects :conditional-effects :equality :typing :rewards)
  (:types block time)
  (:predicates (holding ?b - block) (emptyhand) (on-table ?b - block) (on ?b1 ?b2 - block) (clear ?b - block)
	(enabled-safety-pickup-tower ?b1 ?b2 ?b3 - block)
	(enabled-safety-pickup ?b - block)
	(safety-pickup)
	(safety-pickup-tower)
	(execution)
	(current-time ?t - time)
	(next ?t1 - time ?t2 - time)	
)

  (:action pick-tower-safely
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2) (on ?b2 ?b3)(execution)(enabled-safety-pickup-tower ?b1 ?b2 ?b3))
    :effect
      (probabilistic 1.0 (and (holding ?b2) (clear ?b3) (not (emptyhand)) (not (on ?b2 ?b3))))
  )


 (:action pick-up-safely
    :parameters (?b1 ?b2 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2)(enabled-safety-pickup ?b1)(execution))
    :effect
      (probabilistic
        1.0 (and (holding ?b1) (clear ?b2) (not (emptyhand)) (not (on ?b1 ?b2)))
      )
  )
  (:action pick-up-from-table-safely
    :parameters (?b - block)
    :precondition (and (emptyhand) (clear ?b) (on-table ?b)(enabled-safety-pickup ?b)(execution))
    :effect
      (probabilistic 1.0 (and (holding ?b) (not (emptyhand)) (not (on-table ?b))))
  )

  (:action pick-up
    :parameters (?b1 ?b2 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2)(execution))
    :effect
      (probabilistic
        3/4 (and (holding ?b1) (clear ?b2) (not (emptyhand)) (not (on ?b1 ?b2)))
        1/4 (and (clear ?b2) (on-table ?b1) (not (on ?b1 ?b2))))
  )
  (:action pick-up-from-table
    :parameters (?b - block)
    :precondition (and (emptyhand) (clear ?b) (on-table ?b)(execution))
    :effect
      (probabilistic 3/4 (and (holding ?b) (not (emptyhand)) (not (on-table ?b))))
  )
  (:action put-on-block
    :parameters (?b1 ?b2 - block)
    :precondition (and (holding ?b1) (clear ?b1) (clear ?b2) (not (= ?b1 ?b2))(execution))
    :effect (probabilistic 3/4 (and (on ?b1 ?b2) (emptyhand) (clear ?b1) (not (holding ?b1)) (not (clear ?b2)))
                           1/4 (and (on-table ?b1) (emptyhand) (clear ?b1) (not (holding ?b1))))
  )
  (:action put-down
    :parameters (?b - block)
    :precondition (and (holding ?b) (clear ?b)(execution))
    :effect (and (on-table ?b) (emptyhand) (clear ?b) (not (holding ?b)))
  )
  (:action pick-tower
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2) (on ?b2 ?b3)(execution))
    :effect
      (probabilistic 1/10 (and (holding ?b2) (clear ?b3) (not (emptyhand)) (not (on ?b2 ?b3))))
  )
  (:action put-tower-on-block
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (holding ?b2) (on ?b1 ?b2) (clear ?b3) (not (= ?b1 ?b3))(execution))
    :effect (probabilistic 1/10 (and (on ?b2 ?b3) (emptyhand) (not (holding ?b2)) (not (clear ?b3)))
                           9/10 (and (on-table ?b2) (emptyhand) (not (holding ?b2))))
  )
  (:action put-tower-down
    :parameters (?b1 ?b2 - block)
    :precondition (and (holding ?b2) (on ?b1 ?b2)(execution))
    :effect (and (on-table ?b2) (emptyhand) (not (holding ?b2)))
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

   (:action design-reduce-uncertainty-pickup-tower
    :parameters (?b1 ?b2 ?b3 - block ?t - time ?tnext - time)
    :precondition (and (not (execution))(next ?t ?tnext)(current-time ?t ))
    :effect (and (enabled-safety-pickup-tower ?b1 ?b2 ?b3 )(safety-pickup-tower)(current-time ?tnext )(not (current-time ?t )))
  )

  (:action design-reduce-uncertainty-pickup
    :parameters (?b - block ?t - time ?tnext - time)
    :precondition (and (not (execution))(next ?t ?tnext)(current-time ?t ))
    :effect (and (enabled-safety-pickup ?b )(safety-pickup)(current-time ?tnext )(not (current-time ?t )))
  )

)

(define (domain blocks-domain)
  (:requirements :probabilistic-effects :conditional-effects :equality :typing :rewards)
  (:types block)
  (:predicates (holding ?b - block) (emptyhand) (on-table ?b - block) (on ?b1 ?b2 - block) (clear ?b - block))
  (:action pick-up
    :parameters (?b1 ?b2 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2))
    :effect
      (probabilistic
        3/4 (and (holding ?b1) (clear ?b2) (not (emptyhand)) (not (on ?b1 ?b2)))
        1/4 (and (clear ?b2) (on-table ?b1) (not (on ?b1 ?b2))))
  )
  (:action pick-up-from-table
    :parameters (?b - block)
    :precondition (and (emptyhand) (clear ?b) (on-table ?b))
    :effect
      (probabilistic 3/4 (and (holding ?b) (not (emptyhand)) (not (on-table ?b))))
  )
  (:action put-on-block
    :parameters (?b1 ?b2 - block)
    :precondition (and (holding ?b1) (clear ?b1) (clear ?b2) (not (= ?b1 ?b2)))
    :effect (probabilistic 3/4 (and (on ?b1 ?b2) (emptyhand) (clear ?b1) (not (holding ?b1)) (not (clear ?b2)))
                           1/4 (and (on-table ?b1) (emptyhand) (clear ?b1) (not (holding ?b1))))
  )
  (:action put-down
    :parameters (?b - block)
    :precondition (and (holding ?b) (clear ?b))
    :effect (and (on-table ?b) (emptyhand) (clear ?b) (not (holding ?b)))
  )
  (:action pick-tower
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2) (on ?b2 ?b3))
    :effect
      (probabilistic 1/10 (and (holding ?b2) (clear ?b3) (not (emptyhand)) (not (on ?b2 ?b3))))
  )
  (:action put-tower-on-block
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (holding ?b2) (on ?b1 ?b2) (clear ?b3) (not (= ?b1 ?b3)))
    :effect (probabilistic 1/10 (and (on ?b2 ?b3) (emptyhand) (not (holding ?b2)) (not (clear ?b3)))
                           9/10 (and (on-table ?b2) (emptyhand) (not (holding ?b2))))
  )
  (:action put-tower-down
    :parameters (?b1 ?b2 - block)
    :precondition (and (holding ?b2) (on ?b1 ?b2))
    :effect (and (on-table ?b2) (emptyhand) (not (holding ?b2)))
  )
)

(define (domain blocks-domain-design-relaxed)
  (:requirements :probabilistic-effects :conditional-effects :equality :typing :rewards)
  (:types block time)
  (:predicates (holding ?b - block) (emptyhand) (on-table ?b - block) (on ?b1 ?b2 - block) (clear ?b - block)
	(enabled-safety-pickup-tower ?b1 ?b2 ?b3 - block)
	(enabled-safety-pickup ?b - block)
	(safety-pickup)
	(safety-pickup-tower)
	(execution)
	(current-time ?t - time)
	(next ?t1 - time ?t2 - time)	
)

  (:action pick-tower-safely
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2) (on ?b2 ?b3)(execution)(enabled-safety-pickup-tower ?b1 ?b2 ?b3))
    :effect
      (probabilistic 1.0 (and (holding ?b2) (clear ?b3) ))
  )


 (:action pick-up-safely
    :parameters (?b1 ?b2 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2)(enabled-safety-pickup ?b1)(execution))
    :effect
      (probabilistic
        1.0 (and (holding ?b1) (clear ?b2)  (not (on ?b1 ?b2)))
      )
  )
  (:action pick-up-from-table-safely
    :parameters (?b - block)
    :precondition (and (emptyhand) (clear ?b) (on-table ?b)(enabled-safety-pickup ?b)(execution))
    :effect
      (probabilistic 1.0 (and (holding ?b)  ))
  )

  (:action pick-up
    :parameters (?b1 ?b2 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2)(execution))
    :effect
      (probabilistic
        3/4 (and (holding ?b1) (clear ?b2)  (not (on ?b1 ?b2)))
        1/4 (and (clear ?b2) (on-table ?b1) (not (on ?b1 ?b2))))
  )
  (:action pick-up-from-table
    :parameters (?b - block)
    :precondition (and (emptyhand) (clear ?b) (on-table ?b)(execution))
    :effect
      (probabilistic 3/4 (and (holding ?b)  ))
  )
  (:action put-on-block
    :parameters (?b1 ?b2 - block)
    :precondition (and (holding ?b1) (clear ?b1) (clear ?b2) (not (= ?b1 ?b2))(execution))
    :effect (probabilistic 3/4 (and (on ?b1 ?b2) (emptyhand) (clear ?b1) (not (holding ?b1)) (not (clear ?b2)))
                           1/4 (and (on-table ?b1) (emptyhand) (clear ?b1) (not (holding ?b1))))
  )
  (:action put-down
    :parameters (?b - block)
    :precondition (and (holding ?b) (clear ?b)(execution))
    :effect (and (on-table ?b) (emptyhand) (clear ?b) (not (holding ?b)))
  )
  (:action pick-tower
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2) (on ?b2 ?b3)(execution))
    :effect
      (probabilistic 1/10 (and (holding ?b2) (clear ?b3) ))
  )
  (:action put-tower-on-block
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (holding ?b2) (on ?b1 ?b2) (clear ?b3) (not (= ?b1 ?b3))(execution))
    :effect (probabilistic 1/10 (and (on ?b2 ?b3) (emptyhand) (not (holding ?b2)) (not (clear ?b3)))
                           9/10 (and (on-table ?b2) (emptyhand) (not (holding ?b2))))
  )
  (:action put-tower-down
    :parameters (?b1 ?b2 - block)
    :precondition (and (holding ?b2) (on ?b1 ?b2)(execution))
    :effect (and (on-table ?b2) (emptyhand) (not (holding ?b2)))
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

   (:action design-reduce-uncertainty-pickup-tower
    :parameters (?b1 ?b2 ?b3 - block ?t - time ?tnext - time)
    :precondition (and (not (execution))(next ?t ?tnext)(current-time ?t ))
    :effect (and (enabled-safety-pickup-tower ?b1 ?b2 ?b3 )(safety-pickup-tower)(current-time ?tnext )(not (current-time ?t )))
  )

  (:action design-reduce-uncertainty-pickup
    :parameters (?b - block ?t - time ?tnext - time)
    :precondition (and (not (execution))(next ?t ?tnext)(current-time ?t ))
    :effect (and (enabled-safety-pickup ?b )(safety-pickup)(current-time ?tnext )(not (current-time ?t )))
  )

)

(define (domain blocks-domain-design-over)
  (:requirements :probabilistic-effects :conditional-effects :equality :typing :rewards)
  (:types block time)
  (:predicates (holding ?b - block) (emptyhand) (on-table ?b - block) (on ?b1 ?b2 - block) (clear ?b - block)
	(enabled-safety-pickup-tower ?b1 ?b2 ?b3 - block)
	(enabled-safety-pickup ?b - block)
	(safety-pickup)
	(safety-pickup-tower)
	(execution)
	(current-time ?t - time)
	(next ?t1 - time ?t2 - time)	
)

  (:action pick-tower-safely
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2) (on ?b2 ?b3)(execution)(enabled-safety-pickup-tower ?b1 ?b2 ?b3))
    :effect
      (probabilistic 1.0 (and (holding ?b2) (clear ?b3) (not (emptyhand)) (not (on ?b2 ?b3))))
  )


 (:action pick-up-safely
    :parameters (?b1 ?b2 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2)(enabled-safety-pickup ?b1)(execution))
    :effect
      (probabilistic
        1.0 (and (holding ?b1) (clear ?b2) (not (emptyhand)) (not (on ?b1 ?b2)))
      )
  )
  (:action pick-up-from-table-safely
    :parameters (?b - block)
    :precondition (and (emptyhand) (clear ?b) (on-table ?b)(enabled-safety-pickup ?b)(execution))
    :effect
      (probabilistic 1.0 (and (holding ?b) (not (emptyhand)) (not (on-table ?b))))
  )

  (:action pick-up
    :parameters (?b1 ?b2 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2)(execution))
    :effect
      (probabilistic
        3/4 (and (holding ?b1) (clear ?b2) (not (emptyhand)) (not (on ?b1 ?b2)))
        1/4 (and (clear ?b2) (on-table ?b1) (not (on ?b1 ?b2))))
  )
  (:action pick-up-from-table
    :parameters (?b - block)
    :precondition (and (emptyhand) (clear ?b) (on-table ?b)(execution))
    :effect
      (probabilistic 3/4 (and (holding ?b) (not (emptyhand)) (not (on-table ?b))))
  )
  (:action put-on-block
    :parameters (?b1 ?b2 - block)
    :precondition (and (holding ?b1) (clear ?b1) (clear ?b2) (not (= ?b1 ?b2))(execution))
    :effect (probabilistic 3/4 (and (on ?b1 ?b2) (emptyhand) (clear ?b1) (not (holding ?b1)) (not (clear ?b2)))
                           1/4 (and (on-table ?b1) (emptyhand) (clear ?b1) (not (holding ?b1))))
  )
  (:action put-down
    :parameters (?b - block)
    :precondition (and (holding ?b) (clear ?b)(execution))
    :effect (and (on-table ?b) (emptyhand) (clear ?b) (not (holding ?b)))
  )
  (:action pick-tower
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2) (on ?b2 ?b3)(execution))
    :effect
      (probabilistic 1/10 (and (holding ?b2) (clear ?b3) (not (emptyhand)) (not (on ?b2 ?b3))))
  )
  (:action put-tower-on-block
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (holding ?b2) (on ?b1 ?b2) (clear ?b3) (not (= ?b1 ?b3))(execution))
    :effect (probabilistic 1/10 (and (on ?b2 ?b3) (emptyhand) (not (holding ?b2)) (not (clear ?b3)))
                           9/10 (and (on-table ?b2) (emptyhand) (not (holding ?b2))))
  )
  (:action put-tower-down
    :parameters (?b1 ?b2 - block)
    :precondition (and (holding ?b2) (on ?b1 ?b2)(execution))
    :effect (and (on-table ?b2) (emptyhand) (not (holding ?b2)))
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

   (:action design-reduce-uncertainty-pickup-tower
    :parameters (?b1 ?b2 ?b3 - block ?t - time ?tnext - time)
    :precondition (and (not (execution))(next ?t ?tnext)(current-time ?t ))
    :effect (and (enabled-safety-pickup-tower ?b1 ?b2 ?b3 )(safety-pickup-tower)(current-time ?tnext )(not (current-time ?t )))
  )

  (:action design-reduce-uncertainty-pickup
    :parameters (?b - block ?t - time ?tnext - time)
    :precondition (and (not (execution))(next ?t ?tnext)(current-time ?t ))
    :effect (and (enabled-safety-pickup ?b )(safety-pickup)(current-time ?tnext )(not (current-time ?t )))
  )

)

(define (domain blocks-domain-design-over-relaxed)
  (:requirements :probabilistic-effects :conditional-effects :equality :typing :rewards)
  (:types block time)
  (:predicates (holding ?b - block) (emptyhand) (on-table ?b - block) (on ?b1 ?b2 - block) (clear ?b - block)
	(enabled-safety-pickup-tower ?b1 ?b2 ?b3 - block)
	(enabled-safety-pickup ?b - block)
	(safety-pickup)
	(safety-pickup-tower)
	(execution)
	(current-time ?t - time)
	(next ?t1 - time ?t2 - time)	
)

  (:action pick-tower-safely
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2) (on ?b2 ?b3)(execution)(safety-pickup-tower))
    :effect
      (probabilistic 1.0 (and (holding ?b2) (clear ?b3) ))
  )


 (:action pick-up-safely
    :parameters (?b1 ?b2 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2)(safety-pickup)(execution))
    :effect
      (probabilistic
        1.0 (and (holding ?b1) (clear ?b2)  (not (on ?b1 ?b2)))
      )
  )
  (:action pick-up-from-table-safely
    :parameters (?b - block)
    :precondition (and (emptyhand) (clear ?b) (on-table ?b)(safety-pickup)(execution))
    :effect
      (probabilistic 1.0 (and (holding ?b)  ))
  )

  (:action pick-up
    :parameters (?b1 ?b2 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2)(execution))
    :effect
      (probabilistic
        3/4 (and (holding ?b1) (clear ?b2)  (not (on ?b1 ?b2)))
        1/4 (and (clear ?b2) (on-table ?b1) (not (on ?b1 ?b2))))
  )
  (:action pick-up-from-table
    :parameters (?b - block)
    :precondition (and (emptyhand) (clear ?b) (on-table ?b)(execution))
    :effect
      (probabilistic 3/4 (and (holding ?b)  ))
  )
  (:action put-on-block
    :parameters (?b1 ?b2 - block)
    :precondition (and (holding ?b1) (clear ?b1) (clear ?b2) (not (= ?b1 ?b2))(execution))
    :effect (probabilistic 3/4 (and (on ?b1 ?b2) (emptyhand) (clear ?b1) (not (holding ?b1)) (not (clear ?b2)))
                           1/4 (and (on-table ?b1) (emptyhand) (clear ?b1) (not (holding ?b1))))
  )
  (:action put-down
    :parameters (?b - block)
    :precondition (and (holding ?b) (clear ?b)(execution))
    :effect (and (on-table ?b) (emptyhand) (clear ?b) (not (holding ?b)))
  )
  (:action pick-tower
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2) (on ?b2 ?b3)(execution))
    :effect
      (probabilistic 1/10 (and (holding ?b2) (clear ?b3) ))
  )
  (:action put-tower-on-block
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (holding ?b2) (on ?b1 ?b2) (clear ?b3) (not (= ?b1 ?b3))(execution))
    :effect (probabilistic 1/10 (and (on ?b2 ?b3) (emptyhand) (not (holding ?b2)) (not (clear ?b3)))
                           9/10 (and (on-table ?b2) (emptyhand) (not (holding ?b2))))
  )
  (:action put-tower-down
    :parameters (?b1 ?b2 - block)
    :precondition (and (holding ?b2) (on ?b1 ?b2)(execution))
    :effect (and (on-table ?b2) (emptyhand) (not (holding ?b2)))
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

   (:action design-reduce-uncertainty-pickup-tower
    :parameters (?b1 ?b2 ?b3 - block ?t - time ?tnext - time)
    :precondition (and (not (execution))(next ?t ?tnext)(current-time ?t ))
    :effect (and (enabled-safety-pickup-tower ?b1 ?b2 ?b3 )(safety-pickup-tower)(current-time ?tnext )(not (current-time ?t )))
  )

  (:action design-reduce-uncertainty-pickup
    :parameters (?b - block ?t - time ?tnext - time)
    :precondition (and (not (execution))(next ?t ?tnext)(current-time ?t ))
    :effect (and (enabled-safety-pickup ?b )(safety-pickup)(current-time ?tnext )(not (current-time ?t )))
  )

)

(define (problem p3)
  (:domain blocks-domain)
  (:objects b1 b2 b3 b4 - block)
  (:init (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3)
  (:domain blocks-domain)
  (:objects b1 b2 b3 b4 - block)
  (:init (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-0-design)
  (:domain blocks-domain-design)
  (:objects t1 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-0-design-relaxed)
  (:domain blocks-domain-design-relaxed)
  (:objects t1 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-0-design-over)
  (:domain blocks-domain-design-over)
  (:objects t1 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-0-design-over-relaxed)
  (:domain blocks-domain-design-over-relaxed)
  (:objects t1 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-0-design-tip)
  (:domain blocks-domain-design)
  (:objects t1 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-1-design)
  (:domain blocks-domain-design)
  (:objects t1 t2 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-1-design-relaxed)
  (:domain blocks-domain-design-relaxed)
  (:objects t1 t2 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-1-design-over)
  (:domain blocks-domain-design-over)
  (:objects t1 t2 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-1-design-over-relaxed)
  (:domain blocks-domain-design-over-relaxed)
  (:objects t1 t2 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-1-design-tip)
  (:domain blocks-domain-design)
  (:objects t1 t2 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-2-design)
  (:domain blocks-domain-design)
  (:objects t1 t2 t3 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-2-design-relaxed)
  (:domain blocks-domain-design-relaxed)
  (:objects t1 t2 t3 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-2-design-over)
  (:domain blocks-domain-design-over)
  (:objects t1 t2 t3 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-2-design-over-relaxed)
  (:domain blocks-domain-design-over-relaxed)
  (:objects t1 t2 t3 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-2-design-tip)
  (:domain blocks-domain-design)
  (:objects t1 t2 t3 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-3-design)
  (:domain blocks-domain-design)
  (:objects t1 t2 t3 t4 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-3-design-relaxed)
  (:domain blocks-domain-design-relaxed)
  (:objects t1 t2 t3 t4 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-3-design-over)
  (:domain blocks-domain-design-over)
  (:objects t1 t2 t3 t4 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-3-design-over-relaxed)
  (:domain blocks-domain-design-over-relaxed)
  (:objects t1 t2 t3 t4 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-3-design-tip)
  (:domain blocks-domain-design)
  (:objects t1 t2 t3 t4 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-4-design)
  (:domain blocks-domain-design)
  (:objects t1 t2 t3 t4 t5 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-4-design-relaxed)
  (:domain blocks-domain-design-relaxed)
  (:objects t1 t2 t3 t4 t5 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-4-design-over)
  (:domain blocks-domain-design-over)
  (:objects t1 t2 t3 t4 t5 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-4-design-over-relaxed)
  (:domain blocks-domain-design-over-relaxed)
  (:objects t1 t2 t3 t4 t5 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-4-design-tip)
  (:domain blocks-domain-design)
  (:objects t1 t2 t3 t4 t5 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-5-design)
  (:domain blocks-domain-design)
  (:objects t1 t2 t3 t4 t5 t6 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-5-design-relaxed)
  (:domain blocks-domain-design-relaxed)
  (:objects t1 t2 t3 t4 t5 t6 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-5-design-over)
  (:domain blocks-domain-design-over)
  (:objects t1 t2 t3 t4 t5 t6 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-5-design-over-relaxed)
  (:domain blocks-domain-design-over-relaxed)
  (:objects t1 t2 t3 t4 t5 t6 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-5-design-tip)
  (:domain blocks-domain-design)
  (:objects t1 t2 t3 t4 t5 t6 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-6-design)
  (:domain blocks-domain-design)
  (:objects t1 t2 t3 t4 t5 t6 t7 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)(next t6 t7)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-6-design-relaxed)
  (:domain blocks-domain-design-relaxed)
  (:objects t1 t2 t3 t4 t5 t6 t7 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)(next t6 t7)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-6-design-over)
  (:domain blocks-domain-design-over)
  (:objects t1 t2 t3 t4 t5 t6 t7 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)(next t6 t7)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-6-design-over-relaxed)
  (:domain blocks-domain-design-over-relaxed)
  (:objects t1 t2 t3 t4 t5 t6 t7 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)(next t6 t7)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p3-6-design-tip)
  (:domain blocks-domain-design)
  (:objects t1 t2 t3 t4 t5 t6 t7 - time
 b1 b2 b3 b4 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)(next t6 t7)
 (emptyhand) (on b1 b3) (on-table b2) (on b3 b4) (on-table b4) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on-table b3) (on b2 b4) (on b1 b3) (on-table b4) (clear b2) (clear b1)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
