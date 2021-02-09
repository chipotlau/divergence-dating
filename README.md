# divergence-dating

## Written using treePL version 1.0, script works on Linux systems | see *config* for example CONFIG_FILE 
* treepl_ml.sh (usage: treepl.sh <CONFIG_FILE>)
* treepl_bs.sh (usage: treepl_bs.sh <CONFIG_FILE> <PATH_TO_MAXLIKELIHOOD TREE> <PATH_TO_BOOTSTRAP_REPLICATES>)

#### The treepl_ml.sh script will perform the following:

1. prime the analysis and identify suggested optimization parameters
  
2. add code for cross validation and run cross validation to optimize the opt and optad values
  
3. run cross validation several times to identify the lowest chisq value and its associated smoothing value
  
4. identify the smoothing value consistently associated with the lowest chisq value
  
5. use all optimized parameters to date a maximum likelihood tree

#### The treepl_bs.sh script will perform the same as above, but using bootstrap replicate trees (generated using a fixed topology)
  
- Next steps are to summarize all dated BS replicates into a consensus tree using a program such as TreeAnnotator


***Results will be written to "treepl_dated.tre" file***
