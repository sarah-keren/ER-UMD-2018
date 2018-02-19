#ifndef UMDSTATE_H
#define UMDSTATE_H

#include "./ppddl/PPDDLState.h"

namespace umd
{
// A umd state is either design or execution
class UmdState : public mlppddl::PPDDLState
{
    public:
        UmdState(mlcore::Problem* problem, state_t* pState);
        virtual ~UmdState();

        bool isDesignFlagSet() {return this->isDesignSet;};
        bool getDesignFlag() {return this->flagDesign;};

        void setDesignFlag(bool bFlag){
            this->isDesignSet = true;
            this->flagDesign = bFlag;
        };

    protected:
        bool isDesignSet = false;
        bool flagDesign = false;
    private:
};
}
#endif // UMDSTATE_H
