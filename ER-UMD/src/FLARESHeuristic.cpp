
#include<list>
#include "../include/FLARESHeuristic.h"
#include "../include/solvers/Solver.h"
#include "./solvers/FLARESSolver.h"
#include "../include/UmdUtils.h"


namespace umd
{


FLARESHeuristic::FLARESHeuristic(mlcore::Problem* problem, int num_of_simulations, bool simulate_at_tips):MDPHeuristic()
{
    this->problem_ = (ErUmdProblem*)problem;
    this->num_of_simulations = num_of_simulations;
    this->simulate_at_tips = simulate_at_tips;
    //ctor
}

double FLARESHeuristic::cost(const mlcore::State* s)
{

    //std::cout<<"Evaluating  : "<< (mlcore::State*)s<< std::endl;
    this->update_counter(s);


    //print_cost_array();

    mlppddl::PPDDLState* copyState = new mlppddl::PPDDLState(this->problem_,((mlppddl::PPDDLState*)s)->pState());
    mlcore::State* relaxedProblemState = this->problem_->getState(copyState);


    if (problem_->goal(relaxedProblemState))
    {
        //std::cout<<" ------->goal sate "<<std::endl<< std::endl<< std::endl;
        return 0.0;
    }
    //std::cout<<" ------->serching for precomputed value "<<std::endl;
    auto it = costs_.find(const_cast<mlcore::State*> (relaxedProblemState));
    if (it != costs_.end())
    {
        //std::cout<<" ------->pre computed value found: "<<it->second<<std::endl;
        return it->second;
    }
    //std::cout<<"bla 5"<< std::endl;

    //std::cout<<"Value not in cache - computing  : "<< relaxedProblemState<< std::endl;
    double cost = 0.0;

    //get a lower bound by running FLARES
    mlsolvers::FLARESSolver solver(this->problem_, umddefs::flares_sims, 1.0e-3, 0);
    unsigned long startTime = clock();
    //mlppddl::PPDDLState* copyState = (mlppddl::PPDDLState*)s;
    //copyState->SetProblem(this->problem_);
    //std::cout<<"bla 6"<< std::endl;


    //mlcore::State* relaxedProblemState = this->problem_->addState(copyState);
    solver.solve(relaxedProblemState);
    //double val = s->cost();
    //solver.solve((mlcore::State*)s);
    //((mlcore::State*)s)->setCost(val);

    //solver.solve(copyState);
    unsigned long endTime = clock();

    double planTime = (double(endTime - startTime) / CLOCKS_PER_SEC);
    if (this->simulate_at_tips)
    {
        //std::pair <double,double> simulated_result = umdutils::simulateCost(umddefs::flares_sims,this->problem_,&solver, relaxedProblemState);
        umdutils::simulation_result result = umdutils::simulateCost(umddefs::flares_sims,this->problem_,&solver, relaxedProblemState);

        //std::cout<<"FLARESHeuristic simulated cost: "<< simulated_result.first<< " mean is "<< simulated_result.second<< " s->cost() is "<< s->cost()<<std::endl;
        cost =  result.averageCost;
    }
    else
    {

        //std::cout<<"FLARESHeuristic cost is: "<< relaxedProblemState->cost()<<std::endl;
        //cost = s->cost();
        cost = relaxedProblemState->cost();
    }

    //delete copyState;
    costs_[const_cast<mlcore::State*> (relaxedProblemState)] = cost;
    return cost;





}



} // namespace mlsovers

