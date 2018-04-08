#ifndef UMD_SARAHHEURISTIC_H
#define UMD_SARAHHEURISTIC_H


#include "../include/State.h"
#include "./Heuristic.h"
#include "./Problem.h"
#include "./ErUmdProblem.h"


namespace umd
{

/**
 * Implements the hmin heuristic described in
 * http://www.aaai.org/Papers/ICAPS/2003/ICAPS03-002.pdf
 */
class SarahHeuristic : public mlcore::Heuristic
{
private:
    /* The problem for which this heuristic is computed. */
    //mlcore::Problem* problem_;
    ErUmdProblem* problem_;

    /*
     * If true, the heuristic value for all states will be found when the
     * the heuristic is constructed. Otherwise it will be computed on demand.
     */
    bool solveAll_;

    /*
     * a limit on the number of allowed iterations
     */
    int iteration_limit;

    /* Stores the computed values for the states. */
    mlcore::StateDoubleMap costs_;

    /* Stores the best actions for each state. */
    mlcore::StateActionMap bestActions_;

    /* Computes the hmin q-value for the given state and action. */
    double hminQvalue(mlcore::State* s, mlcore::Action* a);

    /* Performs a hmin update. */
    void hminUpdate(mlcore::State* s);

    /* Returns the successor with the minimum estimated cost. */
    mlcore::State* hminSuccessor(mlcore::State* s, mlcore::Action* a);

    /* Checks if the state has been solved by LRTA*. */
    bool checkSolved(mlcore::State* s);

    void print_cost_array()
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


public:
    //SarahHeuristic(mlcore::Problem* problem_, bool solveAll);

    SarahHeuristic(mlcore::Problem* problem_, bool solveAll, int iteration_limit);

    virtual ~SarahHeuristic() { }

    void reset()
    {
        bestActions_.clear();
        costs_.clear();
    }

    virtual double cost(const mlcore::State* s);
    virtual double cost_original(const mlcore::State* s);
};

}
#endif // UMD_SARAHHEURISTIC_H
