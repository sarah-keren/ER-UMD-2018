#include <stdio.h>

#include "../include/UMDProblem.h"
#include "../include/UmdDefs.h"
#include "../include/UmdUtils.h"
#include "./solvers/Solver.h"
#include "./solvers/FLARESSolver.h"
#include "./solvers/LAOStarSolver.h"
#include "./solvers/DeterministicSolver.h"
#include "./solvers/LRTDPSolver.h""
#include "../include/ErUmdProblem.h"

#include <sstream>
/*
#include "./reduced/PPDDLTaggedReduction.h"
#include "./reduced/ReducedHeuristicWrapper.h"
#include "./reduced/ReducedModel.h"
#include "./reduced/ReducedState.h"
#include "./reduced/ReducedTransition.h"

#include "./solvers/FFReducedModelSolver.h"
*/
namespace umd
{

ErUmdProblem::ErUmdProblem(problem_t* pProblem):mlppddl::PPDDLProblem (pProblem)
{

    ppddlProblem_ = new mlppddl::PPDDLProblem (pProblem);
    domainName_ = pProblem->domain().name();


}

ErUmdProblem::ErUmdProblem(problem_t* pProblem, std::string str_fileName, std::string str_problemName, std::string str_domainName ):mlppddl::PPDDLProblem (pProblem)
{

    ppddlProblem_ = new mlppddl::PPDDLProblem (pProblem);
    fileName(str_fileName);
    problemName(str_problemName);
    domainName(str_domainName);


}

ErUmdProblem::~ErUmdProblem()
{
 if (ppddlProblem_)
 {    delete ppddlProblem_;
 }

}


void ErUmdProblem::solve(UmdHeuristic* umdHeur,std::string solverName, bool timed, std::string command_type)
{
    // solve the compilation with a single search
    if (command_type.find(umddefs::compilation) != std::string::npos)
    {

        this->ppddlProblem_->setHeuristic(umdHeur->get_executionHeuristic_());
        mlsolvers::LAOStarSolver solver(this->ppddlProblem_);
        solver.solve(this->ppddlProblem_->initialState());
        double cost = this->ppddlProblem_->initialState()->cost();
        std::cout << "Initial state:: "<<this->ppddlProblem_->initialState() <<std::endl;
        std::cout<< "Expected cost:: "<< this->ppddlProblem_->initialState()->cost()<<std::endl;
        //umdutils::print_policy_pddl(this->ppddlProblem_);
        std::cout << "Best action:: "<< this->ppddlProblem_->initialState()->bestAction() << std::endl;


    }


    else
    {
        //mlcore::Heuristic* heuristic =  umdutils::getHeuristic(umddefs::atomMinMForwardHeuristic,this);
        mlsolvers::DeterministicSolver solver (this, mlsolvers::det_most_likely, umdHeur);
        std::cout << "Initial state:: " << this->initialState() <<std::endl;
        mlcore::Action* best_action = solver.solve(this->initialState());
        std::cout << "Expected cost:: "<< this->initialState()->cost()<<std::endl;
        std::cout << "Best action:: " << best_action <<std::endl;
        return;
    }


}

/*
void ErUmdProblem::solve_compilation(mlcore::Heuristic* heur)
{    // else -  the cost is that of the underlaying mdp

    this->ppddlProblem_->setHeuristic(heur);
    mlsolvers::LAOStarSolver solver(this->ppddlProblem_);
    solver.solve(this->initialState());
    double cost = this->initialState()->cost();
    std::cout << "\n for state: "<<this->initialState() << " cost is:  "<< this->initialState()->cost()<<std::endl;




}
*/

