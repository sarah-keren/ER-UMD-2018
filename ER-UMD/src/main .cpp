#include <sstream>
#include <iostream>



#include "../include/UMDHeuristic.h"
#include "../include/PDBHeuristic.h"
#include "../include/UmdDefs.h"
#include "../include/UmdUtils.h"


#include "./ppddl/mini-gpt/problems.h"
#include "./ppddl/mini-gpt/states.h"
#include "./ppddl/mini-gpt/domains.h"
#include "./ppddl/mini-gpt/states.h"
#include "./ppddl/mini-gpt/exceptions.h"




using namespace std;


extern int yyparse();


extern FILE* yyin;
string current_file;
int warning_level = 0;
int verbosity = 0;



/* Parses the given file, and returns true on success. */
static bool read_file( const char* name )
{

    yyin = fopen( name, "r" );
    if( yyin == NULL ) {
        std::cout << "parser:" << name <<
            ": " << strerror( errno ) << std::endl;
        return( false );
    }
    else {
        current_file = name;
        bool success;
        try {
            success = (yyparse() == 0);


        }
        catch( Exception exception ) {
            fclose( yyin );
            std::cout << "exception in yyparse : "<<exception << std::endl;
            return( false );
        }

        fclose( yyin );
        return( success );
    }
}

bool parse_problem ( std::string file, std::string prob)
{
    //std::cout<< "parse_problem " << file.c_str()<< ":"<< prob<<std::endl;

    if( !read_file( file.c_str() ) ) {
        std::cout <<
            "<main>: ERROR: couldn't read problem file `" << file << std::endl;
        return false;
    }
    //std::cout<< "read_file " << file<< ":"<<std::endl;
    return true;

}//parse_problem


// given the input ERUMD problem - parse the command
umd::UmdHeuristic* parse_command(int argc, char **argv, umd::ErUmdProblem* umdProblem, std::string command_type, std::string solverName)
{



    //design hueristic
    mlcore::Heuristic* desHeuristic= NULL;
    //execution hueristic
    mlcore::Heuristic* exeHeuristic = NULL;
    //umd hueristic
    umd::UmdHeuristic* umdHeuristic = NULL;
    //simplified version
    mlppddl::PPDDLProblem* simplifiedProblem = NULL;

    //relaxed method (e.g. large epsilon) - NA
    bool isRelaxedMethod = false;

    if ((command_type.find(umddefs::compilation) != std::string::npos)||(command_type.find(umddefs::original) != std::string::npos))
    {
        std::string heuristic_name = argv[5];
        exeHeuristic = umdutils::getHeuristic(heuristic_name,umdProblem->getPPDDLProblem());
        desHeuristic = NULL;
        umdHeuristic = new umd::UmdHeuristic(umdProblem->getPPDDLProblem(),NULL,desHeuristic,exeHeuristic,isRelaxedMethod, umdProblem->getDomainName());
        return umdHeuristic;
        //std::cout<< "exeheuristic " << heuristic_name<< "desheuristic = null with problem " << umdProblem->getPPDDLProblem()->pProblem()->name()<<std::endl;
    }//if

    if (command_type.find(umddefs::bfs_design) != std::string::npos)
    {
        std::string heuristic_name = argv[5];
        exeHeuristic = umdutils::getHeuristic(heuristic_name,umdProblem->getPPDDLProblem());
        desHeuristic = umdutils::getHeuristic(umddefs::zeroHeuristic,umdProblem->getPPDDLProblem());
        umdHeuristic = new umd::UmdHeuristic(umdProblem->getPPDDLProblem(),NULL,desHeuristic,exeHeuristic,isRelaxedMethod, umdProblem->getDomainName());
        return umdHeuristic;
    }//if

    // we are here only with BFD so we get the relaxed file according to the command
    std::string heuristic_name = argv[5];
    exeHeuristic = umdutils::getHeuristic(heuristic_name,umdProblem->getPPDDLProblem());
    std::string file = argv[1];
    std::string problem_name = argv[2];
    std::string relaxed_prob = umdutils::get_relaxed_problem_name(file,problem_name,command_type);
    std::cout<<"Relaxed problem:: " << relaxed_prob.c_str()<<"\n";

    //create a simplified problem
    problem_t * simplified_problem =  (problem_t*) problem_t::find( relaxed_prob.c_str() );
    if(!simplified_problem)
    {
        std::cout << "Parse error in umddefs::simplified with file"<< file<<"\n";
        exit(0);
        return  NULL;
    }//if
    simplifiedProblem = new mlppddl::PPDDLProblem(simplified_problem);

    // get the suitable design heuristic
    desHeuristic = umdutils::getHeuristic(heuristic_name,simplifiedProblem);
    if((command_type.find(umddefs::relaxed_design_process) != std::string::npos)|| (command_type.find(umddefs::relaxed_combined_design_process) != std::string::npos))
    {
        umdHeuristic  = new umd::PDBHeuristic (umdProblem->getPPDDLProblem(), simplifiedProblem, desHeuristic,exeHeuristic,isRelaxedMethod, umdProblem->getDomainName());
        return umdHeuristic;
    }

    if((command_type.find(umddefs::relaxed_environment) != std::string::npos)|| (command_type.find(umddefs::relaxed_modification) != std::string::npos)|| (command_type.find(umddefs::relaxed_combined) != std::string::npos))
    {
       umdHeuristic = new umd::UmdHeuristic(umdProblem->getPPDDLProblem(),simplifiedProblem,desHeuristic,exeHeuristic,isRelaxedMethod, umdProblem->getDomainName());
       return umdHeuristic;
    }

    // if this code is reached it is due an error
    std::cout << "Error in calc method definition: "<< command_type<< "\n";
    exit(0);
    return  NULL;


}


