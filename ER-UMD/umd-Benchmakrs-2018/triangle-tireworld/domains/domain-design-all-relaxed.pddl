(define (domain triangle-tire-design-relaxed)
  (:requirements :typing :strips :equality :probabilistic-effects :rewards)

  (:types location time)

  (:predicates
	       (vehicle-at ?loc - location)
	       (spare-in ?loc - location)
	       (road ?from - location ?to - location)
	       (not-flattire) (hasspare)
	       (execution)
	       (current-time ?t - time)
	       (next ?t1 - time ?t2 - time)
	       (enabled-safety ?from - location ?to - location)
	       (enabled-shortcut ?from - location ?to - location)
	       (enabled-safety-from ?from - location)
	       (enabled-shortcut-from ?from - location)

	

	       		
  )


  (:action move-car-enabled
    :parameters (?from - location ?to - location)
    :precondition (and (vehicle-at ?from) (enabled-shortcut ?from ?to )(not-flattire)(execution))
    :effect (and (vehicle-at ?to) 
		 (probabilistic 0.5 (not (not-flattire))))
  )

   (:action move-car-safely-enabled
    :parameters (?from - location ?to - location)
    :precondition (and (vehicle-at ?from) (road ?from ?to) (not-flattire)(execution)(enabled-safety ?from ?to ))
    :effect (and (vehicle-at ?to) 
		 (probabilistic 0.25 (not (not-flattire))))
  )

  (:action move-car
    :parameters (?from - location ?to - location)
    :precondition (and (vehicle-at ?from) (road ?from ?to) (not-flattire)(execution))
    :effect (and (vehicle-at ?to) 
		 (probabilistic 0.5 (not (not-flattire))))
  )



  (:action loadtire
    :parameters (?loc - location)
    :precondition (and (vehicle-at ?loc) (spare-in ?loc)(execution))
    :effect (and (hasspare) )
  )
  
  (:action changetire
    :precondition (and(hasspare) (execution))
    :effect (and (not-flattire))
  )
  

  

  (:action design-start-execution
    :parameters ()
    :precondition (and (not(execution)))
    :effect (and (execution))
  )

  (:action idle-design
    :parameters ( ?t - time ?tnext - time )
    :precondition (and (not(execution))(current-time ?t )(next ?t ?tnext))
    :effect (and (current-time ?tnext )(not(current-time ?t)))
  )

 
  (:action design-add-road
    :parameters (?from - location ?to - location ?inter - location ?t - time ?tnext - time)
    :precondition (and (not(execution))(next ?t ?tnext)(current-time ?t )(road ?from ?to)(road ?from ?inter)(road ?inter ?to))
    :effect (and (enabled-shortcut ?from ?to )(enabled-shortcut-from ?from)(current-time ?tnext )(not (current-time ?t )))
  )

  (:action design-add-road-service
    :parameters (?from - location ?to - location ?t - time ?tnext - time)
    :precondition (and (not(execution))(next ?t ?tnext)(current-time ?t )(road ?from ?to))
    :effect (and (enabled-safety ?from ?to )(enabled-safety-from ?from)(current-time ?tnext )(not (current-time ?t )))
  )
  

	       



)
