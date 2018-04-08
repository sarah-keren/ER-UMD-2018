#include "../../include/solvers/Solver.h"
#include "../../include/solvers/LAOStarSolver.h"

#include "../../include/util/general.h"

#include <ctime>

namespace mlsolvers
{

mlcore::Action* LAOStarSolver::solve(mlcore::State* s0)
{

    //std::cout<<"In LAOStarSolver::solve(mlcore::State* s0)"<<std::endl;
    clock_t startTime = clock();
    int totalExpanded = 0;
    this->m_totalExpanded = totalExpanded;
    int countExpanded = 0;
    double error = mdplib::dead_end_cost;
    int iteration_counter =0;
    while (true) {
        do {
            iteration_counter+=1;
            visited.clear();
            countExpanded = expand(s0);
            totalExpanded += countExpanded;
            this->m_totalExpanded = totalExpanded;
            this->m_iteration_counter = iteration_counter;
            //std::cout<<" Expanded:"<< this->m_totalExpanded<<std::endl;
            //std::cout<<" iteration_counter:"<< iteration_counter<<std::endl;

            if ((0.001 * (clock() - startTime)) /
                    CLOCKS_PER_SEC > timeLimit_)
                return s0->bestAction();

        } while (countExpanded != 0);

        while (true) {
            if ((0.001 * (clock() - startTime)) /
                    CLOCKS_PER_SEC > timeLimit_)
                return s0->bestAction();

            visited.clear();
            error = testConvergence(s0);
            if (error < epsilon_)
                return s0->bestAction();
            if (error > mdplib::dead_end_cost) {
                break;  // BPSG changed, must expand tip nodes again
            }
        }
    }
}

int LAOStarSolver::expand(mlcore::State* s)
{

    if (!visited.insert(s).second)  // state was already visited.
        return 0;
    if (s->deadEnd() || problem_->goal(s))
        return 0;

    int cnt = 0;
    if (s->bestAction() == nullptr) {
        // state has not been expanded.
        bellmanUpdate(problem_, s, weight_);
        return 1;
    } else {
        mlcore::Action* a = s->bestAction();
        for (mlcore::Successor sccr : problem_->transition(s, a))
            cnt += expand(sccr.su_state);
    }
    bellmanUpdate(problem_, s, weight_);
    return cnt;
}

double LAOStarSolver::testConvergence(mlcore::State* s)
{
    double error = 0.0;

    if (s->deadEnd() || problem_->goal(s))
        return 0.0;

    if (!visited.insert(s).second)
        return 0.0;

    mlcore::Action* prevAction = s->bestAction();
    if (prevAction == nullptr) {
        // if it reaches this point it hasn't converged yet.
        return mdplib::dead_end_cost + 1;
    } else {
        for (mlcore::Successor sccr : problem_->transition(s, prevAction))
            error =  std::max(error, testConvergence(sccr.su_state));
    }

    error = std::max(error, bellmanUpdate(problem_, s, weight_));
    if (prevAction == s->bestAction())
        return error;
    // it hasn't converged because the best action changed.
    return mdplib::dead_end_cost + 1;
}

}

