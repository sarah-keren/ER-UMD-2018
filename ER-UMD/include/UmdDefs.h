#ifndef UMDDEFS_H_INCLUDED

#define UMDDEFS_H_INCLUDED

namespace umddefs
{

  // for parsing purposes
  const std::string deliminator = "~";

  // the predicate indicating the state belongs to the execution stage (and not design)
  const std::string execution_stage_string ("(execution)");

  const std::string design_stage_string ("design");
  const std::string design_start_execution ("design-start-execution");
  const std::string idle_string ("idle");

  // indicating the type of problems
  const std::string relaxed_string ("-relaxed"); // RELAXED ENVIRONMENT
  const std::string relaxed_modification_string ("-over"); // RELAXED MODIFICATION
  const std::string relaxed_combined_string ("-over-relaxed"); // COMBINING THE TWO ABOVE
  const std::string relaxed_process_string ("-relproc"); // RELAXED PROCESS



  // heuristics
  const std::string relaxed_environment ("rel-env");
  const std::string relaxed_modification ("rel-mod");
  const std::string relaxed_combined ("rel-combined");
  const std::string relaxed_design_process ("rel-proc");
  const std::string relaxed_combined_design_process ("rel-combined-proc");
  const std::string relaxed_solution_method ("rel-sol");
  const std::string compilation("compilation"); // no heuristic for design (one heuristic is used for the entire mdp)
  const std::string bfs_design("bfs_design"); // zero heuristic for design, regular heuristic for execution
  const std::string original("original"); // zero heuristic for design, regular heuristic for execution



  // the general huuristics used
  const std::string zeroHeuristic ("zero-heur");
  const std::string baodHeuristic ("BAOD-heur");
  const std::string hminminHeuristic ("hmin-heur");


  // Solution algorithms
  const std::string solverLAO ("LAO*");
  const std::string solverLRTDP ("LRTDP");
  const std::string solverFFLAO ("FFLAO*");
  const std::string solverFLARES ("FLARES");
  const int lrtdp_trials = 5000 ;
  const double lrtdp_epsilon = 0.0001 ;
  const int flares_sims = 100 ;




   //dominating heuristics per domain
   const std::string first_param_relation = "first_param";
   const std::string first_prefix_param_relation = "first_prefix_param";
   const std::string all_param_relation = "all_param";
   const std::string domain_name_triangletire = "triangle-tire";
   const std::string domain_name_vacuum = "vacuum";
   const std::string domain_name_elevators = "elevators";
   const std::string domain_name_boxworld = "boxworld";
   //const std::string domain_name_ex_blocksworld = "ex-blocksworld";
   const std::string domain_name_ex_blocksworld = "exploding-blocksworld";
   const std::string domain_name_blocksworld = "blocks-domain";

   const int ITERATION_LIMIT = 10;

   const std::string TIP = "-tip";




}

#endif // UMDDEFS_H_INCLUDED
