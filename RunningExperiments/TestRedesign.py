__author__ = 'sarah'
import sys, os, time, signal, ntpath

DEFAULT_TIME_LIMIT = 1200
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


def perform_testing(directory):

    problem_folders = get_problem_folders(directory)
    index =0
    for problem_folder in problem_folders:
        problem_folder_name = os.path.join(directory,problem_folder)
        for problem_file_name in os.listdir(problem_folder_name):
            #log_file_name = "output_%s"%(problem_file_name)
            log_file_name = "output_%s"%(problem_folder)
            try:

                print("solving %s"%problem_file_name)

                #set timer (taken from http://stackoverflow.com/questions/366682/how-to-limit-execution-time-of-a-function-call-in-python)
                signal.signal(signal.SIGALRM, signal_handler)
                exec_time_limit = DEFAULT_TIME_LIMIT
                signal.alarm(exec_time_limit)


                # start timer
                ts_start = int(time.time())
                problem_name = problem_file_name.split('-')[0]
                problem_num = problem_name.replace('p','')
                print(problem_num)

                full_problem_file_name = os.path.join(problem_folder_name,problem_file_name)

                command_string ="%s/testppddl.out %s p%s >>%s"%(planner_location,full_problem_file_name,problem_num,log_file_name)
                #command_string ="%s/testppddl.out %s p%s >>%s"%(planner_location,full_problem_file_name,problem_num,log_file_name)
                print(command_string)
                os.system(command_string )
                ts_end = int(time.time())
                exec_time = ts_end - ts_start
                print('\n exec-time: %d\n'%exec_time)

            except TimeoutException as e:
                print('caught Timed out for command %s\n '%command_string)
                print(e)
                f = open('%s'%log_file_name,'a')
                f.write('TIME_OUT\n')
                f.close()


            finally:
                sys.stdout.flush()
                index +=1




def perform_testing_all_heuristics(directory):

    problem_folders = get_problem_folders(directory)
    index =0
    for problem_folder in problem_folders:
        problem_folder_name = os.path.join(directory,problem_folder)
        for problem_file_name in os.listdir(problem_folder_name):
            #log_file_name = "output_%s"%(problem_file_name)
            log_file_name = "output_%s"%(problem_folder)
            try:

                print("\nsolving %s\n"%problem_file_name)

                #set timer (taken from http://stackoverflow.com/questions/366682/how-to-limit-execution-time-of-a-function-call-in-python)
                signal.signal(signal.SIGALRM, signal_handler)
                exec_time_limit = DEFAULT_TIME_LIMIT
                signal.alarm(exec_time_limit)


                # start timer
                ts_start = int(time.time())
                problem_name = problem_file_name.split('-')[0]
                problem_num = problem_name.replace('p','')
                print(problem_num)

                full_problem_file_name = os.path.join(problem_folder_name,problem_file_name)

                #zero
                command_string ="ulimit -t %d ;%s/testppddl-zero.out %s p%s >>%s "%(DEFAULT_TIME_LIMIT,planner_location,full_problem_file_name,problem_num,log_file_name)
                print(command_string)
                os.system(command_string )
                ts_end = int(time.time())
                exec_time = ts_end - ts_start
                print('\n exec-time: %d\n\n'%exec_time)

                #hmin
                command_string ="ulimit -t %d ;%s/testppddl-hmin.out %s p%s >>%s "%(DEFAULT_TIME_LIMIT,planner_location,full_problem_file_name,problem_num,log_file_name)
                print(command_string)
                os.system(command_string )
                ts_end = int(time.time())
                exec_time = ts_end - ts_start
                print('\n exec-time: %d\n\n'%exec_time)

                #hmin-false
                command_string ="ulimit -t %d ;%s/testppddl-hmin-false.out %s p%s >>%s "%(DEFAULT_TIME_LIMIT,planner_location,full_problem_file_name,problem_num,log_file_name)
                print(command_string)
                os.system(command_string )
                ts_end = int(time.time())
                exec_time = ts_end - ts_start
                print('\n exec-time: %d\n\n'%exec_time)


                #forward
                #command_string ="%s/testppddl-forward.out %s p%s >>%s"%(planner_location,full_problem_file_name,problem_num,log_file_name)
                #print(command_string)
                #os.system(command_string )
                #ts_end = int(time.time())
                #exec_time = ts_end - ts_start
                #print('\n exec-time: %d\n'%exec_time)


            except TimeoutException as e:
                print('caught Timed out for command %s\n '%command_string)
                print(e)
                f = open('%s'%log_file_name,'a')
                f.write('TIME_OUT\n')
                f.close()


            finally:
                sys.stdout.flush()
                index +=1


def generate_grid(file_name):

    f = open('%s'%file_name,'a')

    for x in range(1,11):
            f.write('(prox y%s y%s)'%(11-x,10-x))

    f.close()




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


