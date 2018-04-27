#include <queue>

#include "../../include/solvers/DeterministicSolver.h"

namespace mlsolvers
{

mlcore::Action* DeterministicSolver::solve(mlcore::State* s0)
{
    NodeComparer comp();
    std::priority_queue<Node*, std::vector<Node*>, NodeComparer> frontier(comp);
    Node* init = new Node(nullptr, s0, nullptr, 0.0, heuristic_);
    frontier.push(init);
    std::list<Node*> allNodes;  // for memory clean-up later
    allNodes.push_back(init);
    Node* final = nullptr;
    Node* node = nullptr;
    while (!frontier.empty()) {

        /*TODO: SARAH delete*/
        this->iteration_counter += 1;

        /*
        std::cout << " \n the queue in deterministic solver:\n";
        std::priority_queue<Node*, std::vector<Node*>, NodeComparer> cpy(frontier);
        while (!cpy.empty())
        {
            std::cout << cpy.top()->state()<< "with value g: " << cpy.top()->g()<< " and f: "<< cpy.top()->f() <<std::endl;
            cpy.pop();
        }
        std::cout<< " - - - - " <<std::endl;
        */

        /*TODO: SARAH end delete*/

        node = frontier.top();
        frontier.pop();

        //std::cout<< "\n in DeterministicSolver::solve. Extracting from queue state" << node->state() << std::endl;

        //make sure the state has not been visited
        if (node->state()->checkBits(mdplib::VISITED_ASTAR))
            continue;   // valid because this is using path-max
        node->state()->setBits(mdplib::VISITED_ASTAR);

        //goal found
        if (problem_->goal(node->state())) {
            //std::cout<< "\nn DeterministicSolver::solve. Solution found" << node->state();
            //std::cout<<"Goal found::" << node->state()<<" cost::"<< node->f()<< "\ng() value::"<< node->g()<< "  \niteration_counter: "<<iteration_counter <<std::endl;
            break;
            /*
            mlcore::Action* optimal = nullptr;
            Node* cur_node = node;
            while (cur_node->parent() != nullptr) {
                optimal = cur_node->action();
                cur_node = cur_node->parent();
            }

            std::cout<< " s0:: " << s0 <<std::endl;
            std::cout<< " cur_node:: " << cur_node->state() <<std::endl;
            std::cout<< " optimal action:: " << optimal <<std::endl;
            return optimal;
            */
            }

        //insert successors
        for (mlcore::Action* a : problem_->actions()) {
            if (!problem_->applicable(node->state(), a))
                continue;



            mlcore::State* nextState = nullptr;
            if (choice_ == det_most_likely)
            {

                nextState = mostLikelyOutcome(problem_, node->state(), a);

                double cost = problem_->cost(node->state(), a);

                Node* next = new Node(node, nextState, a, cost, heuristic_, true);
                frontier.push(next);
                allNodes.push_back(next);
            }
            else
            {

                std::list<std::pair<mlcore::State*, double>> next_states = problem_->transition(node->state(), a);
                std::list<std::pair<mlcore::State*, double>>::iterator it_states;
                for (it_states = next_states.begin(); it_states != next_states.end(); ++it_states) {

                    mlcore::State* suc_state = (*it_states).first;
                    double cost = problem_->cost(suc_state, a);
                    Node* next = new Node(node, nextState, a, cost, heuristic_, true);
                    frontier.push(next);
                    allNodes.push_back(next);

                } //for


         }//else


        }
    }//while


    //std::cout<<" Search is over - now looking for the optimal action " <<std::endl;
    mlcore::Action* optimal = nullptr;
    Node* cur_node = node ;
    double cost_path = 0.0;
    while (cur_node->parent() != nullptr) {
        optimal = cur_node->action();
        cost_path += problem_->cost(cur_node->state(), optimal);
        cur_node = cur_node->parent();
    }
    std::cout << "A* Cost:: " << cost_path << std::endl;
    //std::cout<<"cur_node: "<<cur_node->state()<<std::endl;
    std::cout<<"Optimal action:: " <<optimal<<std::endl;

    for (Node* node : allNodes) {
        node->state()->clearBits(mdplib::VISITED_ASTAR);
        delete node;
    }

    return optimal;
}

}
