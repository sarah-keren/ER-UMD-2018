#ifndef UMDHEURISTIC_H
#define UMDHEURISTIC_H

#include <./Heuristic.h>
#include "./State.h"

namespace umd
{

/**
 * A UmdHeuristic class using a separate heuristic for the design and execution stages of a umd problem
 *
 *  The problem is encoded in PPDDL (and cast into mlppddl::PPDDLProblem* problem)
 */
class UmdHeuristic : public mlcore::Heuristic
{


    public:
        /**
        * A heuristic that uses a separate heuristic for the design and execution parts of the state space
        * @param problem - problem to be solved.
        * @param simplified problem - simplified problem
        * @param designHeuristic - heuristic to appy to the design states
        * @param executionHeuristic - heuristic to appy to the execution states
        * @param isRelaxedMethod - indicates if the design method is relaxed (higher epsilon)
        */
        UmdHeuristic(mlcore::Problem* problem, mlcore::Problem* simplified_problem, mlcore::Heuristic* designHeuristic, mlcore::Heuristic* executionHeuristic,bool isRelaxedMethod, std::string domainName);


        /**
        * return the heuristic estimate for state s
        * @param s - state to evaluate
        */
        virtual double cost(const mlcore::State* s);

        /** Default destructor */
        virtual ~UmdHeuristic();

        static long  state_count;
        static long  design_state_count;
        static long  execution_state_count;

        std::string getDomainName(){return domainName_;};

        mlcore::Heuristic* get_executionHeuristic_(){return executionHeuristic_;}

        mlcore::Heuristic* get_designHeuristic_(){return this->designHeuristic_;}

        int get_expandedStateCounter(){return this->expandedStateCounter;}
        int get_examinedStateCounter(){return this->examinedStateCounter;}


    protected:

        /** The ppddl problem to be solved*/
        mlcore::Problem* problem_ = NULL ;
        /** A simplified version of the problem*/
        mlcore::Problem* simplifiedProblem_ = NULL ;
        /** The heuristic to apply at design*/
        mlcore::Heuristic* designHeuristic_= NULL;
        /** The heuristic to apply at execution*/
        mlcore::Heuristic* executionHeuristic_= NULL;
        /** A flag inidicating if the process is relaxed (e.g. high epslion)*/
        bool isRelaxedMethod = false;
        /** The name of the domain **/
        std::string domainName_;

        /** Determine if the state belongs to the design stage */
        bool isDesign(const mlcore::State* s);

        int expandedStateCounter = 0;
        int examinedStateCounter = 0;



    private:

        //NA


};
}
#endif // UMDHEURISTIC_H

