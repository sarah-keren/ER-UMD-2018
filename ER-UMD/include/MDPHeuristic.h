#ifndef MDPHEURISTIC_H
#define MDPHEURISTIC_H

#include "../include/State.h"
#include "./Heuristic.h"

//namespace umd
//{
class MDPHeuristic : public mlcore::Heuristic
{
    public:
        MDPHeuristic();
        virtual ~MDPHeuristic();

        virtual double cost(const mlcore::State* s) = 0;

        virtual void update_counter(){state_counter += 1;};
        virtual int get_counter(){return state_counter;};

        //virtual void print_cost_array() =0;


    protected:
        int state_counter;


    private:
};
//}
#endif // MDPHEURISTIC_H
