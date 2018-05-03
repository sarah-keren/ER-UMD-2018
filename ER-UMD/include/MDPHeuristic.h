#ifndef MDPHEURISTIC_H
#define MDPHEURISTIC_H

#include "../include/State.h"
#include "./ppddl/PPDDLState.h"
#include "./Heuristic.h"
#include "../include/UmdDefs.h"
#include <sstream>



//namespace umd
//{
class MDPHeuristic : public mlcore::Heuristic
{
    public:
        MDPHeuristic();
        virtual ~MDPHeuristic();

        virtual double cost(const mlcore::State* s) = 0;

        virtual void update_counter(const mlcore::State* s){
            state_counter += 1;
            std::stringstream buffer;
            buffer<<(mlppddl::PPDDLState*)s;
            //if the staet is a design state - increment the counter
            if (buffer.str().find(umddefs::execution_stage_string) == std::string::npos)
            {
                design_state_counter+=1;
            }
        };

        virtual int get_counter(){return state_counter;};
        virtual int get_design_state_counter(){return design_state_counter;};

        //virtual void print_cost_array() =0;


    protected:
        int state_counter;
        int design_state_counter;


    private:
};
//}
#endif // MDPHEURISTIC_H
