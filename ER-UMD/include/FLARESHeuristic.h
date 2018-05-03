#ifndef FLARESHEURISTIC_H
#define FLARESHEURISTIC_H

#include "../include/State.h"
#include "./Problem.h"
#include "./ErUmdProblem.h"
#include "./MDPHeuristic.h"


namespace umd
{

    class FLARESHeuristic : public MDPHeuristic
    {
    protected:
        /* The problem for which this heuristic is computed. */
        //mlcore::Problem* problem_;
        ErUmdProblem* problem_;

        /*
         * a limit on the number of allowed iterations
         */
        int num_of_simulations;

        /*after a solution is generate - simulate on the generated policy?*/
        bool simulate_at_tips;

        /* Stores the computed values for the states. */
        mlcore::StateDoubleMap costs_;

        /* Stores the best actions for each state. */
        mlcore::StateActionMap bestActions_;



    public:
        //FLARESHeuristic(mlcore::Problem* problem_, bool solveAll);

        FLARESHeuristic(mlcore::Problem* problem, int num_of_simulations, bool simulate_at_tips);

        virtual ~FLARESHeuristic() { }

        void reset()
        {
            bestActions_.clear();
            costs_.clear();
        }

        virtual double cost(const mlcore::State* s);


         virtual void print_cost_array()
        {

            std::cout<<" \n START Cost array: \n";
            mlcore::StateDoubleMap::iterator state_value_iter ;
            for (state_value_iter = this->costs_.begin(); state_value_iter != this->costs_.end(); ++state_value_iter)
            {
                    mlcore::State* state = (mlcore::State*)state_value_iter->first;
                    std::cout<<" state "<< state;
                    std::cout<<" cost: " << (state_value_iter)->second;
                    std::cout<<" best action: " ;
                    mlcore::Action* bestAction = nullptr;
                    if (bestActions_.count(state) > 0)
                    {
                        bestAction = bestActions_[state];
                        std::cout<<bestAction;
                    }
                    std::cout<<std::endl;





            }
            std::cout<<" \n END Cost array: \n";

        }


    };

}

#endif // FLARESHEURISTIC_H
