__author__ = 'sarah'
import sys, os, time, signal, ntpath

DEFAULT_TIME_LIMIT = 1800
#planner_location = './MDP-LIB-NEW/mdp-lib-master-sarah'
planner_location = '/home/sarah/Documents/GoalRecognitionDesign/grd_non_deterministic/planners/MDP-LIB-NEW/mdp-lib-master-sarah'

#Deal with timeout
class TimeoutException(Exception):
    pass

def signal_handler(signum, frame):
    raise TimeoutException("Timed out exception!")

def get_problem_folders(directory):

    problem_directory_list = os.listdir(directory)
    for problem in problem_directory_list:
        print(problem)

    index = 0
    sorted_problem_directory_list = []
    while index < 20:
        index = index+1
        if 'p%d'%index in problem_directory_list:
            sorted_problem_directory_list.append('p%d'%index)

    print('sorted\n')
    for problem in sorted_problem_directory_list:
        print(problem)


    return sorted_problem_directory_list


def perform_testing_all_heuristics(directory):

    problem_folders = get_problem_folders(directory)
    index = 0
    for problem_folder in problem_folders:
        problem_folder_name = os.path.join(directory,problem_folder)
        for problem_file_name in os.listdir(problem_folder_name):

            log_file_name = "output_%s"%(problem_folder)
            print("\nsolving %s\n"%problem_file_name)
            full_problem_file_name = os.path.join(problem_folder_name,problem_file_name)

            # zero
            try:
                # set timer (taken from http://stackoverflow.com/questions/366682/how-to-limit-execution-time-of-a-function-call-in-python)
                signal.signal(signal.SIGALRM, signal_handler)
                exec_time_limit = DEFAULT_TIME_LIMIT
                signal.alarm(exec_time_limit)


                # start timer
                ts_start = int(time.time())
                problem_name = problem_file_name.split('-')[0]
                problem_num = problem_name.replace('p','')
                print(problem_num)


                # zero
                command_string ="ulimit -t %d ;%s/testppddl-zero.out %s p%s >>%s "%(DEFAULT_TIME_LIMIT,planner_location,full_problem_file_name,problem_num,log_file_name)
                print(command_string)
                os.system(command_string )
                ts_end = int(time.time())
                exec_time = ts_end - ts_start
                print('\n exec-time: %d\n\n'%exec_time)

            except TimeoutException as e:
                print('caught Timed out for command %s\n '%command_string)
                print(e)
                f = open('%s'%log_file_name,'a')
                f.write('TIME_OUT\n')
                f.close()


            finally:
                sys.stdout.flush()

            # hmin
            try:

                # set timer (taken from http://stackoverflow.com/questions/366682/how-to-limit-execution-time-of-a-function-call-in-python)
                signal.signal(signal.SIGALRM, signal_handler)
                exec_time_limit = DEFAULT_TIME_LIMIT
                signal.alarm(exec_time_limit)


                # start timer
                ts_start = int(time.time())
                problem_name = problem_file_name.split('-')[0]
                problem_num = problem_name.replace('p','')
                print(problem_num)

                command_string ="ulimit -t %d ;%s/testppddl-hmin.out %s p%s >>%s "%(DEFAULT_TIME_LIMIT,planner_location,full_problem_file_name,problem_num,log_file_name)
                print(command_string)
                os.system(command_string )
                ts_end = int(time.time())
                exec_time = ts_end - ts_start
                print('\n exec-time: %d\n\n'%exec_time)

            except TimeoutException as e:
                print('caught Timed out for command %s\n '%command_string)
                print(e)
                f = open('%s'%log_file_name,'a')
                f.write('TIME_OUT\n')
                f.close()


            finally:
                sys.stdout.flush()

            # hmin false
            try:

                # set timer (taken from http://stackoverflow.com/questions/366682/how-to-limit-execution-time-of-a-function-call-in-python)
                signal.signal(signal.SIGALRM, signal_handler)
                exec_time_limit = DEFAULT_TIME_LIMIT
                signal.alarm(exec_time_limit)


                # start timer
                ts_start = int(time.time())
                problem_name = problem_file_name.split('-')[0]
                problem_num = problem_name.replace('p','')
                print(problem_num)

                command_string ="ulimit -t %d ;%s/testppddl-hmin-false.out %s p%s >>%s "%(DEFAULT_TIME_LIMIT,planner_location,full_problem_file_name,problem_num,log_file_name)
                print(command_string)
                os.system(command_string )
                ts_end = int(time.time())
                exec_time = ts_end - ts_start
                print('\n exec-time: %d\n\n'%exec_time)

            except TimeoutException as e:
                print('caught Timed out for command %s\n '%command_string)
                print(e)
                f = open('%s'%log_file_name,'a')
                f.write('TIME_OUT\n')
                f.close()


            finally:
                sys.stdout.flush()



            index +=1





