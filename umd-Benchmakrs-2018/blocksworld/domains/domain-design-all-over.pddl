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

