#ifndef UMDUTILS_H_INCLUDED
#define UMDUTILS_H_INCLUDED

#include <sstream>

#include "./ppddl/PPDDLState.h"
#include "./ppddl/PPDDLProblem.h"
#include "./ppddl/PPDDLHeuristic.h"

#include "../include/UmdDefs.h"
#include "../include/ErUmdProblem.h"
#include "../include/SarahHeuristic.h"
#include "../include/solvers/HMinHeuristic.h"
#include "../include/solvers/Solver.h"
#include "../include/GPTHeuristicsDesign.h"


namespace umdutils
{
inline std::string get_relaxed_problem_name(std::string file,std::string problem_name,std::string command_type)
{
    std::string relaxed_prob;
    relaxed_prob.append(problem_name);
    if (command_type.find(umddefs::relaxed_environment) != std::string::npos)
    {
        relaxed_prob.append(umddefs::relaxed_string);
        return relaxed_prob;
    }

    if (command_type.find(umddefs::relaxed_modification) != std::string::npos)
    {
        relaxed_prob.append(umddefs::relaxed_modification_string);
        return relaxed_prob;
    }

    if (command_type.find(umddefs::relaxed_combined) != std::string::npos)
    {
        relaxed_prob.append(umddefs::relaxed_combined_string);
        return relaxed_prob;
    }

    if (command_type.find(umddefs::relaxed_design_process) != std::string::npos)
    {
        relaxed_prob.append(umddefs::relaxed_modification_string);
        return relaxed_prob;
     }

    if (command_type.find(umddefs::relaxed_combined_design_process) != std::string::npos)
    {
        relaxed_prob.append(umddefs::relaxed_combined_string);
        return relaxed_prob;
    }


}

inline std::string get_abstraction_type(std::string domain_name)
{

    if (domain_name.find(umddefs::domain_name_triangletire)!= std::string::npos)
    {

        return umddefs::first_prefix_param_relation;

    }


    if (domain_name.find(umddefs::domain_name_vacuum)!= std::string::npos)
    {

        return umddefs::first_param_relation;

    }

    if (domain_name.find(umddefs::domain_name_elevators)!= std::string::npos)
    {

        return umddefs::first_param_relation;

    }


    if (domain_name.find(umddefs::domain_name_boxworld)!= std::string::npos)
    {

        return umddefs::first_param_relation;

    }

    if (domain_name.find(umddefs::domain_name_blocksworld)!= std::string::npos)
    {

        return umddefs::first_param_relation;

    }
    if (domain_name.find(umddefs::domain_name_ex_blocksworld)!= std::string::npos)
    {


        return umddefs::first_param_relation;

    }


    return "error - domain name\n";





}


//https://stackoverflow.com/questions/10058606/splitting-a-string-by-a-character
inline void split(std::string str, std::string splitBy, std::vector<std::string>& tokens)
{

    /* Store the original string in the array, so we can loop the rest
     * of the algorithm. */
    tokens.push_back(str);

    // Store the split index in a 'size_t' (unsigned integer) type.
    size_t splitAt;
    // Store the size of what we're splicing out.
    size_t splitLen = splitBy.size();
    // Create a string for temporarily storing the fragment we're processing.
    std::string frag;
    // Loop infinitely - break is internal.
    while(true)
    {
        /* Store the last string in the vector, which is the only logical
         * candidate for processing. */
        frag = tokens.back();
        /* The index where the split is. */
        splitAt = frag.find(splitBy);
        // If we didn't find a new split point...
        if(splitAt == std::string::npos)
        {
            // Break the loop and (implicitly) return.
            break;
        }
        /* Put everything from the left side of the split where the string
         * being processed used to be. */
        tokens.back() = frag.substr(0, splitAt);
        /* Push everything from the right side of the split to the next empty
         * index in the vector. */
        tokens.push_back(frag.substr(splitAt+splitLen, frag.size()-(splitAt+splitLen)));
    }
}

