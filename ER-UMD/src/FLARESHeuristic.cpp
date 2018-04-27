
#include<list>
#include "../include/FLARESHeuristic.h"
#include "../include/solvers/Solver.h"
#include "./solvers/FLARESSolver.h"
#include "../include/UmdUtils.h"


namespace umd
{


FLARESHeuristic::FLARESHeuristic(mlcore::Problem* problem, int num_of_simulations):MDPHeuristic()
{
    this->problem_ = (ErUmdProblem*)problem;
    this->num_of_simulations = num_of_simulations;
    //ctor
}

double FLARESHeuristic::cost(const mlcore::State* s)
{
    std::cout<<"Evaluating  : "<< (mlcore::State*)s<< std::endl;

    this->update_counter();


    if (problem_->goal(const_cast<mlcore::State*>(s)))
    {
        //std::cout<<" ------->goal sate "<<std::endl<< std::endl<< std::endl;
        return 0.0;
    }

    //std::cout<<" ------->serching for precomputed value "<<std::endl;
    auto it = costs_.find(const_cast<mlcore::State*> (s));
    if (it != costs_.end())
    {
        std::cout<<" ------->pre computed value found: "<<it->second<<std::endl;
        return it->second;
    }

    //std::cout<<"Value not in cache - computing  : "<< (mlcore::State*)s<< std::endl;

    //get a lower bound by running FLARES
    mlsolvers::FLARESSolver solver(this->problem_, umddefs::flares_sims, 1.0e-3, 0);
    unsigned long startTime = clock();
    //solver.solve(s);
    unsigned long endTime = clock();
    double planTime = (double(endTime - startTime) / CLOCKS_PER_SEC);

    if (umddefs::simulate_at_tips_flares)
    {
        std::pair <double,double> simulated_result = umdutils::simulateCost(umddefs::flares_sims,this->problem_,&solver);
        std::cout<<"FLARESHeuristic cost: "<< simulated_result.first<< "\n mean is "<< simulated_result.second<< " s->cost() is "<< s->cost()<<std::endl;
        return simulated_result.first;
    }
    else
    {
        std::cout<<"FLARESHeuristic Simulated cost is: "<< s->cost()<<std::endl;
        return s->cost();
    }





}



} // namespace mlsovers