 bool ErUmdProblem::goal(mlcore::State* s) const
 {

    //std::cout << "in goal with state" << s << std::endl;
    // the goal is achieved when the extracted noded is an execution node
    std::stringstream buffer;
    buffer<<(mlppddl::PPDDLState*)s;

    if (buffer.str().find(umddefs::execution_stage_string) != std::string::npos)
    {
        //std::cout << "at goal : execution node" << std::endl;
        return true;

    }
    //std::cout << "not yet at goal" << std::endl;

    return false;
 }

double ErUmdProblem::cost(mlcore::State* s, mlcore::Action* a) const
{

    std::string actionName = ((mlppddl::PPDDLAction*)a)->pAction()->name();
    //std::cout << "\n in cost with state" << s << " and action "<< a<< std::endl;

    // for design actions that do not start execution
    if (actionName.find(umddefs::design_start_execution) == std::string::npos)
    {
        if (actionName.find(umddefs::design_stage_string) != std::string::npos)
        {
            if(actionName.find(umddefs::idle_string) != std::string::npos)
            {
                // if the action is a idle design action - the cost is epsilon/2
                //std::cout << " cost is " << 1.0e-4/2 << std::endl;
                return 1.0e-4/2;
            }
            else
            {
                // if the action is a design action - the cost is epsilon
                //std::cout << " cost is " << 1.0e-4 << std::endl;
                return 1.0e-4;
            }

        }
        else
        {
            std::cout<< "Error in ErUmdProblem::cost with action " <<actionName <<std::endl;
            throw Exception( "Error in ErUmdProblem::cost with action " + actionName );


        }


    }

    else
    {
            // if the action is a start execution action the cost is 0
            //std::cout << " cost is " << 0.0 << std::endl;
            //return 0.0;
    // else -  the cost is that of the underlaying mdp
    mlsolvers::LAOStarSolver solver(this->ppddlProblem_);
    auto successors = ppddlProblem_->transition(s,a);
    mlcore::State* s0 = successors.front().su_state;
    solver.solve(s0);
    double cost = s0->cost();
    //std::cout << "\n for state: "<<s << " and successor state: " << s0 <<" cost is:  "<< cost<<std::endl;
    return cost;

}






}

void ErUmdProblem::solve_(UmdHeuristic* umdHeur,std::string solverName, bool timed)
{


    unsigned long begTime;
    double  seconds_elapsed;

    //start timer
    if(timed)
    {
        begTime = clock();
    }

    //<< " " << "umdHeur cost" << umdHeur->cost(problem->initialState())<<std::endl;
    //<< " " << "umdHeur cost" << umdHeur->cost(problem->initialState())<<std::endl;


    mlcore::State* init = this->ppddlProblem_->initialState();


    this->ppddlProblem_->setHeuristic(umdHeur);

   if (solverName == umddefs::solverLAO) {
        mlsolvers::LAOStarSolver solver(this->ppddlProblem_);
        //std::cout << "solving..."<<std::endl;
        solver.solve(this->ppddlProblem_->initialState());
        std::cout << "solver state count: "<< solver.m_totalExpanded<<std::endl;
    } else if (solverName == umddefs::solverLRTDP) {
        int ntrials = umddefs::lrtdp_trials;//5000 ;
        double epsilon = umddefs::lrtdp_epsilon;//0.0001 ;
        mlsolvers::LRTDPSolver solver(this->ppddlProblem_, ntrials,epsilon);
        solver.solve(this->ppddlProblem_->initialState());
     } else if (solverName == umddefs::solverFLARES) {
                                                                                std::cout << "FLARES!" << std::endl;
        int ntrials = umddefs::lrtdp_trials;//5000 ;
        double epsilon = umddefs::lrtdp_epsilon;//0.0001 ;
        mlsolvers::FLARESSolver solver(
            this->ppddlProblem_, ntrials, epsilon, 4);
        double expectedCost = 0.0;
        double expectedTime = 0.0;
        for (int sim = 0; sim < 100; sim++) {
            double cost = 0.0;
            double planningTime = 0.0;
            for (mlcore::State* s : this->ppddlProblem_->states())
                s->reset();
            mlcore::State* currentState = this->ppddlProblem_->initialState();
            unsigned long startTime = clock();
            solver.solve(currentState);
            unsigned long endTime = clock();
            planningTime += (double(endTime - startTime) / CLOCKS_PER_SEC);
            mlcore::Action* action = currentState->bestAction();
            while (cost < mdplib::dead_end_cost) {
                cost += this->ppddlProblem_->cost(currentState, action);
                // The successor state according to the
                // original transition model.
                mlcore::State* nextState =
                    mlsolvers::randomSuccessor(
                        this->ppddlProblem_, currentState, action);
                if (this->ppddlProblem_->goal(nextState)) {
                    break;
                }
                currentState = nextState;
                // Re-planning if needed.
                if (!currentState->checkBits(mdplib::SOLVED_FLARES)) {
                    startTime = clock();
                    solver.solve(currentState);
                    endTime = clock();
                    planningTime +=
                        (double(endTime - startTime) / CLOCKS_PER_SEC);
                }
                if (currentState->deadEnd()) {
                    cost = mdplib::dead_end_cost;
                }
                action = currentState->bestAction();
            }
            expectedCost += cost;
            expectedTime += planningTime;
        }
        std::cout << "expectedCost " << expectedCost / 100 << " "
                  << "expectedTime " << expectedTime / 100 << std::endl;
        return;

     }
     /*
      else if (solverName == umddefs::solverFFLAO) {

        std::string base_dir =
            "/home/lpineda/Dropbox/er-umd-2018/mdp-lib-umd/scripts/reduced";
        using namespace mlreduced;
        // Creating all possible determinizations.
        std::string outputDetFilename = "/tmp/" + domainName_;
        std::string create_all_det_cmd =
            base_dir + "/create_all_determinizations.py";
        create_all_det_cmd += " -d " + fileName_;
        create_all_det_cmd += + " -o " + outputDetFilename;
        create_all_det_cmd += + " -n " + domainName_;
                                                                                std::cerr << create_all_det_cmd << std::endl;
        FILE* pipeDet = popen(create_all_det_cmd.c_str(), "r");
        pclose(pipeDet);
                                                                                std::cerr << "HERE" << std::endl;

        // Setting template problem used by FF.
        std::string templateFilename = "/tmp/ff-template";
        std::string setup_template_cmd = base_dir + "/setup_ff_template.py";
        setup_template_cmd += " -p " + fileName_;
        setup_template_cmd += " -o " + templateFilename;
        setup_template_cmd += " -n " + problemName_;
                                                                                std::cerr << setup_template_cmd << std::endl;
        FILE* pipeTmpl = popen(setup_template_cmd.c_str(), "r");
        pclose(pipeTmpl);

        // Solving the reduced model.
        int k = 0;
        std::string detNumber = "0";
        mlreduced::ReducedTransition* reduction =
            new mlreduced::PPDDLTaggedReduction(
                this->ppddlProblem_,
                outputDetFilename + "_det" + detNumber + ".desc");
        mlreduced::ReducedModel* reducedModel =
            new mlreduced::ReducedModel(this->ppddlProblem_, reduction, k);
        mlreduced::ReducedHeuristicWrapper* reducedHeuristic =
            new mlreduced::ReducedHeuristicWrapper(
                this->ppddlProblem_->heuristic());
        reducedModel->setHeuristic(reducedHeuristic);
        // Solving reduced model using LAO* + FF.
        mlsolvers::FFReducedModelSolver solver(
            reducedModel,
            "/home/lpineda/Desktop/FF-v2.3/ff",
            outputDetFilename + "_det" + detNumber + ".pddl",
            templateFilename,
            k, 1.0e-3, true);

        double expectedCost = 0.0;
        double expectedTime = 0.0;
        for (int sim = 0; sim < 100; sim++) {
            double cost = 0.0;
            double planningTime = 0.0;
            for (mlcore::State* s : reducedModel->states())
                s->reset();
            ReducedState* currentState =
                static_cast<ReducedState*> (reducedModel->initialState());
            unsigned long startTime = clock();
            solver.solve(currentState);
            unsigned long endTime = clock();
            planningTime += (double(endTime - startTime) / CLOCKS_PER_SEC);
            mlcore::Action* action = currentState->bestAction();
            while (cost < mdplib::dead_end_cost) {
                cost += this->ppddlProblem_->cost(currentState->originalState(), action);
                // The successor state according to the
                // original transition model.
                mlcore::State* nextOriginalState =
                    mlsolvers::randomSuccessor(this->ppddlProblem_,
                                               currentState->originalState(),
                                               action);

                if (this->ppddlProblem_->goal(nextOriginalState)) {
                    break;
                }

                bool isException =
                    reducedModel->isException(currentState->originalState(),
                                              nextOriginalState,
                                              action);
                int exceptionCount =
                    currentState->exceptionCount() + int(isException);
                currentState = new ReducedState(nextOriginalState,
                                                exceptionCount,
                                                reducedModel);

                // Re-planning if needed.
                if (currentState->bestAction() == nullptr ||
                        exceptionCount > k) {
                    currentState->exceptionCount(0);
                    currentState = static_cast<ReducedState*> (
                        reducedModel->addState(currentState));
                    startTime = clock();
                    solver.solve(currentState);
                    endTime = clock();
                    planningTime +=
                        (double(endTime - startTime) / CLOCKS_PER_SEC);
                }

                if (currentState->deadEnd()) {
                    cost = mdplib::dead_end_cost;
                }

                action = currentState->bestAction();
            }
            expectedCost += cost;
            expectedTime += planningTime;

          std::cout<<"In comments" <<std::endl;
        }
        std::cout << "expectedCost " << expectedCost / 100 << " "
                  << "expectedTime " << expectedTime / 100 << std::endl;
        return;
        }
    */
     else //unrecognized solver
    {
        {throw std::invalid_argument( "solver: " + solverName + " not supported!" );}
    }




    if(timed)
    {
        /*
        std::cout << "solver name:  "<<solverName << std::endl;
        std::cout << "s0:  "<<this->ppddlProblem_->initialState() << std::endl;
        std::cout << "Value of s0:  "<<this->ppddlProblem_->initialState()->cost() << std::endl;
        std::cout << "Best action of s0: "<< this->ppddlProblem_->initialState()->bestAction() << std::endl;
        seconds_elapsed =  ((unsigned long) clock() - begTime)/(CLOCKS_PER_SEC/1.0);
        std::cout << "Elapsed time:  " << seconds_elapsed << std::endl;
        std::cout<<"Time to evaluate design: "  << umdHeur->time_spent_varifying<< std::endl;
        std::cout<<"Ratio of time to evaluate design: " << umdHeur->time_spent_varifying/seconds_elapsed<< std::endl;
        std::cout<<"Number of explored states: " << umdHeur->state_count<< std::endl;
        std::cout<<"Number of design states: " << umdHeur->design_state_count<< std::endl;
        std::cout<<"Number of execution states: " << umdHeur->execution_state_count<< std::endl;
       */


        std::cout << "solver name:  "<< solverName<<std::endl;
        std::cout << "init state:  "<<this->ppddlProblem_->initialState()<<std::endl;
        std::cout << "init cost:  "<< this->ppddlProblem_->initialState()->cost()<<std::endl;
        std::cout << "best action:  "<<this->ppddlProblem_->initialState()->bestAction()<<std::endl;
        seconds_elapsed =  ((unsigned long) clock() - begTime)/(CLOCKS_PER_SEC/1.0);
        std::cout << "seconds elapsed: "<<seconds_elapsed<<std::endl;
        std::cout << "state count: "<< umdHeur->state_count<<std::endl;
        //std::cout<< "optimal policy: \n";
        //umdutils::print_policy(this);


        //std::cout<<  umdHeur->time_spent_varifying<<std::endl;
        //std::cout<<  umdHeur->time_spent_varifying/seconds_elapsed<<std::endl;
        //std::cout<<  umdHeur->state_count<<std::endl;
        //std::cout<<  umdHeur->design_state_count<<std::endl;
        //std::cout<<  umdHeur->execution_state_count<<std::endl;

        /*mlcore::StateSet::const_iterator iterator;
        mlcore::StateSet bpsg4 = mlcore::StateSet();
        mlsolvers::getBestPartialSolutionGraph(ppddlProblem_, ppddlProblem_->initialState(),bpsg4);
        mlcore::Action* bestAction = NULL;

        for (iterator = bpsg4.begin(); iterator != bpsg4.end(); ++iterator) {
            std::cout << std::endl<<"iterator:"<<*iterator<< " ";
            //std::cout << std::endl<<"Before getting best action"<<std::endl;
            bestAction = mlsolvers::greedyAction(ppddlProblem_, *iterator);
            //std::cout << std::endl<<"After getting best action"<<std::endl;
            if (bestAction)
            {std::cout << bestAction<< " cost: " << (*iterator)->cost()<<std::endl;}

            else
            {std::cout << "Goal State"<<std::endl;}
        }//for
        */


    }

}//execute


}
