__author__ = 'sarah'
__author__ = 'sarah'
import sys, os

BFD_HEURISTIC_TYPES = {'combined-rel-proc','rel-proc','rel-combined','rel-mod','rel-env','compilation','bfs_design'}
MDP_HEURISTIC_TYPES = {'hmin-heur-false','AM1F'}
BUDGET_ARRAY = {0,1,2,3,4,5,6}
NEW_BM_DELIMINATOR = '- - - -'
#NEW_BM_DELIMINATOR = '---/home/'
NEW_BM_DELIMINATOR = '---../umd-Benchm'

#---../umd-B
NUMBER_OF_STEPS_TO_JUMP = 3

def parse_result_file(results_folder_name, output_file,domain, is_optimal):

    # initialize
    heuristic_dictionary = {}
    for mdp_heur in MDP_HEURISTIC_TYPES:
        heuristic_dictionary[mdp_heur] = {}
        for budget in BUDGET_ARRAY:
            heuristic_dictionary.get(mdp_heur)[int(budget)] = {}

    #for heuristic_approach in BFD_HEURISTIC_TYPES:
    #        for mdp_heur in MDP_HEURISTIC_TYPES:

    for filename in os.listdir(results_folder_name):
        results_file = open(os.path.join(results_folder_name,filename), 'r')
        #output_file  = open(output_file,'a')
        lines = results_file.readlines()
        line_index = 0
        while line_index < len(lines):
            iteration_counter = -1
            cost = -1
            time = -1
            problem_name  = 'error'
            budget = -1
            command_type = 'error'
            heuristic_name ='error'
            line = lines[line_index]

            if NEW_BM_DELIMINATOR in line :
                # read 6 lines
                #print('new benchmark found')
                line_index = line_index + NUMBER_OF_STEPS_TO_JUMP
                bm_name =lines[line_index].split()[-1]
                if len(bm_name.split('-')) == 1:
                    problem_name = bm_name
                else:
                    problem_name =bm_name.split('-')[0]

                #print('problem_name: %s'%problem_name)
                #problem_name = lines[line_index].split()[0]
                #print('problem name is %s'%problem_name)
                if len(bm_name.split('-')) == 1:
                    budget = 0
                else:
                    budget =bm_name.split('-')[1]

                #print('budget: %s'%budget)
                line_index = line_index + 2
                command_type = lines[line_index].split()[-1]
                #print('command_type: %s'%command_type)
                line_index = line_index + 1
                heuristic_name = lines[line_index].split()[-1]
                #print('heuristic_name: %s'%heuristic_name)

                time_out = False
                eof = False
                #look for cost
                while 'cost' not in lines[line_index]:
                    # the problem timed out - break
                    if NEW_BM_DELIMINATOR in lines[line_index]:
                        time_out = True
                        break
                    line_index += 1
                    # end of file reached
                    if line_index >= len(lines):
                        eof = True
                        break

                if not (time_out or eof):
                    cost = lines[line_index].split()[-1].replace('cost::','')
                    #print('cost: %s'%cost)

                    if 'compilation' not in command_type:
                        # get iteration counter
                        while 'iteration_counter:' not in lines[line_index]:
                            line_index += 1

                        iteration_counter = lines[line_index].split()[-1]
                        #print('iteration_counter: %s'%iteration_counter)
                    else:
                        iteration_counter = 1

                    # get time
                    while 'time' not in lines[line_index]:
                        line_index += 1

                    time = lines[line_index].split()[-1]
                    #print('time: %s'%time)

                    #print('- - - - - - - ')
                # add to table
                #iteration_counter = -1
                #cost = -1
                #time = -1
                #problem_name  = 'error'

                #budget = -1
                #command_type = 'error'
                #heuristic_name ='error'
                budget = int(budget)
                heuristic_map = heuristic_dictionary.get(heuristic_name).get(budget)
                if not heuristic_map.get(problem_name):
                    heuristic_map[problem_name] = {}

                problem_map =  heuristic_map.get(problem_name)
                problem_map[command_type] = [float(cost),int(iteration_counter),float(time)]


            line_index = line_index+1


    #print(heuristic_dictionary)
    return heuristic_dictionary


