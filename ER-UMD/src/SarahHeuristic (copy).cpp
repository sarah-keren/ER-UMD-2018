#include<list>

#include "../include/SarahHeuristic.h"
#include "../include/solvers/Solver.h"
#include "../include/UmdUtils.h"

using namespace mlcore;


namespace umd
{



SarahHeuristic::SarahHeuristic(mlcore::Problem* problem, bool solveAll, int iteration_limit)
{


    problem_ = (ErUmdProblem*)problem;
    solveAll_ = solveAll;
    this->iteration_limit = iteration_limit;
    /*
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

double SarahHeuristic::cost(const mlcore::State* s)
{


    std::cout<<"\n\n Entering SarahHeuristic cost with state : "<< (mlcore::State*)s<< std::endl;

    if (problem_->goal(const_cast<mlcore::State*>(s)))
    {
        std::cout<<" ------->goal sate "<<std::endl<< std::endl<< std::endl;
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
    int iteration_counter =0;

    //create to set of states to be explored
    std::set<std::pair<const mlcore::State*, double>> states_a;
    std::set<std::pair<const mlcore::State*, double>> states_b;

    //create three pointers to the lists (that will alternate)
    std::set<std::pair<const mlcore::State*, double>>* current = &states_a;
    std::set<std::pair<const mlcore::State*, double>>* next = &states_b;
    std::set<std::pair<const mlcore::State*, double>>* tmp;

    //init the list by pushing the current state
    current->insert(std::make_pair(s,0));

    double minCost = mdplib::dead_end_cost;
    bool bMostLikleyOutcome = false;

    //iterate though the current list of states until the iteration limit is met or until there are no more states to explore
    while ((iteration_counter<=iteration_limit)&&current->size()>0){

        // switch pointers and increment counter
        iteration_counter += 1;


        std::cout<<"Start iteration with current list (" <<current->size()<<")\n";
        std::set<std::pair<const mlcore::State*, double>>::iterator itt;
        for (itt = current->begin(); itt != current->end(); ++itt) {
            std::cout<<"      State: "<< (mlcore::State*)(*itt).first<< " and cost: "<< (*itt).second<<"\n";
        }
        std::cout<<"------------------------------------\n\n\n";


       //clear the list that will hold the nodes for the next iteration
        next->clear();

        //go through the states in the current list
        double curMinCost = 0;
        std::set<std::pair<const mlcore::State*, double>>::iterator it;
        for (it = current->begin(); it != current->end(); ++it) {

            //get current state
            mlcore::State* current_state =  (mlcore::State*)(*it).first;
            std::cout << "\n\nExpanding current state :" <<current_state << std::endl;
            double cur_cost = (*it).second ;
            ///if the goal is found return it's cost
            if (problem_->goal(const_cast<mlcore::State*>((*it).first)))
            {

                //std::cout<<"Heur value is (goal reached) "<<cur_cost<<std::endl;
                //cache the result
                return cur_cost;
            }

            if ((curMinCost == 0)||(cur_cost < curMinCost))
            {
                curMinCost = cur_cost;
            }


            /*for (mlcore::Action* a : problem_->actions()) {
                std::cout<<"action ==="<<a<<std::endl;
            }
            */

            ///populate the queue with the next set of states by exlporing the actions that can be performed
            mlcore::State* nextState = nullptr;
            for (mlcore::Action* a : problem_->actions()) {

                if (!problem_->applicable((mlcore::State*)current_state, a))
                    continue;

                //action cost
                double qAction = problem_->cost((mlcore::State*)s, a);
                std::cout<<" \n      Checking action: "<<a<< " with qAction "<<qAction<<std::endl;


                if(bMostLikleyOutcome)
                {
                    //get the next state
                    nextState = umdutils::mostLikelyOutcome(problem_, (mlcore::State*)current_state, a, false);

                    double accumulated_cost = 0.0;
                    //check if its value has been already computed
                    auto it = costs_.find(const_cast<mlcore::State*> (nextState));
                    if (it != costs_.end())
                    {
                        //std::cout<<" ------->value found: "<<it->second<<std::endl;
                        accumulated_cost =  it->second;
                    }
                    else
                    {
                        accumulated_cost = qAction + cur_cost;
                        costs_[nextState] = accumulated_cost;
                    }
                    std::cout<<" cost for state " << nextState << " and most likely outcome is " << accumulated_cost<<std::endl;

                    next->insert(std::make_pair(nextState, accumulated_cost));
                }

                else //all outcome
                {
                    // get all possible transitions and add them to the next list
                    std::list<std::pair<mlcore::State*, double>> next_states = problem_->transition((mlcore::State*)current_state, a);
                    std::cout<<" number of successor node is "<<next_states.size() << std::endl;


                    std::list<std::pair<mlcore::State*, double>>::iterator it_states;
                    for (it_states = next_states.begin(); it_states != next_states.end(); ++it_states) {
                        mlcore::State* suc_state = (*it_states).first;


                        double accumulated_cost = 0.0;
                        //check if its value has been already computed
                        auto it = costs_.find(const_cast<mlcore::State*> (suc_state));
                        if (it != costs_.end())
                        {
                            //std::cout<<" ------->value found: "<<it->second<<std::endl;
                            accumulated_cost =  it->second;
                        }
                        else
                        {
                            accumulated_cost = qAction + cur_cost;
                            costs_[suc_state] = accumulated_cost;
                        }


                        std::cout<<"                       **successor state" << suc_state<<" with accumulated cost: "<<accumulated_cost<< std::endl;

                        //push back with the accumulated cost
                        next->insert(std::make_pair(suc_state, accumulated_cost));
                    } //for
                 }//else

            }//for
        }//for - exploring current
        std::cout<<"End interation \n";
        std::cout<<"next size is: "<<next->size()<<std::endl;

