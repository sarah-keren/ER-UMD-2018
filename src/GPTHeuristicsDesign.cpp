#include "../include/GPTHeuristicsDesign.h"

#include <assert.h>
#include <limits.h>
#include <math.h>
#include <values.h>
#include <iostream>
#include <sstream>



/*******************************************************************************
 *
 * atom-min-1-forward heuristic
 *
 ******************************************************************************/

namespace umd_heuristics
{


/*******************************************************************************
 *
 * codification for atom lists up to a fixed size
 *
 ******************************************************************************/

class codification_t
{
public:
  static unsigned f_p( unsigned w )
    {
      return( ((w+1)*(w+1) - (w+1)) >> 1 );
    }
  static unsigned f_w( unsigned z )
    {
      double t = (1 + sqrt( 1 + 8*z )) / 2;
      return( (unsigned)floor( t ) - 1 );
    }
  static unsigned f_x( unsigned z )
    {
      return( z - f_p( f_w( z ) ) );
    }
  static unsigned f_y( unsigned z )
    {
      return( f_p( f_w( z ) ) - z + f_w( z ) );
    }
  static unsigned code( unsigned x, unsigned y )
    {
      unsigned z = x*x + 2*x*y + y*y + 3*x + y;
      return( z >> 1 );
    }
  static unsigned code( const atomList_t &alist );
  static unsigned code( const ushort_t *array, size_t size );
  static void decode( unsigned ucode, atomList_t &alist );
};

inline unsigned
codification_t::code( const atomList_t &alist )
{
  assert( alist.size() < 8 );
  unsigned ucode = 0;
  if( alist.size() > 0 )
    {
      ucode = alist.atom( 0 );
      for( size_t i = 1; i < alist.size(); ++i )
	ucode = code( ucode, alist.atom( i ) );

      if( ((ucode<<3)>>3) != ucode )
	throw Exception( "precision overflow in codification_t::code(const atomList_t&)" );

      ucode = alist.size() + (ucode<<3);
    }
  return( ucode );
}

inline unsigned
codification_t::code( const ushort_t *array, size_t size )
{
  assert( size < 8 );
  unsigned ucode = 0;
  if( size > 0 )
    {
      ucode = array[0];
      for( size_t i = 1; i < size; ++i )
	ucode = code( ucode, array[i] );

      if( ((ucode<<3)>>3) != ucode )
	throw Exception( "precision overflow in codification_t::code(const ushort_t*,size_t)" );

      ucode = size + (ucode<<3);
    }
  return( ucode );
}

inline void
codification_t::decode( unsigned ucode, atomList_t &alist )
{
  alist.clear();
  size_t size = ucode & 0x7;
  ucode = ucode >> 3;
  if( size == 1 )
    alist.insert( ucode );
  else if( size > 1 )
    {
      for( size_t i = 0; i < size - 1; ++i )
	{
	  alist.insert( f_y( ucode ) );
	  ucode = f_x( ucode );
	}
      alist.insert( ucode );
    }
}





design_atomMin1ForwardHeuristic_t::design_atomMin1ForwardHeuristic_t( const problem_t &problem )
  : heuristic_t(problem), relaxation_(problem.strong_relaxation())
{
  if( gpt::verbosity >= 500 )
    std::cout << "<atom-min-1-forward>: new" << std::endl;

  // generate random states and compute their heuristic
  if( gpt::xtra > 0 )
    {
      // recover one initial states
      const problem_t &relax = problem_.medium_relaxation();
      std::pair<state_t*,Rational> *initial = new std::pair<state_t*,Rational>[DISP_INT_SIZE];
      for( size_t i = 0; i < DISP_INT_SIZE; ++i )
	initial[i].first = new state_t;
      problem_.initial_states( initial );

      for( size_t i = 0; i < gpt::xtra; ++i )
	{
	  // set initial state
	  state_t state;
	  for( state_t::const_predicate_iterator ai = initial[0].first->predicate_begin(); ai != initial[0].first->predicate_end(); ++ai )
	    if( *ai % 2 == 0 )
	      state.add( *ai );

	  // apply random operators
	  for( size_t steps = 0; steps < 1250; ++steps )
	    for( actionList_t::const_iterator ai = relax.actionsT().begin(); ai != relax.actionsT().end(); ++ai )
	      if( (*ai)->enabled( state ) && (drand48() > 0.5) )
		{
		  (*ai)->affect( state );
		  break;
		}

	  // output init description and value
	  std::cout << "  (:init";
	  for( state_t::const_predicate_iterator pi = state.predicate_begin(); pi != state.predicate_end(); ++pi )
	    {
	      std::cout << " ";
	      const Atom *atom = problem_t::atom_inv_hash_get( *pi );
	      if( !atom )
		std::cout << "(int-" << (*pi) << ")";
	      else
		problem_.print( std::cout, *atom );
	    }
	  std::cout << ")" << std::endl;
	  std::cout << "<state-value>: " << value( state ) << std::endl;
	}

      // clean
      for( size_t i = 0; i < DISP_INT_SIZE; ++i )
	delete initial[i].first;
      delete[] initial;
      exit( 0 );
    }
}

design_atomMin1ForwardHeuristic_t::~design_atomMin1ForwardHeuristic_t()
{
  problem_t::unregister_use( &relaxation_ );

  if( gpt::verbosity >= 500 )
    std::cout << "<atom-min-1-forward>: deleted" << std::endl;
}

double design_atomMin1ForwardHeuristic_t::cost(const mlcore::State* s)
{

    state_t* state = ((umd::UmdState*)s)->pState();
//    std::cout<<"In cost with state" <<  state << "With value " << this->value(*state);
    return this->value(*state);

}


double
design_atomMin1ForwardHeuristic_t::value( const state_t &state )
{
  actionList_t::const_iterator it;
  double result;
  state_t current( state );

  size_t steps = 0;
  bool change = true;
  relaxation_.complete_state( current );
  while ( change && !relaxation_.goalT().holds( current ) )
    {
      ++steps;
      change = false;
      for( it = relaxation_.actionsT().begin(); it != relaxation_.actionsT().end(); ++it )
	if( (*it)->enabled( current, relaxation_.nprec() ) )
	  {
	    change = (*it)->affect( current, relaxation_.nprec() ) || change;
	  }
    }

  if( relaxation_.goalT().holds( current, relaxation_.nprec() ) )
    result = (double)steps;
  else
    result = gpt::dead_end_value;

  if( gpt::verbosity >= 450 )
    {
      std::cout << "<atom-min-1-forward>: heuristic for " << state  << " = " << result << std::endl;
    }

  if( (result < gpt::dead_end_value) && problem_.goal_atom() )
    result = result - 1;
  //if( result < gpt::dead_end_value )
  //  result = result * ;
  return( result );
}

void
design_atomMin1ForwardHeuristic_t::statistics( std::ostream &os ) const
{
}



/*******************************************************************************
 *
 * atom-min-<m>-forward heuristic
 *
 ******************************************************************************/

design_atomMinMForwardHeuristic_t::design_atomMinMForwardHeuristic_t( const problem_t &problem,
							size_t m )
  : heuristic_t(problem), m_(m), relaxation_(problem.medium_relaxation())
{
  array_ = (ushort_t*)malloc( m_ * sizeof(ushort_t) );

  if( gpt::verbosity >= 500 )
    std::cout << "<atom-min-" << m_ << "-forward>: new" << std::endl;
}

design_atomMinMForwardHeuristic_t::~design_atomMinMForwardHeuristic_t()
{
  free( array_ );
  problem_t::unregister_use( &relaxation_ );

  if( gpt::verbosity >= 500 )
    std::cout << "<atom-min-" << m_ << "-forward>: deleted" << std::endl;
}

double
design_atomMinMForwardHeuristic_t::value( const state_t &state )
{

    //DEBUG
    //std::cout<< "In value "<<std::endl;
    //END_DEBUG

  static atomList_t alist, slist;
  static actionList_t aset;
  static std::vector<unsigned> ssets, gssets;
  static priorityQueue_t<std::pair<unsigned,ushort_t>,pairINDEX> PQ;
  static std::map<unsigned,ushort_t> map;
  static std::map<unsigned,ushort_t>::const_iterator it;
  static state_t::const_predicate_iterator ai;

  // base case
  if( problem_.goalT().holds( state ) ) return( 0 );

  // initialize goal subsets
  gssets.clear();
  subsets( m_, relaxation_.goalT().atom_list( 0 ), 0, array_, 0, gssets );

  // transform state into atom list
  slist.clear();
  for( ai = state.predicate_begin(); ai != state.predicate_end(); ++ai )
  {
    //DEBUG
    //std::cout<< " atom is " << *ai << std::endl;
    //END_DEBUG
    slist.insert( *ai );
    }
  // insert initial m-subsets into priority queue
  map.clear();
  ssets.clear();
  subsets( m_, slist, 0, array_, 0, ssets );

  //DEBUG
  //std::cout<< " m is " << m_<< " and sstes " << ssets.size() << std::endl;
  //END_DEBUG


  for( size_t i = 0; i < ssets.size(); ++i )
    {

      std::pair<unsigned,ushort_t> p( ssets[i], 0 | OPEN );
      //DEBUG
      //std::cout<< " atom value " << p.first << " " << p.second<< std::endl;
     //END_DEBUG

      PQ.push( p );
      map[p.first] = p.second;
    }

  // apply Dijkstra's to atom space
  size_t count = 0;
  while( !PQ.empty() )
    {
      std::pair<unsigned,ushort_t> p = PQ.top();
      PQ.pop();
      p.second = (p.second & 0xFF) | CLOSED;
      map[p.first] = p.second;
      codification_t::decode( p.first, alist );

      if( gpt::verbosity >= 500 )
	{
	  std::cout << "<atom-min-" << m_ << "-forward>: " << m_
		    << "-subset = " << p.first << alist
		    << ", value = " << (p.second & 0xFF) << std::endl;
	}

      // check if done
      for( size_t i = 0; i < gssets.size(); ++i )
	if( gssets[i] == p.first )
	  {
	    ++count;
	    break;
	  }
      if( count == gssets.size() ) break;

      // expand
      actionList_t::const_iterator ai = relaxation_.actionsT().begin();
      for( ; ai != relaxation_.actionsT().end(); ++ai )
	{
	  // check precondition
	  size_t i = 0;
	  assert( (*ai)->precondition().size() == 1 );
	  while( i < (*ai)->precondition().atom_list( 0 ).size() )
	    if( !alist.holds( (*ai)->precondition().atom_list( 0 ).atom( i++ ) ) )
	      break;
	  if( i < (*ai)->precondition().atom_list( 0 ).size() ) continue;

	  const deterministicAction_t *action = (const deterministicAction_t*)(*ai);
	  ushort_t cost = (p.second & 0xFF) + 1; // 1 should be (*ai)'s cost
	  atomList_t progress( alist );

	  // add add-list
	  for( i = 0; i < action->effect().s_effect().add_list().size(); ++i )
	    progress.insert( action->effect().s_effect().add_list().atom( i ) );

	  // remove del-list
	  for( i = 0; i < action->effect().s_effect().del_list().size(); ++i )
	    progress.remove( action->effect().s_effect().del_list().atom( i ) );

	  // insert m-subsets into priority queue
	  ssets.clear();
	  subsets( m_, progress, 0, array_, 0, ssets );
	  for( i = 0; i < ssets.size(); ++i )
	    {
	      it = map.find( ssets[i] );
	      if( (it == map.end()) ||
		  ((((*it).second & 0xFF00) == OPEN) && (cost < ((*it).second & 0xFF))) )
		{
		  if( it != map.end() ) PQ.remove( *it );
		  std::pair<unsigned,ushort_t> q( ssets[i], cost | OPEN );
		  PQ.push( q );
		  map[q.first] = q.second;
		}
	    }
	}
    }

    //DEBUG
    //std::cout<< "Size is: "<<gssets.size()<<std::endl;
    //END_DEBUG
    for( size_t i = 0; i < gssets.size(); ++i )
    {
        //DEBUG
        //std::cout<< "State: " << gssets[i];
        //END_DEBUG
        it = map.find( gssets[i] );
        double result_val =  (*it).second & 0xFF;
        //DEBUG
        //std::cout<< "Result_val is : " << result_val << std::endl;
        //END_DEBUG
    }



  // compute value
  double result = 0;
  for( size_t i = 0; i < gssets.size(); ++i )
    if( (it = map.find( gssets[i] )) != map.end() )
      {
        double result_val =  (*it).second & 0xFF;
    //  	std::cout<<"state "<< gssets[i] <<"is has value" << result_val<<std::endl;

        result = MAX(result,((*it).second & 0xFF));
      }
    else
      {

        result = gpt::dead_end_value;

//        std::cout<<"state is a dead end" <<std::endl;
//        state.full_print(std::cout,&this->problem_);

	break;
      }

  if( gpt::verbosity >= 450 )
    {
      std::cout << "<atom-min-" << m_ << "-forward>: heuristic for " << state  << " = " << result << std::endl;
    }

  if( (result < gpt::dead_end_value) && problem_.goal_atom() )
    result = result - 1;
  if( result < gpt::dead_end_value )
    result = result ;//* gpt::heuristic_weight;

/*  std::cout<<"The heuristic value for state "<<std::endl;
  state.full_print(std::cout,&this->problem_);
  std::cout<<" is " << result << std::endl;
*/
  return( result );
}

void
design_atomMinMForwardHeuristic_t::statistics( std::ostream &os ) const
{
}

void
design_atomMinMForwardHeuristic_t::subsets( size_t m, const atomList_t &alist,
				     size_t i, ushort_t *array, size_t j,
				     std::vector<unsigned> &ssets ) const
{
  if( (j == m) || (i == alist.size()) )
    {
      if( (j == m) || (j == alist.size()) )
	{
	  unsigned ucode = codification_t::code( array, j );
	  ssets.push_back( ucode );
	}
    }
  else
    {
      // insert ith atom into subset
      array[j] = alist.atom( i );
      subsets( m, alist, i+1, array, j+1, ssets );

      // skip ith atom
      subsets( m, alist, i+1, array, j, ssets );
    }
}

double design_atomMinMForwardHeuristic_t::cost(const mlcore::State* s)
{
    state_t* state = ((umd::UmdState*)s)->pState();
    return this->value(*state);

}







}