def analyze_dictionary(heuristic_dictionary):

    #for heuristic in MDP_HEURISTIC_TYPES:
    #    print('\nheuristic %s:'%heuristic)
    #    print('--------------\n')

    #heuristic_map = heuristic_dictionary['AM1F']
    heuristic_map = heuristic_dictionary['hmin-heur-false']

    for budget in BUDGET_ARRAY:
        print('\nbudget: %d'%budget)
        print('- - - -')

        budget_map = heuristic_map[budget]

        nodes ={}
        time ={}
        for method in BFD_HEURISTIC_TYPES:
            nodes[method] = 0
            time[method] = 0.0

        instance_count = 0
        for problem in budget_map.keys():
            cur_problem = budget_map[problem]
            #check that all methods have been solved
            #print(len(cur_problem.keys()))
            if len(cur_problem.keys())== 7:
                instance_count = instance_count+1

                nodes['rel-proc'] += cur_problem.get('rel-proc')[1]
                time['rel-proc'] += cur_problem.get('rel-proc')[2]

                nodes['rel-env'] += cur_problem.get('rel-env')[1]
                time['rel-env'] += cur_problem.get('rel-env')[2]

                nodes['compilation'] += cur_problem.get('compilation')[1]
                time['compilation'] += cur_problem.get('compilation')[2]

                nodes['bfs_design'] += cur_problem.get('bfs_design')[1]
                time['bfs_design'] += cur_problem.get('bfs_design')[2]

                nodes['rel-mod'] += cur_problem.get('rel-mod')[1]
                time['rel-mod'] += cur_problem.get('rel-mod')[2]

                nodes['rel-combined'] += cur_problem.get('rel-combined')[1]
                time['rel-combined'] += cur_problem.get('rel-combined')[2]

                nodes['combined-rel-proc'] += cur_problem.get('combined-rel-proc')[1]
                time['combined-rel-proc'] += cur_problem.get('combined-rel-proc')[2]



                #print("Solved by all")

        if instance_count >0:

            for method in BFD_HEURISTIC_TYPES:
                average_time = time[method]/instance_count
                average_nodes = nodes[method]/instance_count

                print('method:: %s time:: %f nodes:: %f'%(method,average_time,average_nodes))



            #average_time_rel_env  = time['rel-env']/instance_count
            #average_time_rel_proc  = time['rel-proc']/instance_count
            #average_time_compilation  = time['compilation']/instance_count
            #average_time_bfs  = time['bfs_design']/instance_count
            #average_rel_mod  = time['rel-mod']/instance_count
            #print('average_time_rel_env: %f'%average_time_rel_env)
            #print('average_time_rel_proc: %f'%average_time_rel_proc)
            #print('average_time_compilation: %f'%average_time_compilation)
            #print('average_time_bfs: %f'%average_time_bfs)
            #print('average_time_rel_mod: %f'%average_rel_mod)


            #average_nodes_rel_env  = nodes['rel-env']/instance_count
            #average_nodes_rel_proc  = nodes['rel-proc']/instance_count
            #average_nodes_compilation = nodes['compilation']/instance_count
            #average_nodes_bfs = nodes['bfs_design']/instance_count
            #print('average_nodes_rel_env: %f'%average_nodes_rel_env)
            #print('average_nodes_rel_proc: %f'%average_nodes_rel_proc)
            #print('average_nodes_compilation: %f'%average_nodes_compilation)
            #print('average_nodes_bfs: %f'%average_nodes_bfs)



if __name__ == '__main__' :



    for domain in  ['ex-blocksworld','boxworld','blocksworld', 'elevators', 'triangle_tire', 'vacuum']:

        print('\n\n\ndomain: %s \n\n\n'%domain)


        #results_folder_name= '/home/sarah/Dropbox/er-umd-2018/FinalResults/Optimal/exp_results_%s'%(domain)
        #is_optimal = True

        results_folder_name = '/home/sarah/Dropbox/er-umd-2018/FinalResults/Suboptimal/exp_results_%s'%domain
        is_optimal = False

        output_file_name  = '/home/sarah/Documents/GoalRecognitionDesign/Redesign/Code-IJCAI18/umd/results_%s.txt'%(domain)

        results_map = parse_result_file(results_folder_name, output_file_name, domain, is_optimal)
        analyze_dictionary(results_map)