    /*
    //string to atom map of the problem
    std::unordered_map<std::string, unsigned short>* stringAtomMap = new std::unordered_map<std::string, unsigned short>();
    //string to atom map of the problem
    umdutils::populate_string_to_atom_map(*stringAtomMap,umdProblem->getPPDDLProblem());
    std::unordered_map<std::string,unsigned short>::const_iterator it= stringAtomMap->find (umddefs::execution_stage_string);
    std::cout << it->first << " is " << it->second <<std::endl;
    unsigned short execution_predicate_index = it->second;
    */

inline bool populate_string_to_atom_map(std::unordered_map<std::string, ushort_t>& stringAtomMap, mlppddl::PPDDLProblem* p_ppddlProblem)
{
    Domain dom = p_ppddlProblem->pProblem()->domain();
    PredicateTable& preds = dom.predicates();
    TermTable& terms = p_ppddlProblem->pProblem()->terms();

    for (auto const & atom : problem_t::atom_hash()) {
        std::ostringstream oss;
        atom.first->print(oss, preds, dom.functions(), terms);

        //std::cout<< "Adding "<< oss.str() << " To the map as " << atom.second <<std::endl;
        stringAtomMap[oss.str()] = atom.second;
    }

    return true;
}


/**
* Add an atom to a ppddl state set
* @param state - state to modify
* @param atom_name - string representing the atom to add
*/
inline bool add_atom_to_state(mlppddl::PPDDLState* original_state, mlppddl::PPDDLProblem* p_ppddl, std::string atom_name,mlppddl::PPDDLState& execution_state,std::unordered_map<std::string, ushort_t>& stringAtomMap)
{

/*
    std::unordered_map<std::string, ushort_t> stringAtomMap;
    Domain dom = p_ppddl->pProblem()->domain();
    PredicateTable& preds = dom.predicates();
    TermTable& terms = p_ppddl->pProblem()->terms();

    for (auto const & atom : problem_t::atom_hash()) {
        std::ostringstream oss;
        atom.first->print(oss, preds, dom.functions(), terms);
        stringAtomMap[oss.str()] = atom.second;
    }
*/
 //   std::cout<<"Adding atom: " << atom_name  << "To the state" << stringAtomMap[atom_name] <<std::endl;
    execution_state.pState()->add(stringAtomMap[atom_name]);
    return true;

 }//add_atom_to_state

// goes through the state and figures out which modifications have been applied
inline void get_modification_sequence(mlppddl::PPDDLState* state, std::vector<std::string>* modification_list)
{
    std::stringstream buffer;
    buffer<< state;
    //std::cout<<"buffer is: " <<buffer.str() <<std::endl;

    std::string foo = buffer.str();
    std::vector<std::string> predicates;
    std::vector<std::string> modifications;
    split(foo, ")", predicates);

    std::vector<std::string>::iterator it;
    for (it = predicates.begin(); it != predicates.end(); ++it) {
        //std::cout << *it << '\n';
        if ((*it).find("enabled") != std::string::npos)
        {
            std::string modification = *it;
            std::size_t pos = modification.find("(");
            modification  = modification.substr(pos+1);
            //std::cout << "pushing: " << modification << '\n';
            modifications.push_back(modification);
            modification_list->push_back(modification);

        }
    }

    //std::cout << "state: " << state << std::endl;
    std::vector<std::string>::iterator itt;
    //std::cout<<"Modification sequence is:" <<std::endl;
    //for (itt = modification_list->begin(); itt != modification_list->end(); ++itt)
    //{
    //    std::cout << *itt << '\n';
    //}
    //std::cout << "\n\n";


}
inline void print_modification_sequence(std::vector<std::string>& modification_list)
{
    std::cout<<"\nModification sequence is:";
    std::vector<std::string>::iterator itt;
    for (itt = modification_list.begin(); itt != modification_list.end(); ++itt)
    {
        std::cout << *itt << " ";

    }
    std::cout << std::endl;



}


// goes through the state and figures out which modifications have been applied
inline bool is_dominating_abstraction_of(std::string  modification_a, std::string modification_b, std::string domain_name)
{
    /*
    std::string dominance_relation = umdutils::get_dominance_relation(domain_name);
    if (dominance_relation.find(umddefs::first_param_relation)!= std::string::npos)
    {
        std::vector<std::string> tokens_a;
        split(modification_a, " ", tokens_a);
        std::vector<std::string> tokens_b;
        split(modification_b, " ", tokens_b);

        // check the modification type is the same
        if (tokens_a[0].find(tokens_b[0])== std::string::npos)
        {
            std::cout<< "the modifications are not of the same type" <<std::endl;
            return false;
        }
        else
        {
            std::cout<< "the modifications have the same type" <<std::endl;
        }

        //check that the modifications share at least one param
        for (int index_b =1; index_b <= tokens_b.size();index_b ++)
        {
            for (int index_a =1; index_a<= tokens_a.size();index_a ++)
            {
                if(tokens_a[index_a].find(tokens_b[index_b])!= std::string::npos)
                {
                    std::cout<< "common param found" <<std::endl;
                    return true;
                }

            }
        }//for

        return false;






    }//if
    */
    return false;

}

// goes through the state and figures out which modifications have been applied
inline bool is_abstraction(std::vector<std::string>* modification_sequence_a, std::vector<std::string>* modification_sequence_b, std::string domain_name)
{

 // iterate through the modifications of list_b and make sure each is dominated by a modification in list_b
 std::vector<std::string>::iterator modification_iter_a;
 std::vector<std::string>::iterator modification_iter_b;

 for (modification_iter_b = modification_sequence_b->begin(); modification_iter_b != modification_sequence_b->end(); ++modification_iter_b)
 {
        std::string modification_b = *modification_iter_b;
        //std::cout << "checking modification: "<< modification_b<< '\n';
        bool abstraction_found = false;
        for (modification_iter_a = modification_sequence_a->begin(); modification_iter_a != modification_sequence_a->end(); ++modification_iter_a)
        {
            //std::cout << "in loop\n";

            std::string modification_a = *modification_iter_a;
            if (is_dominating_abstraction_of(modification_a,modification_b, domain_name))
            {
                // Found a dominating modification - move on to the next sequence
                abstraction_found = true;
                break;
            }

        }//for

 }

  return false;

}


inline std::string get_abstract_modification_set(std::vector<std::string>& modification_sequence, std::string abstraction_type )
{

    std::set<std::string> abstract_queue;
    std::vector<std::string>::iterator modification_iter;



    if ( abstraction_type.find(umddefs::first_param_relation)!= std::string::npos)
    {

        for (modification_iter = modification_sequence.begin(); modification_iter != modification_sequence.end(); ++modification_iter)
        {

            std::vector<std::string> tokens;
            std::string cur_token = "";
            split(*modification_iter, " ", tokens);
            cur_token.append(tokens[0]);
            cur_token.append(" ");
            cur_token.append("(");
            cur_token.append(tokens[1]);
            cur_token.append(")");
            cur_token.append("---");
            abstract_queue.insert(cur_token);




        }
    }//first param

    else
    {
        if ( abstraction_type.find(umddefs::first_prefix_param_relation)!= std::string::npos)
        {
            for (modification_iter = modification_sequence.begin(); modification_iter != modification_sequence.end(); ++modification_iter)
            {
                std::vector<std::string> tokens;
                std::string cur_token = "";
                split(*modification_iter, " ", tokens);
                cur_token.append(tokens[0]);
                cur_token.append(" ");
                cur_token.append("(");
                std::vector<std::string> vars;
                split(tokens[1], "-", vars);
                cur_token.append(vars[0]);
                cur_token.append(vars[1]);
                cur_token.append(")");
                cur_token.append("---");
                abstract_queue.insert(cur_token);


            }
        }
        else
        {
            std::cout<<"get_abstract_modification: abstraction_type error";

        }
    }//first param_prefix

    // get the key
    std::string abstraction_key = "";
    std::set<std::string>::iterator it;
    for (it=abstract_queue.begin(); it!=abstract_queue.end(); ++it)
    {
        std::cout << ' ' << *it;
        std::cout << '\n';
        abstraction_key+= *it;

    }


    std::cout<<"\n\n\n new abstraction key: ";
    std::cout<<abstraction_key;
    return abstraction_key;
}




inline std::string get_abstract_modification(std::vector<std::string>& modification_sequence, std::string abstraction_type )
{

    std::priority_queue<std::string> abstract_queue;
    std::vector<std::string>::iterator modification_iter;



    if ( abstraction_type.find(umddefs::first_param_relation)!= std::string::npos)
    {

        for (modification_iter = modification_sequence.begin(); modification_iter != modification_sequence.end(); ++modification_iter)
        {

            std::vector<std::string> tokens;
            std::string cur_token = "";
            split(*modification_iter, " ", tokens);
            cur_token.append(tokens[0]);
            cur_token.append(" ");
            cur_token.append("(");
            cur_token.append(tokens[1]);
            cur_token.append(")");
            cur_token.append("---");
            abstract_queue.push(cur_token);

        }
    }//first param

    else
    {
        if ( abstraction_type.find(umddefs::first_prefix_param_relation)!= std::string::npos)
        {
            for (modification_iter = modification_sequence.begin(); modification_iter != modification_sequence.end(); ++modification_iter)
            {
                std::vector<std::string> tokens;
                std::string cur_token = "";
                split(*modification_iter, " ", tokens);
                cur_token.append(tokens[0]);
                cur_token.append(" ");
                cur_token.append("(");
                std::vector<std::string> vars;
                split(tokens[1], "-", vars);
                cur_token.append(vars[0]);
                cur_token.append(vars[1]);
                cur_token.append(")");
                cur_token.append("---");
                abstract_queue.push(cur_token);

            }
        }
        else
        {
            std::cout<<"get_abstract_modification: abstraction_type error";

        }
    }//first param_prefix

    // get the key
    std::string abstraction_key = "";
    while(!abstract_queue.empty()) {
        abstraction_key+= abstract_queue.top();
        abstract_queue.pop();
    }


    //std::cout<<"\n\n\n new abstraction key: ";
    //std::cout<<abstraction_key;
    return abstraction_key;
}




inline std::string get_abstract_modification_old(std::vector<std::string>& modification_sequence, std::string abstraction_type )
{

    std::string abstraction_key = "";
    std::vector<std::string>::iterator modification_iter;


    if ( abstraction_type.find(umddefs::first_param_relation)!= std::string::npos)
    {

        for (modification_iter = modification_sequence.begin(); modification_iter != modification_sequence.end(); ++modification_iter)
        {

            std::vector<std::string> tokens;
            split(*modification_iter, " ", tokens);
            abstraction_key.append(tokens[0]);
            abstraction_key.append(" ");
            abstraction_key.append("(");
            abstraction_key.append(tokens[1]);
            abstraction_key.append(")");
            abstraction_key.append("---");

        }
    }//first param

    else
    {
        if ( abstraction_type.find(umddefs::first_prefix_param_relation)!= std::string::npos)
        {
            for (modification_iter = modification_sequence.begin(); modification_iter != modification_sequence.end(); ++modification_iter)
            {
                std::cout<<"I am here\n";
                std::vector<std::string> tokens;
                split(*modification_iter, " ", tokens);
                abstraction_key.append(tokens[0]);
                abstraction_key.append(" ");
                abstraction_key.append("(");
                std::vector<std::string> vars;
                split(tokens[1], "-", vars);
                abstraction_key.append(vars[0]);
                abstraction_key.append(vars[1]);
                abstraction_key.append(")");
                abstraction_key.append("---");

            }
        }
        else
        {
            std::cout<<"get_abstract_modification: abstraction_type error";

        }
    }//first param_prefix




    //std::cout<<"\n\n\n abstraction key: ";
    //std::cout<<abstraction_key;
  //  std::cout<<" ## "<<std::endl;
    return abstraction_key;
}


inline mlppddl::PPDDLState* get_abstract_state(mlppddl::PPDDLState*  state, std::string abstraction_type)
{

    return NULL;


}


inline bool get_execution_state(mlppddl::PPDDLState*  original_state, mlppddl::PPDDLState&  execution_state, umd::ErUmdProblem* umdProblem)
{

    //remove atom
    //umdutils::remove_atom_from_state(&s_copy, umdProblem,"(coin-at c3 f1 p3)",*s_pddl);
    //string to atom map of the problem
    std::unordered_map<std::string, unsigned short>* stringAtomMap_ = new std::unordered_map<std::string, unsigned short>();

    std::cout<< "Before populate" <<std::endl;

    // string to atom map of the problem
    umdutils::populate_string_to_atom_map(*stringAtomMap_,umdProblem->getPPDDLProblem());

    std::cout<< "After populate" <<std::endl;

    umdutils::add_atom_to_state(&execution_state, umdProblem->getPPDDLProblem(),"(execution)",*original_state,*stringAtomMap_);



}


/**
* Remove an atom from a ppddl state set
* @param stat - state to modify
* @param atom_name - string representing the atom to remove
*/
inline void remove_atom_from_state(mlppddl::PPDDLState* original_state, mlppddl::PPDDLProblem* p_ppddl, std::string atom_name,mlppddl::PPDDLState& execution_state)
{


    //iterate through atoms to locate the design flag and remove it
    //iteration is performed on the original state (s_pddl) while deletion is performed on s_exeuction
    for( state_t::const_predicate_iterator ai = original_state->pState()->predicate_begin(); ai != original_state->pState()->predicate_end(); ++ai )
    {

        std::stringstream buffer;
        //get the atom
        const Atom *cur_atom = problem_t::atom_inv_hash_get( *ai );
        //set the buffer to the string of the atom
        p_ppddl->pProblem()->print( buffer, *cur_atom );


        //search for the key word
        if (buffer.str().find(atom_name) != std::string::npos)
        {
            //remove the predicate
            execution_state.pState()->clear(*cur_atom );
        }
     }//for

 }//remove_atom_from_state

inline void print_state(mlppddl::PPDDLProblem* p_ppddl, mlppddl::PPDDLState* state)
{

    //set the flag of design to false (initialzliation complete)
    //implemented by removing the atom from the list of atoms
    const Atom *cur_atom ;

    //iterate through atoms to locate the design flag and remove it
    //iteration is performed on the original state (s_pddl) while deletion is performed on s_exeuction
    for( state_t::const_predicate_iterator ai = state->pState()->predicate_begin(); ai != state->pState()->predicate_end(); ++ai )
    {

        //get the atom
        cur_atom = problem_t::atom_inv_hash_get( *ai );
        //set the buffer to the string of the atom
        p_ppddl->pProblem()->print( std::cout, *cur_atom );
    }//for


}//print_state


inline mlcore::Heuristic* getHeuristic(std::string heuristic_name , mlppddl::PPDDLProblem* umdProblem)
{
        unsigned long begTime  = (unsigned long) clock();
        unsigned long seconds_elapsed;

        mlcore::Heuristic*  heuristic ;

        if (heuristic_name.find(umddefs::zeroHeuristic)!= std::string::npos)
            {heuristic = new umd_heuristics::design_zeroHeuristic_t(*umdProblem->pProblem());}
        else
        {
            if(heuristic_name.find(umddefs::zeroPlusHeuristic)!= std::string::npos)
                {heuristic = new umd_heuristics::design_zeroPlusHeuristic_t(*umdProblem->pProblem());}

            else
            {

                if(heuristic_name.find(umddefs::hminFalseHeuristic)!= std::string::npos)
                {
                    heuristic =  new mlsolvers::HMinHeuristic(umdProblem,false);
               }

                else
                {

                    if (heuristic_name.find(umddefs::hminHeuristic)!= std::string::npos)
                    {

                        heuristic =  new mlsolvers::HMinHeuristic(umdProblem,true);
                    }
                    else
                    {
                        if(heuristic_name.find(umddefs::FFHeuristic)!= std::string::npos)
                        {heuristic = new mlppddl::PPDDLHeuristic(umdProblem, mlppddl::FF);}

                        else
                        {
                            if(heuristic_name.find(umddefs::atomMinMForwardHeuristic)!= std::string::npos)
                            {heuristic = new umd_heuristics::design_atomMinMForwardHeuristic_t(*umdProblem->pProblem(),2);

                            //heuristic = new mlppddl::PPDDLHeuristic(umdProblem, mlppddl::atomMinMForward,2);
                            }
                            else
                            {
                                if(heuristic_name.find(umddefs::atomMinMBackwardHeuristic)!= std::string::npos)
                                {heuristic = new mlppddl::PPDDLHeuristic(umdProblem, mlppddl::atomMinMBackward,2);}
                                else
                                {
                                    if(heuristic_name.find(umddefs::atomMin1ForwardHeuristic)!= std::string::npos)
                                    //{heuristic = new mlppddl::PPDDLHeuristic(umdProblem, mlppddl::atomMin1Forward);}
                                    {heuristic = new umd_heuristics::design_atomMin1ForwardHeuristic_t(*umdProblem->pProblem());}
                                    else
                                    {
                                        if(heuristic_name.find(umddefs::minminIDAHeuristic)!= std::string::npos)
                                        {

                                            umd_heuristics::design_zeroHeuristic_t* zeroHeur = new umd_heuristics::design_zeroHeuristic_t(*umdProblem->pProblem());

                                            heuristic = new umd_heuristics::design_minMinIDAHeuristic_t(*umdProblem->pProblem(),*zeroHeur,true);
                                        }

                                        else
                                        {

                                        if(heuristic_name.find(umddefs::sarahHeuristic)!= std::string::npos)
                                        {
                                            heuristic =  new umd::SarahHeuristic(umdProblem,true,umddefs::ITERATION_LIMIT);
                                        }
                                        else
                                        {throw std::invalid_argument( "heuritic type: " + heuristic_name + " not supported!" );}


                                        }
                    }}}}}}}}//else

        seconds_elapsed =  ((unsigned long) clock() - begTime);
        return heuristic;

}//getHeuristic



inline void print_policy_pddl(mlppddl::PPDDLProblem* problem)
{

     //Printing the policy map
    mlcore::StateSet bpsg = mlcore::StateSet();
    //std::cout << "Before getting solution graph  " << std::endl;
    //mlsolvers::getBestPartialSolutionGraph(umdProblem->getPPDDLProblem(), umdProblem->getPPDDLProblem()->initialState(),bpsg);
    mlsolvers::getBestPartialSolutionGraph(problem, problem->initialState() ,bpsg);
    //std::cout << "After getting solution graph  " << std::endl;
    std::cout << "Solution graph size: "<<bpsg.size()<< std::endl;



    mlcore::StateSet::const_iterator iterator;
    mlcore::Action* bestAction = NULL;

    for (iterator = bpsg.begin(); iterator != bpsg.end(); ++iterator) {
        std::cout << "iterator:"<<*iterator<< " ";
        //std::cout << endl<<"Before getting best action"<<endl;
        bestAction = mlsolvers::greedyAction(problem, *iterator);
        //std::cout << endl<<"After getting best action"<<endl;
        if (bestAction)
        {std::cout << bestAction<<std::endl;
        std::cout << (*iterator)->cost()<<std::endl;
        }

        else
        {std::cout << "Goal State"<<std::endl;}


    }//for


}//print_policy

inline void print_policy(umd::ErUmdProblem* umdProblem)
{

    print_policy_pddl(umdProblem->getPPDDLProblem());
}



inline mlcore::State* mostLikelyOutcome(mlcore::Problem* problem, mlcore::State* s,
                                 mlcore::Action* a, bool random)
{

    if (random)
    {
        double prob = -1.0;
        double eps = 1.0e-6;
        std::vector<mlcore::State*> outcomes;
        for (mlcore::Successor sccr : problem->transition(s, a)) {
            if (sccr.su_prob > prob + eps) {
                prob = sccr.su_prob;
                outcomes.clear();
                outcomes.push_back(sccr.su_state);
            } else if (sccr.su_prob > prob - eps) {
                outcomes.push_back(sccr.su_state);
            }
        }
        return outcomes[rand() % outcomes.size()];
    }//if
    else //most likely
    {
        mlcore::State* max_prob_state = NULL;
        double max_prob = 0.0;
        for (mlcore::Successor sccr : problem->transition(s, a)) {
            if (sccr.su_prob > max_prob) {
                max_prob = sccr.su_prob;
                max_prob_state = sccr.su_state;
            }//if
        }
        return max_prob_state;
    }
}


/*
    // all the modifications applied in the current state
    std::string applied_modifications;
    //applied_modifications.append("");

    std::string start_delimiter = ":(enabled";
    std::string end_delimiter = ")";

    size_t start_pos = 0;
    size_t end_pos = 0;
    std::string token;

    while ((start_pos = buffer.str().find(start_delimiter,start_pos)) != std::string::npos) {
        std::cout<< start_pos <<std::endl<<std::endl;
        end_pos = buffer.str().find(end_delimiter,start_pos);
        std::cout<< end_pos <<std::endl<<std::endl;
        std::string modification = buffer.str().substr(start_pos, end_pos);
        std::cout << "modificstion is:" <<modification << std::endl<<std::endl;
        start_pos = end_pos;
        //s.erase(0, end_pos);
    }

//print abstract sequence
        std::vector<std::string>::iterator modification_iter_abstract ;
        for (modification_iter_abstract = abstract_sequence.begin(); modification_iter_abstract != abstract_sequence.end(); ++modification_iter_abstract)
        {
            std::string modification = *modification_iter_abstract;
            std::cout<" abstract modification "<< modification;
        }
*/
}
#endif // UMDUTILS_H_INCLUDED
