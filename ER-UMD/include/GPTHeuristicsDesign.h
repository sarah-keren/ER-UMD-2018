#ifndef GPTHEURISTICSDESIGN_H
#define GPTHEURISTICSDESIGN_H

#include "../include/UMDProblem.h"
#include "../include/UMDState.h"

#include "./ppddl/PPDDLState.h"
#include "./ppddl/mini-gpt/problems.h"
#include "./ppddl/mini-gpt/states.h"
#include "./ppddl/mini-gpt/domains.h"
#include "./ppddl/mini-gpt/states.h"
#include "./ppddl/mini-gpt/exceptions.h"
#include "./ppddl/mini-gpt/heuristics.h"
#include "./ppddl/mini-gpt/queue.h"

#include <stdlib.h>
#include <iostream>
#include <queue>
#include <set>
#include <tr1/unordered_map>


//using both self-implemented heuristics and heuristics from mini-gpt (by Blai Bonet)

namespace umd_heuristics
{



/*******************************************************************************
 *
 * zero heuristic
 *
 ******************************************************************************/

class design_zeroHeuristic_t : public heuristic_t,public mlcore::Heuristic
{

public:
  design_zeroHeuristic_t( const problem_t &problem ): heuristic_t(problem){};;
  virtual ~design_zeroHeuristic_t(){};
  virtual double value( const state_t &state )
  {
    return 0.0;
  };
  virtual void statistics( std::ostream &os ) const{};
  virtual double cost(const mlcore::State* s)
  {
    state_t* state = ((umd::UmdState*)s)->pState();
    return this->value(*state);
  }
  ;


};



/*******************************************************************************
 *
 * zero-plus heuristic
 *
 ******************************************************************************/

class design_zeroPlusHeuristic_t : public heuristic_t,public mlcore::Heuristic
{

public:
  design_zeroPlusHeuristic_t( const problem_t &problem ): heuristic_t(problem){};
  virtual ~design_zeroPlusHeuristic_t(){};
  virtual double value( const state_t &state )
  {
      if( problem_.goalT().holds( state ) ) return( 0 );
      else return 1.0;
  };
  virtual void statistics( std::ostream &os ) const{};
  virtual double cost(const mlcore::State* s)
  {
    state_t* state = ((umd::UmdState*)s)->pState();
    return this->value(*state);
  };


};



/*******************************************************************************
 *
 * atom-min-1-forward heuristic
 *
 ******************************************************************************/

class design_atomMin1ForwardHeuristic_t : public heuristic_t,public mlcore::Heuristic
{
  const problem_t &relaxation_;

public:
  design_atomMin1ForwardHeuristic_t( const problem_t &problem );
  virtual ~design_atomMin1ForwardHeuristic_t();
  virtual double value( const state_t &state );
  virtual void statistics( std::ostream &os ) const;
  virtual double cost(const mlcore::State* s);
  bool isGoalT();


};


/*******************************************************************************
 *
 * atom-min-<m>-forward heuristic
 *
 ******************************************************************************/

class design_atomMinMForwardHeuristic_t : public heuristic_t ,public mlcore::Heuristic
{
  size_t m_;
  ushort_t *array_;
  const problem_t &relaxation_;
  enum { OPEN = 0x100, CLOSED = 0x200 };

  class pairINDEX
  {
  public:
    unsigned operator()( const std::pair<unsigned,ushort_t> &pair ) const
    {
      return( pair.second );
    }
  };

public:
  design_atomMinMForwardHeuristic_t( const problem_t &problem, size_t m );
  virtual ~design_atomMinMForwardHeuristic_t();
  virtual double value( const state_t &state );
  virtual void statistics( std::ostream &os ) const;
  void subsets( size_t m, const atomList_t &alist, size_t i, ushort_t *array,
		size_t j, std::vector<unsigned> &ssets ) const;

 virtual double cost(const mlcore::State* s);




};


class design_minMinIDAHeuristic_t :public mlcore::Heuristic
{

public:

  minMinIDAHeuristic_t idaHeuristic;
  design_minMinIDAHeuristic_t ( const problem_t &problem, heuristic_t &heur, bool useTT ):idaHeuristic(problem,heur, useTT )
  {}

  double cost(const mlcore::State* s){

    mlppddl::PPDDLState* pddlState = (mlppddl::PPDDLState*)s;
    return idaHeuristic.value(*pddlState->pState());
   };

};

}
#endif // GPTHEURISTICSDESIGN_H

