#ifndef UMDPROBLEM_H
#define UMDPROBLEM_H

#include "./ppddl/PPDDLProblem.h"
#include "./ppddl/mini-gpt/problems.h"


#include "../include/UMDHeuristic.h"


namespace umd
{
//General utility maximizing design problem (including er-umd and grd problems)
class UmdProblem
{
    public:
        virtual void solve(UmdHeuristic* umdHeur,std::string solverName,bool timed) = 0;
    protected:


    private:
};
}
#endif // UMDPROBLEM_H