def generate_problems_ex(domains_folder_name, problems_folder_name, destination_folder_name):

    problem_file_names = []
    for domain_file in os.listdir(domains_folder_name):
        print(domain_file)
        if 'all.' not in domain_file:
            continue
        for problem_file in os.listdir(problems_folder_name):

            # create a file that attaches the two files together under the name %s-%s with problem, domain and budget
            problem_name = os.path.splitext(ntpath.basename(problem_file))[0]
            domain_name = os.path.splitext(ntpath.basename(domain_file))[0]

            output_file_name = '%s-%s.pddl'%(problem_name,domain_name)
            problem_destination_directory = os.path.join(destination_folder_name,problem_name)
            #create the directory
            if not os.path.exists(problem_destination_directory):
                os.makedirs(problem_destination_directory)

            # paste both problem and domain into the same file
            with open(os.path.join(problem_destination_directory,output_file_name), 'w') as outfile:

                relaxed_domain_file_name = domain_file.replace('.','-relaxed.')
                #over_domain_file_name = domain_file.replace('.','-over.')
                origimal_domain_file_name = 'domain.pddl'
                with open(os.path.join(domains_folder_name,domain_file)) as infile, open(os.path.join(domains_folder_name,relaxed_domain_file_name)) as infile_relaxed,  open(os.path.join(domains_folder_name,origimal_domain_file_name)) as infile_original:#,open(os.path.join(domains_folder_name,over_domain_file_name)) as infile_over:

                    outfile.write(infile_original.read())
                    outfile.write(infile.read())
                    outfile.write(infile_relaxed.read())
                    #outfile.write(infile_over.read())

                    # paste original formulation
                    with open(os.path.join(problems_folder_name,problem_file)) as infile:
                        for line in infile.readlines():
                            outfile.write(line)

                    # paste problem file with various budgets in original and relaxed form
                    for b in (0,1,2,3):
                        for mode in ('relaxed','design'):#,'over'):
                            with open(os.path.join(problems_folder_name,problem_file)) as infile:
                                for line in infile.readlines():
                                    if 'problem' in line :
                                        if mode == 'relaxed':
                                            line = line.replace(')','_design_%d_relaxed)'%b)
                                        elif mode == 'design':
                                            line = line.replace(')','_design_%d)'%b)
                                        else: #mode == 'over'
                                            line = line.replace(')','_design_%d_over)'%b)

                                    if 'domain' in line :
                                        if mode == 'relaxed':
                                            line = line.replace(')','-design-relaxed)')
                                        elif mode == 'design':
                                            line = line.replace(')','-design)')
                                        else: #mode=='over'
                                            line = line.replace(')','-design-over)')

                                    if 'objects' in line:
                                        if b == 0:
                                            line = line.replace('objects','objects t1 - time\n')
                                        elif b == 1:
                                            line = line.replace('objects','objects t1 t2 - time\n')
                                        elif b == 2:
                                            line = line.replace('objects','objects t1 t2 t3 - time\n')
                                        else:# b==3
                                            line = line.replace('objects','objects t1 t2 t3 t4 - time\n')

                                    elif 'design' in domain_name and 'init' in line:
                                        if b == 0:
                                            line = line.replace('init','init (current-time t1)\n')
                                        elif b == 1:
                                            line = line.replace('init','init (current-time t1)(next t1 t2)\n')
                                        elif b == 2:
                                            line = line.replace('init','init (current-time t1)(next t1 t2)(next t2 t3)\n')
                                        else: #b==3
                                            line = line.replace('init','init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)\n')



                                    outfile.write(line)




            problem_file_names.append(output_file_name)



    return problem_file_names

#if os.path.isdir(directory):
#    for filename in os.listdir(directory):
#        problem_files_list.append(os.path.join(directory,filename))

if __name__ == '__main__' :


    #directory = sys.argv[1]

    problem_files_list = []
    domain_name = 'triangle-tireworld'
    domain_name = 'zenotravel'
    domain_name = 'blocksworld'
    #domain_name = 'triangle-tireworld-no-dead-ends'
    #domain_name = 'vacuum-no-fuel-simple-deterministic'
    #domain_name = 'vacuum-no-fuel'

    #domains_folder= '/home/sarah/Documents/GoalRecognitionDesign/Redesign/Benchmarks/Redesign-Benchmakrs-2008/Current/%s/domains'%domain_name
    #problems_folder = '/home/sarah/Documents/GoalRecognitionDesign/Redesign/Benchmarks/Redesign-Benchmakrs-2008/Current/%s/problems'%domain_name
    #destination_folder = '/home/sarah/Documents/GoalRecognitionDesign/Redesign/Benchmarks/Redesign-Benchmakrs-2008/Current/%s/joint'%domain_name
    #destination_folder = './Redesign-Benchmakrs-2008/Current/%s/joint'%domain_name

    domains_folder = '/home/sarah/Dropbox/GoalRecognitionDesign/GRD-SharedFolder/RedesigningEnvironments/umd-Benchmakrs/er-umd-becnhmarks/%s/domains'%domain_name
    problems_folder = '/home/sarah/Dropbox/GoalRecognitionDesign/GRD-SharedFolder/RedesigningEnvironments/umd-Benchmakrs/er-umd-becnhmarks/%s/problems'%domain_name
    destination_folder = '/home/sarah/Dropbox/GoalRecognitionDesign/GRD-SharedFolder/RedesigningEnvironments/umd-Benchmakrs/er-umd-becnhmarks/%s/joint/'%domain_name


    problem_files_list = generate_problems_ex(domains_folder,problems_folder,destination_folder)



    #perform_testing(destination_folder)
    #destination_folder = "/home/sarah/Documents/GoalRecognitionDesign/Redesign/Benchmarks/Redesign-Benchmakrs-2008/Test/joint"
    #perform_testing_all_heuristics(destination_folder)

    #generate_grid('text.pddl')


