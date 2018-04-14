#include<list>

#include "../include/HminminHeuristic.h"
#include "../include/solvers/Solver.h"
#include "../include/UmdUtils.h"

using namespace mlcore;


namespace umd
{



HminminHeuristic::HminminHeuristic(mlcore::Problem* problem, int iteration_limit,bool solveAll):MDPHeuristic()
{


    problem_ = (ErUmdProblem*)problem;

    this->iteration_limit = iteration_limit;
    /*
    solveAll_ = solveAll;
    if (solveAll_) {
        problem->generateAll();
        while (true) {


            double maxResidual = 0.0;
            for (State * s : problem->states()) {
                double prevCost = costs_[s];
                hminUpdate(s);
                maxResidual = std::max(maxResidual, fabs(costs_[s]- prevCost));
            }
            if (maxResidual < 1.0e-6)
                break;
        }
    }
    */
}



double HminminHeuristic::cost(const mlcore::State* s)
{

    //std::cout<<"Entering  hmin cost with state : "<< (mlcore::State*)s<< std::endl;

    if (problem_->goal(const_cast<mlcore::State*>(s)))
    {
        //std::cout<<" ------->goal sate "<<std::endl;
        return 0.0;
    }


    //std::cout<<" ------->serching for precomputed value "<<std::endl;
    auto it = costs_.find(const_cast<mlcore::State*> (s));
    if (it != costs_.end())
    {
        //std::cout<<" ------->value found: "<<it->second<<std::endl;
        return it->second;
    }

    //std::cout<<"Value not in cache - computing  : "<< (mlcore::State*)s<< std::endl;

    mlcore::State* currentState = nullptr;
    while (true) {
        // Starting a LRTA* trial.
        currentState = const_cast<mlcore::State*> (s);
        bool noActionChange = true;
        double maxResidual = 0.0;
        int counter = 0;
        while (!problem_->goal(currentState)) {
            mlcore::Action* bestAction = nullptr;
            if (bestActions_.count(currentState) > 0)
                bestAction = bestActions_[currentState];

            hminUpdate(currentState);

            double prevCost = costs_[currentState];
            if (currentState->deadEnd())
                break;
            if (bestAction != bestActions_.at(currentState))
                noActionChange = false;


            maxResidual = std::max(maxResidual,
                                   fabs(prevCost - costs_.at(currentState)));
            // Getting the successor of the best action.
            bestAction = bestActions_.at(currentState);


            /*if (bestAction == nullptr)
            {
                std::cout<<"best action for state "<<currentState<< " is null"<<std::endl;

            }
            else
            {
              std::cout<<"best action for state "<<currentState<< " is "<<bestAction<<std::endl;

            }
            */


            double minCost = mdplib::dead_end_cost;
            mlcore::State* nextState = nullptr;
            for (auto const & successor :
                    problem_->transition(currentState, bestAction)) {

                double successorCost = costs_.at(successor.su_state);
                if (successorCost < minCost) {
                    nextState = successor.su_state;
                    minCost = successorCost;
                }
            }

            counter += 1;
            currentState = nextState;
            if (currentState == nullptr)
            {
                break;
            }
            //std::cout<<"current state is "<< (mlcore::State*)currentState<< " iteration:" << counter<< " and goal "<< problem_->goal(currentState)<<std::endl;
        }


        if (noActionChange && maxResidual < 1.0e-6)
            break;
    }

    it = costs_.find(const_cast<mlcore::State*> (s));
    //std::cout<< "\n cost::::: " << it->second << std::endl<<std::endl;


    return it->second;
}


void HminminHeuristic::hminUpdate(mlcore::State* s)
{
    if (problem_->goal(s)) {
        costs_[s] = 0.0;
        return;
    }

    double bestQ = mdplib::dead_end_cost;
    bool hasAction = false;
    for (mlcore::Action* a : problem_->actions()) {
        if (!problem_->applicable(s, a))
            continue;
        hasAction = true;
        double qAction = problem_->cost(s, a);
        //std::cout<<"In hmin update with state:" <<s <<" and action: " << a << " and cost:" <<qAction<<std::endl;
        double minCostSuccessor = mdplib::dead_end_cost;
        for (auto const & successor : problem_->transition(s, a)) {
            minCostSuccessor =
                std::min(minCostSuccessor, costs_[successor.su_state]);
        }
        qAction += minCostSuccessor;
        qAction = std::min(qAction, mdplib::dead_end_cost);
        if (qAction <= bestQ) {
            bestQ = qAction;
            bestActions_[s] = a;
        }
    }
    if (!hasAction) {
        s->markDeadEnd();
    }
    costs_[s] = bestQ;

    //print_cost_array();
}



} // namespace mlsovers
