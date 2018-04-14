#ifndef ZEROHEURISTIC_H
#define ZEROHEURISTIC_H

#include "../include/State.h"
#include "./MDPHeuristic.h"

namespace umd{

class ZeroHeuristic : public MDPHeuristic
{
    public:
        ZeroHeuristic();
        virtual ~ZeroHeuristic();
        virtual double cost(const mlcore::State* s){
            update_counter();
            return 0.0;
            };
    protected:
    private:
};
}

#endif // ZEROHEURISTIC_H