int perform_testing (int argc, char **argv)
{

    try
    {
        //start timer
        unsigned long begTime = clock();;
        double  seconds_elapsed;



        //get problem
        std::string file = argv[1];//"/home/sarah/Documents/GoalRecognitionDesign/Redesign/Benchmarks/Redesign-Benchmakrs-2008/Current/triangle-tireworld-simplified-new-8/joint/p1/p1-domain-design-add-road-service.pddl"; /
        std::string prob = argv[2]; //"p1"
        std::string solverName = argv[3];


        //Parse ppddl problem using mgpt parser

        std::cout<< "File:: " << file << std::endl;
        std::cout<< "Problem:: " << prob << std::endl;
        std::cout<< "Solver :: " << solverName << std::endl;

        //parse the ppddle file (all problems are witihn the class problem_t)
        if(!parse_problem(file,prob))
        {
            std::cout << "Parse error \n";
            exit(0);
            return -1;
        }//if

        //get the original problem
        problem_t* problem = (problem_t*) problem_t::find( prob.c_str() );
        if( !problem ) {
            std::cout << "<main>: ERROR: problem `" << prob <<
            "' is not defined in file '" << file << "'" << std::endl;
            return NULL;
        }
        //std::cout<< "found problem  " << prob.c_str()<<std::endl;


        //std::cout<<"Problem:: " << problem->name()<< "\nDomain::  "<< problem->domain().name();

        //ge the mdp to be used at the tip nodes
        std:string prob_tip = prob+umddefs::TIP;
        //std::cout<<"Serching for problem " << prob_tip<<std::endl;
        problem_t * problem_tip_nodes =  (problem_t*) problem_t::find( prob_tip.c_str() );
        if(!problem_tip_nodes)
        {
            std::cout << "Parse error \n";
            exit(0);
            return -1;
        }//if

        //create erumd problem
        umd::ErUmdProblem* umdProblem = new umd::ErUmdProblem(problem,problem_tip_nodes,solverName);

        //get analysis type
        std::string command_type = argv[4];
        std::cout<<"Command type:: " << command_type <<std::endl;
        std::string heuristic_name = argv[5];
        std::cout<<"Heuristic_name:: " << heuristic_name <<std::endl;


        //parse input and get heuristic
        umd::UmdHeuristic* umdHeur = parse_command(argc, argv,umdProblem,command_type,solverName);
        //cout<<"Init State: "<<umdProblem->getPPDDLProblem()->initialState()<<" Starting execution" << std::endl;

        // solve the problem
        umdProblem->solve(umdHeur,true,command_type);






        //log results
        //cout<<"Heuristic approach:: "<< argv[4] <<endl;
        //cout<<"Solver heuristic:: "<< argv[5] <<endl;
        seconds_elapsed =  ((unsigned long) clock() - begTime)/(CLOCKS_PER_SEC/1.0);
        cout<<"Total time:: "<<seconds_elapsed<<endl;




        //cout<<umddefs::deliminator<<seconds_elapsed<<endl;
        //umdutils::print_policy(umdProblem);


        //CLEAN UP
        delete umdProblem;

        }
        catch( Exception exception ) {

            std::cout << "exception in perform_testing : "<<exception << std::endl;
            throw exception;

        }

        return 0;
}


int main(int argc, char **argv)
{



    if (argc < 2) {
        std::cout << "Usage: umd [file] [problem]\n";
        return -1;
    }

    return perform_testing(argc,argv);
    ////return testing_modifying_states(argc,argv);
    //return testing_grd_compiled(argc,argv);

}
