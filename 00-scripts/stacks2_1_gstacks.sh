#!/bin/bash
# Launch gstacks to build loci from aligned data 
# The input BAM file(s) must be sorted by coordinate

# Global variables 
NCPU=$1

# User defined variables
map="01-info_files/population_map_retained.txt"

# Test if user specified a number of CPUs
if [[ -z "$NCPU" ]]
then
    NCPU=1
fi

# Copy script as it was run
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="10-log_files"

cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"


## Options (comment out any options you do not want to use)


# General options:
# Note: use either -I/-M (input folder & map) or -B (input file by name)
# Note: currently works using input file
I="-I 04-all_samples" # input directory
M="-M $map"       # path to a population map giving the list of samples
O="-O 05-stacks" # output directory
t="-t $NCPU"      # number of threads to use (default: 1)

# Model options:
model="--model marukilow"         # model to use to call variants and genotypes; one of marukilow (default), marukihigh, or snp
var_alpha="--var-alpha 0.01"      # alpha threshold for discovering SNPs (default: 0.01 for marukilow)
gt_alpha="--gt-alpha 0.05"        # alpha threshold for calling genotypes (default: 0.05)

# Advanced options (Ref-based mode):
min_mapq="--min-mapq 10"          # minimum PHRED-scaled mapping quality to consider a read (default: 10)
max_clipped="--max-clipped 0.20"  # maximum soft-clipping level, in fraction of read length (default: 0.20)
max_insert_len="--max-insert-len 1000" # maximum allowed sequencing insert length (default: 1000)
details="--details"               # write a heavier output
phasing_coocurrences_thr_range="--phasing-cooccurrences-thr-range 1,2" # range of edge coverage thresholds to iterate over when building the graph of allele cooccurrences for SNP phasing (default: 1,2)
#phasing_dont_prune_hets="--phasing-dont-prune-hets" # don't try to ignore dubious heterozygote genotypes during phasing

# Launch gstacks for all the individuals
echo "Starting gstacks with $NCPU cores"    
gstacks $I $M $O $t \
        $model $var_alpha $gt_alpha \
        $min_mapq $max_clipped $max_insert_len \
        $details $phasing_coocurrences_thr_range $phasing_dont_prune_hets \
            2>&1 | tee 10-log_files/"$TIMESTAMP"_stacks2_gstacks.log
