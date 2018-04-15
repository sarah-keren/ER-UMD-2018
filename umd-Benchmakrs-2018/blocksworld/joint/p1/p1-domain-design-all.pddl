(define (domain blocks)
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

(define (domain blocks-design)
  (:requirements :probabilistic-effects :conditional-effects :equality :typing :rewards)
  (:types block time)
  (:predicates (holding ?b - block) (emptyhand) (on-table ?b - block) (on ?b1 ?b2 - block) (clear ?b - block)
	(enabled-safety-pickup-tower ?b1 ?b2 ?b3 - block)
	(enabled-safety-pickup ?b - block)
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

  (:action design-start-execution
    :parameters ()
    :precondition (and (not (execution)))
    :effect (and (execution))
  )

   (:action design-reduce-uncertainty-pickup-tower
    :parameters (?b1 ?b2 ?b3 - block ?t - time ?tnext - time)
    :precondition (and (not (execution))(next ?t ?tnext)(current-time ?t ))
    :effect (and (enabled-safety-pickup-tower ?b1 ?b2 ?b3 )(current-time ?tnext )(not (current-time ?t )))
  )

  (:action design-reduce-uncertainty-pickup
    :parameters (?b - block ?t - time ?tnext - time)
    :precondition (and (not (execution))(next ?t ?tnext)(current-time ?t ))
    :effect (and (enabled-safety-pickup ?b )(current-time ?tnext )(not (current-time ?t )))
  )

)

;;no delete effects

(define (domain blocks-design-relaxed)
  (:requirements :probabilistic-effects :conditional-effects :equality :typing :rewards)
  (:types block time)
  (:predicates (holding ?b - block) (emptyhand) (on-table ?b - block) (on ?b1 ?b2 - block) (clear ?b - block)
	(enabled-safety-pickup-tower ?b1 ?b2 ?b3 - block)
	(enabled-safety-pickup ?b - block)
	(initialization)
	(current-time ?t - time)
	(next ?t1 - time ?t2 - time)	
)

(:action pick-tower-safely
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2) (on ?b2 ?b3)(not(initialization))(enabled-safety-pickup-tower ?b1 ?b2 ?b3))
    :effect
      (probabilistic 1.0 (and (holding ?b2) (clear ?b3)))
 )


 (:action pick-up-safely
    :parameters (?b1 ?b2 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2)(enabled-safety-pickup ?b1)(not(initialization)))
    :effect
      (probabilistic
        1.0 (and (holding ?b1) (clear ?b2) )
      )
  )
  (:action pick-up-from-table-safely
    :parameters (?b - block)
    :precondition (and (emptyhand) (clear ?b) (on-table ?b)(enabled-safety-pickup ?b)(not(initialization)))
    :effect
      (probabilistic 1.0 (and (holding ?b) ))
  )

  (:action pick-up
    :parameters (?b1 ?b2 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2)(not(initialization)))
    :effect
      (probabilistic
        3/4 (and (holding ?b1) (clear ?b2) (not (emptyhand)) (not (on ?b1 ?b2)))
        1/4 (and (clear ?b2) (on-table ?b1) ))
  )
  (:action pick-up-from-table
    :parameters (?b - block)
    :precondition (and (emptyhand) (clear ?b) (on-table ?b)(not(initialization)))
    :effect
      (probabilistic 3/4 (and (holding ?b) ))
  )
  (:action put-on-block
    :parameters (?b1 ?b2 - block)
    :precondition (and (holding ?b1) (clear ?b1) (clear ?b2) (not (= ?b1 ?b2))(not(initialization)))
    :effect (probabilistic 3/4 (and (on ?b1 ?b2) (emptyhand) (clear ?b1) )
                           1/4 (and (on-table ?b1) (emptyhand) (clear ?b1) ))
  )
  (:action put-down
    :parameters (?b - block)
    :precondition (and (holding ?b) (clear ?b)(not(initialization)))
    :effect (and (on-table ?b) (emptyhand) (clear ?b) )
  )
  (:action pick-tower
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (emptyhand) (clear ?b1) (on ?b1 ?b2) (on ?b2 ?b3)(not(initialization)))
    :effect
      (probabilistic 1/10 (and (holding ?b2) (clear ?b3) (not (emptyhand)) ))
  )
  (:action put-tower-on-block
    :parameters (?b1 ?b2 ?b3 - block)
    :precondition (and (holding ?b2) (on ?b1 ?b2) (clear ?b3) (not (= ?b1 ?b3))(not(initialization)))
    :effect (probabilistic 1/10 (and (on ?b2 ?b3) (emptyhand) )
                           9/10 (and (on-table ?b2) (emptyhand) ))
  )
  (:action put-tower-down
    :parameters (?b1 ?b2 - block)
    :precondition (and (holding ?b2) (on ?b1 ?b2)(not(initialization)))
    :effect (and (on-table ?b2) (emptyhand) )
  )

  (:action design-start-execution
    :parameters ()
    :precondition (and (initialization))
    :effect (and (not(initialization)))
  )

   (:action design-reduce-uncertainty-pickup-tower
    :parameters (?b1 ?b2 ?b3 - block ?t - time ?tnext - time)
    :precondition (and (initialization)(next ?t ?tnext)(current-time ?t ))
    :effect (and (enabled-safety-pickup-tower ?b1 ?b2 ?b3 )(current-time ?tnext )(not (current-time ?t )))
  )

  (:action design-reduce-uncertainty-pickup
    :parameters (?b - block ?t - time ?tnext - time)
    :precondition (and (initialization)(next ?t ?tnext)(current-time ?t ))
    :effect (and (enabled-safety-pickup ?b )(current-time ?tnext )(not (current-time ?t )))
  )

)

