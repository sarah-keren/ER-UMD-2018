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

        /* Stores the computed values for the states. */
        mlcore::StateDoubleMap costs_;

        /* Stores the best actions for each state. */
        mlcore::StateActionMap bestActions_;



    public:
        //FLARESHeuristic(mlcore::Problem* problem_, bool solveAll);

        FLARESHeuristic(mlcore::Problem* problem, int num_of_simulations);

        virtual ~FLARESHeuristic() { }

        void reset()
        {
            bestActions_.clear();
            costs_.clear();
        }

        virtual double cost(const mlcore::State* s);

    };

}

#endif // FLARESHEURISTIC_H
