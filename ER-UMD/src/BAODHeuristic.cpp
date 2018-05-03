#include<list>
#include "../include/BAODHeuristic.h"
#include "../include/solvers/Solver.h"
#include "../include/UmdUtils.h"


namespace umd
{



BAODHeuristic::BAODHeuristic(mlcore::Problem* problem, bool solveAll, int iteration_limit):MDPHeuristic()
{


    problem_ = (ErUmdProblem*)problem;
    this->iteration_limit = iteration_limit;


}

double BAODHeuristic::cost(const mlcore::State* s)
{


    //std::cout<<"Evaluating  : "<< (mlcore::State*)s<< std::endl;

    this->update_counter(s);
    if (problem_->goal(const_cast<mlcore::State*>(s)))
    {
        //std::cout<<" ------->goal sate "<<std::endl<< std::endl<< std::endl;
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
        //go through the states in the current list
        double curIterMinCost = 0;

        /*
        std::cout<<"Start iteration with current list (" <<current->size()<<")\n";
        std::set<std::pair<const mlcore::State*, double>>::iterator itt;
        for (itt = current->begin(); itt != current->end(); ++itt) {
            std::cout<<"      State: "<< (mlcore::State*)(*itt).first<< " and cost: "<< (*itt).second<<"\n";
        }
        std::cout<<"------------------------------------\n\n\n";
        */

       //clear the list that will hold the nodes for the next iteration
        next->clear();

        std::set<std::pair<const mlcore::State*, double>>::iterator it;
        for (it = current->begin(); it != current->end(); ++it) {

            //get current state
            mlcore::State* current_state =  (mlcore::State*)(*it).first;
            //std::cout << "\n\nExpanding current state :" <<current_state << std::endl;
            double cur_cost = (*it).second ;
            ///if the goal is found return it's cost
            if (problem_->goal(const_cast<mlcore::State*>((*it).first)))
            {
                //std::cout<<"Heur value is (goal reached) "<<cur_cost<<std::endl;
                //cache the result
                costs_[const_cast<mlcore::State*>(s)] = minCost;
                //print_cost_array();
                return cur_cost;


            }

            if ((curIterMinCost == 0)||(cur_cost < curIterMinCost))
            {
                curIterMinCost = cur_cost;
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
                //std::cout<<" \n      Checking action: "<<a<< " with qAction "<<qAction<<std::endl;
                if(bMostLikleyOutcome)
                {
                    //get the next state
                    nextState = umdutils::mostLikelyOutcome(problem_, (mlcore::State*)current_state, a, false);
                    double accumulated_cost = qAction + cur_cost;
                    //std::cout<<" cost for state " << nextState << " and most likely outcome is " << accumulated_cost<<std::endl;
                    next->insert(std::make_pair(nextState, accumulated_cost));
                }

                else //all outcome
                {
                    // get all possible transitions and add them to the next list
                    std::list<std::pair<mlcore::State*, double>> next_states = problem_->transition((mlcore::State*)current_state, a);
                    //std::cout<<" number of successor nodes is "<<next_states.size() << std::endl;

                    std::list<std::pair<mlcore::State*, double>>::iterator it_states;
                    for (it_states = next_states.begin(); it_states != next_states.end(); ++it_states) {
                        mlcore::State* suc_state = (*it_states).first;
                        double accumulated_cost = qAction + cur_cost;
                        //std::cout<<"                       **successor state" << suc_state<<" with accumulated cost: "<<accumulated_cost<< std::endl;
                        //push back with the accumulated cost
                        next->insert(std::make_pair(suc_state, accumulated_cost));
                    } //for
                 }//else

            }//for
        }//for - exploring current
        //std::cout<<"End iteration \n";
        //std::cout<<"next size is: "<<next->size()<<std::endl;

        //switch the q'
        tmp = current;
        current = next;
        next = tmp;
        minCost = curIterMinCost;

        //std::cout<< "current has "<< current->size()<< "elements\n";

    }//while

    /*
    if (iteration_counter>=iteration_limit)
        std::cout<<"\n\nHeur value is (iteration limit "<<iteration_counter<< ":: "<<minCost <<std::endl;
    else
    {
        if(current->size()==0)
        std::cout<<"\n\nHeur value is (dead end)"<<minCost <<std::endl;
    }
    */

    //std::cout<<"Updating costs"<<std::endl;
    costs_[const_cast<mlcore::State*>(s)] = minCost;
    //print_cost_array();
    return minCost;

}



} // namespace mlsovers
