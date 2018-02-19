(define (domain elevators-design)
  (:requirements :probabilistic-effects :conditional-effects :negative-preconditions :equality :typing)
  (:types elevator floor pos coin)
  (:constants f1 - floor p1 - pos)
  (:predicates (dec_f ?f ?g - floor) (dec_p ?p ?q - pos) (in ?e - elevator ?f - floor) (at ?f - floor ?p - pos) (shaft ?e - elevator ?p - pos) (inside ?e - elevator) (gate ?f - floor ?p - pos) (coin-at ?c - coin ?f - floor ?p - pos) (have ?c - coin)
(execution)
(current-time ?t - time)
(next ?t1 - time ?t2 - time)	
(enabled-safety-move ?f - floor ?p - pos ?np - pos)
(enabled-add-shaft ?e - elevator ?p - pos)
(add-shaft ?e - elevator)
(safety-move ?f - floor)
)

  (:action enabled-move-left-safely
    :parameters (?f - floor ?p ?np - pos)
    :precondition (and (at ?f ?p) (dec_p ?p ?np)(execution)(enabled-safety-move ?f ?p ?np))
    :effect (probabilistic 0.85 (and (not (at ?f ?p)) (at ?f ?np))
                           0.15 (and (when (gate ?f ?p) (and (at f1 p1)(not (at ?f ?p))))))
  )
  (:action enabled-move-right-safely
    :parameters (?f - floor ?p ?np - pos)
    :precondition (and (at ?f ?p) (dec_p ?np ?p)(execution)(enabled-safety-move ?f ?p ?np))
    :effect (probabilistic 0.85 (and (not (at ?f ?p)) (at ?f ?np))
                           0.15 (and (when (gate ?f ?p) (and (at f1 p1)(not (at ?f ?p))))))
  )


 (:action enabled-step-in
    :parameters (?e - elevator ?f - floor ?p - pos)
    :precondition (and (at ?f ?p) (in ?e ?f) (enabled-add-shaft ?e ?p)(execution))
    :effect (and (inside ?e) (not (at ?f ?p)))
  )
  (:action enabled-step-out
    :parameters (?e - elevator ?f - floor ?p - pos)
    :precondition (and (inside ?e) (in ?e ?f) (enabled-add-shaft ?e ?p)(execution))
    :effect (and (at ?f ?p) (not (inside ?e)))
  )


  (:action go-up
    :parameters (?e - elevator ?f ?nf - floor)
    :precondition (and (dec_f ?nf ?f) (in ?e ?f)(execution))
    :effect (and (in ?e ?nf) (not (in ?e ?f)))
  )
  (:action go-down
    :parameters (?e - elevator ?f ?nf - floor)
    :precondition (and (dec_f ?f ?nf) (in ?e ?f)(execution))
    :effect (and (in ?e ?nf) (not (in ?e ?f)))
  )
  (:action step-in
    :parameters (?e - elevator ?f - floor ?p - pos)
    :precondition (and (at ?f ?p) (in ?e ?f) (shaft ?e ?p)(execution))
    :effect (and (inside ?e) (not (at ?f ?p)))
  )
  (:action step-out
    :parameters (?e - elevator ?f - floor ?p - pos)
    :precondition (and (inside ?e) (in ?e ?f) (shaft ?e ?p)(execution))
    :effect (and (at ?f ?p) (not (inside ?e)))
  )
  (:action move-left
    :parameters (?f - floor ?p ?np - pos)
    :precondition (and (at ?f ?p) (dec_p ?p ?np)(execution))
    :effect (probabilistic 0.7 (and (not (at ?f ?p)) (at ?f ?np))
                           0.3 (and (when (gate ?f ?p) (and (at f1 p1)(not (at ?f ?p))))))
  )
  (:action move-right
    :parameters (?f - floor ?p ?np - pos)
    :precondition (and (at ?f ?p) (dec_p ?np ?p)(execution))
    :effect (probabilistic 0.7 (and (not (at ?f ?p)) (at ?f ?np))
                           0.3 (and (when (gate ?f ?p) (and (at f1 p1)(not (at ?f ?p))))))
  )



  (:action collect
    :parameters (?c - coin ?f - floor ?p - pos)
    :precondition (and (coin-at ?c ?f ?p) (at ?f ?p)(execution))
    :effect (and (have ?c) (not (coin-at ?c ?f ?p)))
  )



;Design actions

 (:action design-idle
    :parameters ( ?t - time ?tnext - time )
    :precondition (and (not (execution)) (current-time ?t ) (next ?t ?tnext))
    :effect (and (current-time ?tnext ) (not (current-time ?t)))
  )

 (:action design-start-execution
    :parameters ()
    :precondition (not(execution))
    :effect (and (execution))
  )

   (:action design-reduce-uncertainty-move
    :parameters (?f - floor ?p - pos ?np - pos ?t1 - time ?tnext - time)
    :precondition (and (not(execution))(next ?t1 ?tnext)(current-time ?t1 ))
    :effect (and (enabled-safety-move ?f ?p ?np)(safety-move ?f)(current-time ?tnext )(not (current-time ?t1 )))
  )

 (:action design-add-shaft
    :parameters (?e - elevator ?p - pos ?t - time ?tnext - time)
    :precondition (and (not(execution))(next ?t ?tnext)(current-time ?t ))
    :effect (and(current-time ?tnext )(not (current-time ?t ))(enabled-add-shaft ?e ?p )(add-shaft ?e))
  )




)