        //switch the q'
        tmp = current;
        current = next;
        next = tmp;
        minCost = curMinCost;

        std::cout<< "current has "<< current->size()<< "elements\n";

    }//while

    if (iteration_counter>=iteration_limit)
        std::cout<<"\n\nHeur value is (iteration limit "<<iteration_counter<< ":: "<<minCost <<std::endl;
    else
    {
        if(current->size()==0)
        std::cout<<"\n\nHeur value is (dead end)"<<minCost <<std::endl;
    }

    return minCost;

}




double SarahHeuristic::cost_original(const mlcore::State* s)
{

    std::cout<<"Entering  hmin cost with state : "<< (mlcore::State*)s<< std::endl;

    if (problem_->goal(const_cast<mlcore::State*>(s)))
    {
        std::cout<<" ------->goal sate "<<std::endl;
        return 0.0;
    }


    //std::cout<<" ------->serching for precomputed value "<<std::endl;
    auto it = costs_.find(const_cast<mlcore::State*> (s));
    if (it != costs_.end())
    {
        std::cout<<" ------->value found: "<<it->second<<std::endl;
        return it->second;
    }

    std::cout<<"Value not in cache - computing  : "<< (mlcore::State*)s<< std::endl;

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

            double prevCost = costs_[currentState];
            hminUpdate(currentState);


            if (currentState->deadEnd())
                break;
            if (bestAction != bestActions_.at(currentState))
                noActionChange == false;
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
            std::cout<<"current state is "<< (mlcore::State*)currentState<< " iteration:" << counter<< " and goal "<< problem_->goal(currentState)<<std::endl;
        }
        if (noActionChange && maxResidual < 1.0e-6)
            break;
    }

    it = costs_.find(const_cast<mlcore::State*> (s));
    std::cout<< "\n cost::::: " << it->second << std::endl<<std::endl;


    return it->second;
}


void
 SarahHeuristic::hminUpdate(mlcore::State* s)
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

    print_cost_array();
}



} // namespace mlsovers
