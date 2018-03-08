#ifndef ERUMDPROBLEM_H
#define ERUMDPROBLEM_H


#include "./ppddl/PPDDLAction.h"
#include "../include/UMDProblem.h"




namespace umd
{
/*
A class represening a Equi-Reward Utility Maximizing problem as decribed in "Equi-Reward Utility Maximizing Design in Stochastic Environments
Sarah Keren, Luis Pineda, Avigdor Gal, Erez Karpas, Shlomo Zilberstein" IJCAI-17
*/
class ErUmdProblem : mlppddl::PPDDLProblem
{
    public:

        ErUmdProblem(problem_t* pProblem, std::string solverName);
        ErUmdProblem(problem_t* pProblem, std::string str_fileName, std::string str_problemName, std::string str_domainName, std::string str_solverName );
        virtual ~ErUmdProblem();
        virtual mlppddl::PPDDLProblem* getPPDDLProblem(){return ppddlProblem_;}
        // get the optimal policy for the umd problem using the solver (e.g. LAO*)
        virtual void solve(UmdHeuristic* umdHeur,bool timed,std::string command_type);


        void fileName(std::string name) { fileName_ = name; }
        std::string getFileName(){return fileName_;}

        void problemName(std::string name) { problemName_ = name; }
        std::string getProblemName(){return problemName_;}

        void domainName(std::string name) { domainName_ = name; }
        std::string getDomainName(){return domainName_;}


        /**
        * Overrides method from pddlProblem.
        */
        virtual bool goal(mlcore::State* s) const;

        /**
        * Overrides method from pddlProblem.
        */
        virtual double cost(mlcore::State* s, mlcore::Action* a) const;




    protected:
       mlppddl::PPDDLProblem* ppddlProblem_;
       std::string domainName_;
       std::string solverName;
    private:
        std::string fileName_;
        std::string problemName_;


};
}
#endif // ERUMDPROBLEM_H
