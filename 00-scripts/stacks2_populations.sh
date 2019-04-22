#!/bin/bash
# Launch populations
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)

# Copy script as it was run
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="10-log_files"
INFO_FILES_FOLDER="01-info_files"
POP_MAP="population_map_retained.txt"

cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"
cp $INFO_FILES_FOLDER/$POP_MAP $LOG_FOLDER/"$TIMESTAMP"_"$POP_MAP"

# IMPORTANT: make sure your read about the available options for 'populations'
# in the STACKS papers

# Comment out the options required to run your analysis

# Current command
populations --in-path 05-stacks --popmap 01-info_files/population_map_retained.txt --out-path 07-filtered_vcfs -r 0.7 --min-populations 15 --min-maf 0.01 --vcf --fstats --smooth --hwe -t 8
