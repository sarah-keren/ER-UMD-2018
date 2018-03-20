__author__ = 'sarah'
import sys, os, time, signal, ntpath

MAX_BUDGET = 6

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
    while index < 21:
        index = index+1
        if 'p%d'%index in problem_directory_list:
            sorted_problem_directory_list.append('p%d'%index)

    print('sorted\n')
    for problem in sorted_problem_directory_list:
        print(problem)


    return sorted_problem_directory_list





def generate_problems(domains_folder_name, problems_folder_name, destination_folder_name):

    problem_file_names = []
    for domain_file in os.listdir(domains_folder_name):
        print(domain_file)
        if 'all.' not in domain_file:
            continue
        for problem_file in os.listdir(problems_folder_name):

            # ignore hidden files
            if '~' in problem_file:
                continue

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
                over_domain_file_name = domain_file.replace('.','-over.')
                over_relaxed_domain_file_name = domain_file.replace('.','-over-relaxed.')
                original_domain_file_name = 'domain.pddl'

                with open(os.path.join(domains_folder_name,domain_file)) as infile,\
                        open(os.path.join(domains_folder_name,relaxed_domain_file_name)) as infile_relaxed,\
                        open(os.path.join(domains_folder_name,original_domain_file_name)) as infile_original,\
                        open(os.path.join(domains_folder_name,over_domain_file_name)) as infile_over,\
                        open(os.path.join(domains_folder_name,over_relaxed_domain_file_name)) as infile_over_relaxed:


                    outfile.write(infile.read())
                    outfile.flush()
                    outfile.write(infile_original.read())
                    outfile.flush()
                    outfile.write(infile_relaxed.read())
                    outfile.flush()
                    outfile.write(infile_over.read())
                    outfile.flush()
                    outfile.write(infile_over_relaxed.read())
                    outfile.flush()


                    # include original problem
                    with open(os.path.join(problems_folder_name,problem_file)) as infile:
                        for line in infile.readlines():
                            outfile.write(line)
                            outfile.flush()

                    # paste problem file with various budgets in original and relaxed form
                    for b in range(MAX_BUDGET+1):
                        for mode in ('design','design-relaxed','design-over','design-over-relaxed'):
                            with open(os.path.join(problems_folder_name,problem_file)) as infile:
                                for line in infile.readlines():
                                    if 'problem' in line :
                                        line = line.replace(')','-%d-%s)'%(b,mode))
                                    if 'domain' in line :
                                        line = line.replace(')','-%s)'%mode)
                                    #if '(:goal (' in line :
                                    #    line = line.replace('(:goal (','(:goal (and (current-time t%d)('% (b+1))
                                    #if ' (:goal-reward' in line :
                                    #    line = line.replace(' (:goal-reward',')(:goal-reward')
                                    if 'objects' in line:
                                        if b == 0:
                                            line = line.replace('objects','objects t1 - time\n')
                                        elif b == 1:
                                            line = line.replace('objects','objects t1 t2 - time\n')
                                        elif b == 2:
                                            line = line.replace('objects','objects t1 t2 t3 - time\n')
                                        elif b == 3:
                                            line = line.replace('objects','objects t1 t2 t3 t4 - time\n')
                                        elif b == 4:
                                            line = line.replace('objects','objects t1 t2 t3 t4 t5 - time\n')
                                        elif b == 5:
                                            line = line.replace('objects','objects t1 t2 t3 t4 t5 t6 - time\n')
                                        elif b == 6:
                                            line = line.replace('objects','objects t1 t2 t3 t4 t5 t6 t7 - time\n')
                                        else: #b == 7:
                                            line = line.replace('objects','objects t1 t2 t3 t4 t5 t6 t7 t8 - time\n')


                                    elif 'design' in domain_name and 'init' in line:
                                        if b == 0:
                                            line = line.replace('init','init (current-time t1)\n')
                                        elif b == 1:
                                            line = line.replace('init','init (current-time t1)(next t1 t2)\n')
                                        elif b == 2:
                                            line = line.replace('init','init (current-time t1)(next t1 t2)(next t2 t3)\n')
                                        elif b== 3:
                                            line = line.replace('init','init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)\n')
                                        elif b== 4:
                                            line = line.replace('init','init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)\n')
                                        elif b== 5:
                                            line = line.replace('init','init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)\n')
                                        elif b== 6:
                                            line = line.replace('init','init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)(next t6 t7)\n')
                                        else: #b=7
                                            line = line.replace('init','init (current-time t1)(next t1 t2)(next t2 t3)(next t3 t4)(next t4 t5)(next t5 t6)(next t6 t7)(next t7 t8)\n')




                                    outfile.write(line)
                                    outfile.flush()




            problem_file_names.append(output_file_name)



    return problem_file_names





#if os.path.isdir(directory):
#    for filename in os.listdir(directory):
#        problem_files_list.append(os.path.join(directory,filename))

if __name__ == '__main__' :

    domain_names = []
    domain_names.append('vacuum-no-fuel-test')
    #domain_names.append('vacuum-no-fuel')
    #domain_names.append('triangle-tireworld')
    domain_names.append('triangle-tireworld-test')
    #domain_names.append('ex-blocksworld')
    #domain_names.append('boxworld')
    #domain_names.append('blocksworld')
    #domain_names.append('elevators')









    benchmarks_location = '/home/sarah/Documents/GoalRecognitionDesign/Redesign/Code-IJCAI18/ER-UMD/umd-Benchmakrs-2018'


    for domain_name in domain_names:
        domains_folder= '%s/%s/domains'%(benchmarks_location,domain_name)
        problems_folder = '%s/%s/problems'%(benchmarks_location,domain_name)
        destination_folder = '%s/%s/joint'%(benchmarks_location,domain_name)

        simplified_problems_folder = '%s/%s/simplified_problems'%(benchmarks_location,domain_name)
        simplified_destination_folder = '%s/%s/simplified_joint'%(benchmarks_location,domain_name)



        problem_files_list = generate_problems(domains_folder,problems_folder,destination_folder)
        simplified_problems_list = generate_problems(domains_folder,simplified_problems_folder,simplified_destination_folder)

