#ifndef PDBHEURISTIC_H
#define PDBHEURISTIC_H

#include <UMDHeuristic.h>
#include "../include/ErUmdProblem.h"
#include <map>

namespace umd
{
class PDBHeuristic : public UmdHeuristic
{
    public:
        PDBHeuristic(mlcore::Problem* problem, mlcore::Problem* simplified_problem, mlcore::Heuristic* designHeuristic, mlcore::Heuristic* executionHeuristic,bool isRelaxedMethod, std::string domainName);
        virtual ~PDBHeuristic();
        virtual double cost(const mlcore::State* s);
        bool print_value_map();
    protected:
        // maintainting the db of heuristic values
        std::unordered_map<std::string, double>* mapOfValues;
        //int populate_heuristic_table(const std::string solverName);
        double get_dominating_modification_cost(const mlcore::State*  s);


        ErUmdProblem* m_simplified_problem;
    private:
};
}
#endif // PDBHEURISTIC_H
