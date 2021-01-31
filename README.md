# divergence-dating

Written using treePL version 1.0

usage: treepl.sh config_file PATH_to_treefile

The treepl.sh script will perform the following:
  (1) prime the analysis and identify suggested optimization parameters
  (2) add code for cross validation and run cross validation to optimize the opt and optad values
  (3) run cross validation several times to identify the lowest chisq value and its associated smoothing value
  (4) identify the smoothing value consistently associated with the lowest chisq value
  (5) use all optimized parameters to date a maximum likelihood tree
