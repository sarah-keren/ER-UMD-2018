#include <stdio.h>

#include "../include/UMDProblem.h"
#include "../include/UmdDefs.h"
#include "../include/UmdUtils.h"
#include "./solvers/Solver.h"
#include "./solvers/FLARESSolver.h"
#include "./solvers/LAOStarSolver.h"
#include "./solvers/FLARESSolver.h"
#include "./solvers/DeterministicSolver.h"
#include "./solvers/LRTDPSolver.h""
#include "../include/ErUmdProblem.h"

#include <sstream>
/*
#include "./reduced/PPDDLTaggedReduction.h"
#include "./reduced/ReducedHeuristicWrapper.h"
#include "./reduced/ReducedModel.h"
#include "./reduced/ReducedState.h"
#include "./reduced/ReducedTransition.h"

#include "./solvers/FFReducedModelSolver.h"
*/
namespace umd
{

ErUmdProblem::ErUmdProblem(problem_t* pProblem):mlppddl::PPDDLProblem (pProblem)
{

    ppddlProblem_ = new mlppddl::PPDDLProblem (pProblem);
    domainName_ = pProblem->domain().name();


}

ErUmdProblem::ErUmdProblem(problem_t* pProblem, std::string str_fileName, std::string str_problemName, std::string str_domainName ):mlppddl::PPDDLProblem (pProblem)
{

    ppddlProblem_ = new mlppddl::PPDDLProblem (pProblem);
    fileName(str_fileName);
    problemName(str_problemName);
    domainName(str_domainName);


}

ErUmdProblem::~ErUmdProblem()
{
 if (ppddlProblem_)
 {    delete ppddlProblem_;
      ppddlProblem_ = NULL;
 }

}


void ErUmdProblem::solve(UmdHeuristic* umdHeur,std::string solverName, bool timed, std::string command_type)
{

    // solve the compilation\original problem with a single search
    if((command_type.find(umddefs::compilation) != std::string::npos)|| (command_type.find(umddefs::original) != std::string::npos))
    {

        if (true) {
            // TODO: change this if(true) to an appropriate option
            //SOLVE
            this->ppddlProblem_->setHeuristic(umdHeur->get_executionHeuristic_());
            mlsolvers::LAOStarSolver solver(this->ppddlProblem_);
            solver.solve(this->ppddlProblem_->initialState());

            //ANALYZE
            double cost = this->ppddlProblem_->initialState()->cost();
            std::cout << "Initial state:: "<<this->ppddlProblem_->initialState() <<std::endl;
            std::cout<< "Expected cost:: "<< this->ppddlProblem_->initialState()->cost()<<std::endl;
            //umdutils::print_policy_pddl(this->ppddlProblem_);
            std::cout << "Best action:: "<< this->ppddlProblem_->initialState()->bestAction() << std::endl;
            return;
        } else {
            // This is the suboptimal solver part
            // SOLVE
            mlsolvers::FLARESSolver solver(this->ppddlProblem_, 100, 1.0e-3, 0);
            solver.solve(this->ppddlProblem_->initialState());

            // ANALYZE
            std::cout << "Initial state:: "<<this->ppddlProblem_->initialState() <<std::endl;
            double expectedCost = 0.0;
            double expectedTime = 0.0;
            int numSims = 20;
            for (int sim = 0; sim < numSims; sim++) {
                double cost = 0.0;
                double planningTime = 0.0;
                mlcore::State* currentState = this->ppddlProblem_->initialState();
                unsigned long startTime = clock();
                solver.solve(currentState);
                unsigned long endTime = clock();
                planningTime += (double(endTime - startTime) / CLOCKS_PER_SEC);
                mlcore::Action* action = currentState->bestAction();
                while (cost < mdplib::dead_end_cost) {
                    cost += this->ppddlProblem_->cost(currentState, action);
                    // The successor state according to the
                    // original transition model.
                    mlcore::State* nextState =
                        mlsolvers::randomSuccessor(
                            this->ppddlProblem_, currentState, action);
                    if (this->ppddlProblem_->goal(nextState)) {
                        break;
                    }
                    currentState = nextState;
                    // Re-planning if needed.
                    if (!currentState->checkBits(mdplib::SOLVED_FLARES)) {
                        startTime = clock();
                        solver.solve(currentState);
                        endTime = clock();
                        planningTime +=
                            (double(endTime - startTime) / CLOCKS_PER_SEC);
                    }
                    if (currentState->deadEnd()) {
                        cost = mdplib::dead_end_cost;
                    }
                    action = currentState->bestAction();
                }
                expectedCost += cost;
                expectedTime += planningTime;
            }
            std::cout << std::endl << "ExpectedCost " << expectedCost / numSims << std::endl;
            std::cout << "Best action:: " << this->ppddlProblem_->initialState()->bestAction() << std::endl;
        }
    }


    else
    {
        //SOLVE
        mlsolvers::DeterministicSolver solver (this, mlsolvers::det_most_likely, umdHeur);
        mlcore::Action* best_action = solver.solve(this->initialState());

        //ANALYZE
        std::cout << "Initial state:: " << this->initialState() <<std::endl;
        std::cout << "Expected cost:: "<< this->initialState()->cost()<<std::endl;
        std::cout << "Best action:: " << best_action <<std::endl;
        return;
    }


}

//goal states are execution nodes
 bool ErUmdProblem::goal(mlcore::State* s) const
 {

    //std::cout << "in goal with state" << s << std::endl;
    // the goal is achieved when the extracted noded is an execution node
    std::stringstream buffer;
    buffer<<(mlppddl::PPDDLState*)s;

    if (buffer.str().find(umddefs::execution_stage_string) != std::string::npos)
    {
        //std::cout << "at goal : execution node" << std::endl;
        return true;

    }
    //std::cout << "not yet at goal" << std::endl;

    return false;
 }

double ErUmdProblem::cost(mlcore::State* s, mlcore::Action* a) const
{

    std::string actionName = ((mlppddl::PPDDLAction*)a)->pAction()->name();
    //std::cout << "\n in cost with state" << s << " and action "<< a<< std::endl;

    // for design actions that do not start execution
    if (actionName.find(umddefs::design_start_execution) == std::string::npos)
    {
        if (actionName.find(umddefs::design_stage_string) != std::string::npos)
        {
            if(actionName.find(umddefs::idle_string) != std::string::npos)
            {
                // if the action is a idle design action - the cost is epsilon/2
                //std::cout << " cost is " << 1.0e-4/2 << std::endl;
                return 1.0e-4/2;
            }
            else
            {
                // if the action is a design action - the cost is epsilon
                //std::cout << " cost is " << 1.0e-4 << std::endl;
                return 1.0e-4;
            }

        }
        else
        {
            std::cout<< "Error in ErUmdProblem::cost with action " <<actionName <<std::endl;
            throw Exception( "Error in ErUmdProblem::cost with action " + actionName );


        }


    }

    // the action is a start execution action the cost is the cost of the underlaying mdp
    else
    {
        if (true) {
            // TODO: change this if(true) to have an appropriate option
            mlsolvers::LAOStarSolver solver(this->ppddlProblem_);
            auto successors = ppddlProblem_->transition(s,a);
            mlcore::State* s0 = successors.front().su_state;
            solver.solve(s0);
            double cost = s0->cost();
            //std::cout << "\n for state: "<<s << " and successor state: " << s0 <<" cost is:  "<< cost<<std::endl;
            return cost;
        } else {
            mlsolvers::FLARESSolver solver(this->ppddlProblem_, 100, 1.0e-3, 0);
            unsigned long startTime = clock();
            solver.solve(s0);
            unsigned long endTime = clock();
            double planTime = (double(endTime - startTime) / CLOCKS_PER_SEC);
            return s0->cost();
        }
    }
}


}