(define (problem p1)
  (:domain blocks)
  (:objects b1 b2 b3 - block)
  (:init (emptyhand) (on-table b1) (on b2 b3) (on-table b3) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on b1 b2) (on-table b2) (on-table b3) (clear b1) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p1_relaxed)
  (:domain blocks-design-relaxed)
  (:objects t1 - time
 b1 b2 b3 - block)
  (:init (current-time t1)
 (emptyhand) (on-table b1) (on b2 b3) (on-table b3) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on b1 b2) (on-table b2) (on-table b3) (clear b1) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p1_design_0)
  (:domain blocks-design)
  (:objects t1 - time
 b1 b2 b3 - block)
  (:init (current-time t1)
 (emptyhand) (on-table b1) (on b2 b3) (on-table b3) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on b1 b2) (on-table b2) (on-table b3) (clear b1) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p1_design_1_relaxed)
  (:domain blocks-design-relaxed)
  (:objects t1 t2 - time
 b1 b2 b3 - block)
  (:init (current-time t1)(next t1 t2)
 (emptyhand) (on-table b1) (on b2 b3) (on-table b3) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on b1 b2) (on-table b2) (on-table b3) (clear b1) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p1_design_1)
  (:domain blocks-design)
  (:objects t1 t2 - time
 b1 b2 b3 - block)
  (:init (current-time t1)(next t1 t2)
 (emptyhand) (on-table b1) (on b2 b3) (on-table b3) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on b1 b2) (on-table b2) (on-table b3) (clear b1) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p1_design_2_relaxed)
  (:domain blocks-design-relaxed)
  (:objects t1 t2 t3 - time
 b1 b2 b3 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)
 (emptyhand) (on-table b1) (on b2 b3) (on-table b3) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on b1 b2) (on-table b2) (on-table b3) (clear b1) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p1_design_2)
  (:domain blocks-design)
  (:objects t1 t2 t3 - time
 b1 b2 b3 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)
 (emptyhand) (on-table b1) (on b2 b3) (on-table b3) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on b1 b2) (on-table b2) (on-table b3) (clear b1) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p1_design_3_relaxed)
  (:domain blocks-design-relaxed)
  (:objects t1 t2 t3 t4 - time
 b1 b2 b3 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)
 (emptyhand) (on-table b1) (on b2 b3) (on-table b3) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on b1 b2) (on-table b2) (on-table b3) (clear b1) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
(define (problem p1_design_3)
  (:domain blocks-design)
  (:objects t1 t2 t3 t4 - time
 b1 b2 b3 - block)
  (:init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)
 (emptyhand) (on-table b1) (on b2 b3) (on-table b3) (clear b1) (clear b2))
  (:goal (and (emptyhand) (on b1 b2) (on-table b2) (on-table b3) (clear b1) (clear b3)))
  (:goal-reward 1)
  (:metric maximize (reward))
)
