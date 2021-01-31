#!/bin/bash

#this block asks the user to input the name of the original configuration file and the PATH to MLTREE and BSREP
[ -n "$1" ] && CONFIG=$1 || { echo -n "Enter configuration file: "; read CONFIG; }
[ -n "$2" ] && MLTREE=$2 || { echo -n "Enter PATH to ML tree file: "; read MLTREE; }
#[ -n "$3" ] && BSREP=$3 || { echo -n "Enter PATH TO BSREP file: "; read BSREP; }

#this block will comment out your bootstrap replicate file for later use
#sed "s|treefile = ${BSREP}|#&|" ${CONFIG} > config_ml
cp $CONFIG config_ml #comment out once you have bootstrap trees

#this block will prime your run in treepl
treePL config_ml > log-file.out 2>&1

cp config_ml config_prime #make a copy of the configuration file for our edits based on the priming step

#edit config_prime file to contain best optimization parameters
echo "#best optimization parameters" >> config_prime
awk '$0 == "PLACE THE LINES BELOW IN THE CONFIGURATION FILE" {i=1;next};i && i++ <= 6' log-file.out >> config_prime #adds the prime results to the configuration file
sed 's/^prime/#&/' config_prime > config_cv #comment out prime, we don't need it anymore,  and make a new config file for the next step

#add code for cross validation, values are very broad but may need to change if the lowest chisq value in the cv.out file corresponds to the ncvstop value
printf "#cross validation analysis \nrandomcv \ncviter = 5 \ncvsimaniter = 1000000000 \ncvstart = 10000000 \ncvstop = 0.00000000001 \ncvmultstep = 0.1 \ncvoutfile = cv.out0 " >> config_cv

treePL config_cv > log-file-cv.out 2>&1
cp log-file-cv.out log-file-cv_0.out

#this block of code is used to optimize the optad and opt values obtained from the priming step
#it optimizes the optad and opt values by reading the previous log file and searching for the "might want to try.." message
END=10 #number of times it will loop, you can increase this integer if optad and opt values are not optimized
for x in $(seq 0 $END);
do
	y=$(expr "$x" + 1);
		if cat log-file-cv_$x.out | grep -q "might want to try a different optad=VALUE"; #if it prints this message, add 1 to optad and test again
			then
				sed -r -i 's/optad = ([0-9]+)/echo "optad = $((\1+1))"/ge' config_cv;
				treePL config_cv > log-file-cv_$y.out 2>&1;
		fi

		if cat log-file-cv_$x.out | grep -q "might want to try a different opt=VALUE"; #if it prints this message, add 1 to opt and test again
			then
				sed -r -i 's/opt = ([0-9]+)/echo "opt = $((\1+1))"/ge' config_cv;
				treePL config_cv >> log-file-cv_$y.out 2>&1;
		fi
done

#this block of code is used to run cross validation several times to identify the lowest chisq value and its associated smoothing value
for x in $(seq 1 10);
do
	sed -r -i 's/cvoutfile = cv.out([0-9]+)/echo "cvoutfile = cv.out$((\1+1))"/ge' config_cv;
	treePL config_cv > log-file-cv-iter_$x.out;
	sort -k3 -g cv.out$x | head -1	>> cv-iter-lowest;
done

cp config_cv config_smooth #make a copy of configuration file for us to edit to add the smooth parameter
#after running cross validation several times, identify the smoothing value consistently associated with the lowest chisq value
sort cv-iter-lowest | uniq -c | sort -rn | head -n 1 | awk '{print $2}' | tr -d '()' | perl -ne 'printf "%d\n", $_;' | xargs -I % sh -c 'echo smooth = %' >> config_smooth
printf "#outputfile of dating step  \noutfile = treepl_dated.tre" >> config_smooth

#this block will date the bootstrap replicates using optimized optad, opt, smooth parameters
#need to comment out cross validation block from config_smooth
sed -r -i 's/^randomcv/#&/' config_smooth
sed -r -i 's/^cviter/#&/' config_smooth
sed -r -i 's/^cvsimaniter/#&/' config_smooth
sed -r -i 's/^cvstart/#&/' config_smooth
sed -r -i 's/^cvstop/#&/' config_smooth
sed -r -i 's/^cvmultstep/#&/' config_smooth
sed -r -i 's/^cvoutfile/#&/' config_smooth

#run treepl on your bootstrap replicate trees
#comment out ml treefile and use the bsrep treefile
#sed "s|treefile = ${MLTREE}|#&|" config_smooth > config_bs
#sed -i "s|#treefile = ${BSREP}|treefile = ${BSREP}|" config_bs
treePL config_bs > log-file-final.out 2>&1

#cleanup working directory after
mkdir -p logfiles_optimize_cv logfiles_optimize_smooth cv_iter_results
mv log-file-cv_* logfiles_optimize_cv
mv log-file-cv-iter_* logfiles_optimize_smooth
mv cv.out* cv_iter_results

echo "treepl run completed, next steps are to summarize all dated BS replicates into consensus tree using a program such as TreeAnnotator"
