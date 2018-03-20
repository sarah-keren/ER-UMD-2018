__author__ = 'sarah'
import sys, os, time, signal, ntpath


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





def generate_problems(domains_folder_name, problems_folder_name, destination_folder_name):

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


    #domain_name = 'triangle-tireworld'
    #domain_name = 'triangle-tireworld-simplified'
    #domain_name = 'zenotravel'
    #domain_name = 'zenotravel-simplified'
    domain_name = 'blocksworld'
    #domain_name = 'boxworld-simplified'
    #domain_name = 'blocksworld-simplified'
    #domain_name = 'ex-blocksworld-simplified'
    #domain_name = 'elevators-simplified'


    #benchmarks_location = '/home/sarah/Documents/GoalRecognitionDesign/Redesign/Benchmarks/umd-Benchmakrs'#/home/sarah/Dropbox/GoalRecognitionDesign/GRD-SharedFolder/RedesigningEnvironments-improvedSearch
    #benchmarks_location = '/home/sarah/Dropbox/GoalRecognitionDesign/GRD-SharedFolder/RedesigningEnvironments/umd-Benchmakrs/er-umd-becnhmarks'
    benchmarks_location = '/home/sarah/Documents/GoalRecognitionDesign/Redesign/Benchmarks/umd-Benchmakrs-2018/original'


    #for domain_name in ['triangle-tireworld-simplified','blocksworld-simplified','boxworld-simplified','ex-blocksworld-simplified','elevators-simplified']:
    for domain in ['blocksworld']:#['boxworld-1','boxworld-2','boxworld-3']:
        domains_folder= '%s/%s/domains'%(benchmarks_location,domain)
        problems_folder = '%s/%s/problems'%(benchmarks_location,domain)
        destination_folder = '%s/%s/joint'%(benchmarks_location,domain)


        problem_files_list = generate_problems(domains_folder,problems_folder,destination_folder)

