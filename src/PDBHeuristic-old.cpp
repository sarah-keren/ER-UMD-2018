#include "../include/PDBHeuristic.h"
#include "../include/UmdDefs.h"
#include "../include/UmdUtils.h"

namespace umd
{

PDBHeuristic::PDBHeuristic(mlcore::Problem* problem, mlcore::Heuristic* designHeuristic, mlcore::Heuristic* executionHeuristic,bool isRelaxedMethod, ErUmdProblem* simplified_problem, std::string domainName)
:UmdHeuristic(problem, designHeuristic, executionHeuristic,isRelaxedMethod,domainName)
{
    //ctor
    //construct a DB of heuristic values
    mapOfValues= new std::unordered_map<std::string, double>();

}

PDBHeuristic::~PDBHeuristic()
{
    print_value_map();
    if (mapOfValues)
    {
        delete mapOfValues;
    }
    //dtor
}



double PDBHeuristic::get_dominating_modification_cost(const mlcore::State*  s)
{
    double cost = 0;

    //std::cout<< "\n \n In get_dominating_modification_cost with state " <<(mlppddl::PPDDLState*)s <<  std::endl;

    // get the modification
    std::vector<std::string> modification_list;
    umdutils::get_modification_sequence((mlppddl::PPDDLState*)s, &modification_list);


    //umdutils::print_modification_sequence(modification_list);


    //get abstraction key
    std::string abstraction_key = umdutils::get_abstract_modification(modification_list,umdutils::get_abstraction_type(this->domainName_));

    //std::cout<< "\n \n abstraction_key " << abstraction_key  <<  std::endl;
    // get precalculated value
    std::unordered_map<std::string,double>::const_iterator iter_map = this->mapOfValues->find(abstraction_key);


    //if the value is not yet in the table - calculate it
    if (iter_map == this->mapOfValues->end())
    {
        //std::cout << "value not found in the hash - computing value" <<std::endl;
        mlcore::State* abstract_state =  umdutils::get_abstract_state((mlppddl::PPDDLState*)s,umdutils::get_abstraction_type(this->domainName_));
        cost = this->designHeuristic_->cost(s);

        this->mapOfValues->insert({abstraction_key,cost});

     }
    // else: return the cahsed value
    else
    {
        //std::cout << "\nUsing pre-calculated value found in the hash" <<std::endl;
        //std::cout << iter_map->first << " is " << iter_map->second;
        cost = iter_map->second;
    }

    // go through the cache and look for a dominating sequence

    //umdutils::is_abstraction(modification_list,modification_list,problem->domain().name());



    return cost;
}

bool PDBHeuristic::print_value_map()
{

    std::cout<<" \n abstract hash: \n";
    std::unordered_map<std::string, double>::iterator abstract_value_iter ;
    for (abstract_value_iter = this->mapOfValues->begin(); abstract_value_iter != this->mapOfValues->end(); ++abstract_value_iter)
    {
            std::string abstract_modification = (abstract_value_iter)->first;
            std::cout<<" abstract modification "<< abstract_modification;
            std::cout<<"  cost: " << (abstract_value_iter)->second<<std::endl;
    }

    return true;
}

// if the value of a dominating state has been calculated
// otherwise- calculate the value of an over-modification in the current state
double PDBHeuristic::cost(const mlcore::State* s)
{

    state_count +=1;

     //std::cout<<"in pdb cost"<<std::endl;

    unsigned long begTime = clock();


    if (isDesign(s))
    {
            double cur_cost = get_dominating_modification_cost(s);
            design_state_count +=1;
            double hcost = this->designHeuristic_->cost(s);
            //std::cout<<"\nUsing the design hueristic cost: ";
            //std::cout<<"\nState: " << (mlppddl::PPDDLState*)s << "cost: " << hcost << "Time to compute cost : " <<   ((unsigned long) clock() - begTime)/(CLOCKS_PER_SEC/1.0)<<std::endl;
            return cur_cost;
    }

    execution_state_count +=1;
    //std::cout<<"\nUsing the exe hueristic cost: "<< this->executionHeuristic_->cost(s)<<std::endl;
    double hcost = this->executionHeuristic_->cost(s);

    //std::cout<<"\nState: " << (mlppddl::PPDDLState*)s << "cost: " << hcost << "Time to compute cost : " <<   ((unsigned long) clock() - begTime)/(CLOCKS_PER_SEC/1.0)<<std::endl;
    return hcost;


}

}
