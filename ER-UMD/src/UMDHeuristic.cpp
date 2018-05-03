#include "../include/UMDHeuristic.h"
#include "../include/UmdDefs.h"
#include "../include/UmdUtils.h"
#include "../include/UMDState.h"
#include "../include/ErUmdProblem.h"
#include "../include/UmdUtils.h"
#include "./ppddl/mini-gpt/atom_states.h"
#include "./solvers/LAOStarSolver.h"

#include <sstream>



namespace umd
{

long UmdHeuristic::state_count= 0;
long UmdHeuristic::design_state_count= 0;
long UmdHeuristic::execution_state_count= 0;



UmdHeuristic::UmdHeuristic(mlcore::Problem* problem, mlcore::Problem* simplified_problem, mlcore::Heuristic* designHeuristic, mlcore::Heuristic* executionHeuristic,bool isRelaxedMethod, std::string domainName)
{

    this->problem_ = problem;
    ((mlppddl::PPDDLProblem*)this->problem_)->setHeuristic(this->executionHeuristic_);
    this->designHeuristic_ = designHeuristic;
    this->executionHeuristic_ = executionHeuristic;
    this->isRelaxedMethod = isRelaxedMethod;
    this->domainName_ = domainName;
   //ctor
}


UmdHeuristic::~UmdHeuristic()
{

      if(this->executionHeuristic_)
        {delete this->executionHeuristic_;}

       if(this->designHeuristic_)
        {delete this->designHeuristic_;}

    //dtor
}


double UmdHeuristic::cost(const mlcore::State* s)
{



    //std::cout<<"---------------------------------------------------------------------------------- "<<std::endl;
    //std::cout<<"UmdHeuristic::cost with state :"<< (mlppddl::PPDDLState*)s<<std::endl;


    //if a design heuristic is defined - apply it for design states
    if((this->designHeuristic_)&&(umdutils::isDesign(s)))
    {

        expandedStateCounter+=1;
        examinedStateCounter+=1;


        unsigned long begTime = clock();
        design_state_count +=1;
        double cost = this->designHeuristic_->cost(s);
        //std::cout<<"\nUmdHeuristic::cost:: State: " << (mlppddl::PPDDLState*)s << "   -----> cost (design): " << cost << "----> Time to compute cost : " <<   ((unsigned long) clock() - begTime)/(CLOCKS_PER_SEC/1.0)<<std::endl;
        return cost;

    }//if

    //TODO : this is zero since the calculation of the underlying mdp was moved to the ErUmdProblem file
    return 0;
/*
    this->problem_->setHeuristic(get_executionHeuristic_());
    mlsolvers::LAOStarSolver solver(this->problem_);
    solver.solve((mlcore::State*)s);
    double cost = s->cost();
    std::cout << "\n sarah for state: "<<(mlppddl::PPDDLState*)s <<" cost is  --  :  "<< cost<<std::endl;
    return cost;
*/
}//cost



}//namespace