def generate_problems(domains_folder_name, problems_folder_name, destination_folder_name):

    problem_file_names = []
    for domain_file in os.listdir(domains_folder_name):
        for problem_file in os.listdir(problems_folder_name):

            #problem_name = problem_file.split('/')[-1]


            # create a file that has the two files together under the name %s-%s with problem and then domain
            problem_name = os.path.splitext(ntpath.basename(problem_file))[0]
            domain_name = os.path.splitext(ntpath.basename(domain_file))[0]

            output_file_name = '%s-%s.pddl'%(problem_name,domain_name)
            problem_destination_directory = os.path.join(destination_folder_name,problem_name)
            #create the directory
            if not os.path.exists(problem_destination_directory):
                os.makedirs(problem_destination_directory)
            with open(os.path.join(problem_destination_directory,output_file_name), 'w') as outfile:

                # paste both problem and domain into the same file
                with open(os.path.join(domains_folder_name,domain_file)) as infile:
                    outfile.write(infile.read() )
                with open(os.path.join(problems_folder_name,problem_file)) as infile:
                    for line in infile.readlines():
                        if 'design' in domain_name and 'objects' in line:
                            if 'all' in domain_name:
                                line = line.replace('objects','objects t1 t2 t3 - time\n')
                            else:
                                line = line.replace('objects','objects t1 t2 - time\n')
                        elif 'design' in domain_name and 'init' in line:
                            if 'all' in domain_name:
                                line = line.replace('init','init (current-time t1)(next t1 t2)(next t2 t3)(initialization)\n')
                            else:
                                line = line.replace('init','init (current-time t1)(next t1 t2)(initialization)\n')

                        outfile.write(line)




            problem_file_names.append(output_file_name)



    return problem_file_names





#if os.path.isdir(directory):
#    for filename in os.listdir(directory):
#        problem_files_list.append(os.path.join(directory,filename))

if __name__ == '__main__' :


    #domain_name = 'triangle-tireworld'
    domain_name = 'triangle-tireworld-simplified'
    #domain_name = 'zenotravel'
    #domain_name = 'zenotravel-simplified'
    #domain_name = 'blocksworld'
    #domain_name = 'boxworld-simplified'
    #domain_name = 'boxworld-simplified-b'
    #domain_name = 'sysAdmin-SLP'
    #domain_name = 'blocksworld-simplified'
    #domain_name = 'rectangle-tireworld'
    #domain_name = 'elevators'
    #domain_name = 'blocksworld-all-8'
    #domain_name = 'boxworld-444-666'



    #domain_name = sys.argv[1]

    domains_folder= '/home/sarah/Documents/GoalRecognitionDesign/Redesign/Benchmarks/Redesign-Benchmakrs-2008/Current/%s/domains'%domain_name
    problems_folder = '/home/sarah/Documents/GoalRecognitionDesign/Redesign/Benchmarks/Redesign-Benchmakrs-2008/Current/%s/problems'%domain_name
    destination_folder = '/home/sarah/Documents/GoalRecognitionDesign/Redesign/Benchmarks/Redesign-Benchmakrs-2008/Current/%s/joint'%domain_name
    #destination_folder = './Redesign-Benchmakrs-2008/Current/%s/joint'%domain_name


    #problem_files_list = generate_problems(domains_folder,problems_folder,destination_folder)
    perform_testing_all_heuristics(destination_folder)
