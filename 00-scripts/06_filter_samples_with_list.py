#!/usr/bin/env python3
"""Filtering VCF files output by STACKS1 or STACKS2 to remove samples

Usage:
    <program> input_vcf filtering_type info_file output_vcf

Where:
    input_vcf is the name of the VCF file to filter (can be compressed with gzip, ending in .gz)
    filtering_type is either "wanted" or "unwanted"
    info_file contains wanted or unwanted sample names
    output_vcf is the name of the filtered VCF (can be compressed with gzip, ending in .gz)

Warning:
    The allele frequency values are not recomputed after filtering the samples
"""

# Modules
import gzip
import sys

# Functions
def myopen(_file, mode="rt"):
    if _file.endswith(".gz"):
        return gzip.open(_file, mode=mode)

    else:
        return open(_file, mode=mode)

# Parse user input
try:
    input_vcf = sys.argv[1]
    filtering_type = sys.argv[2]
    info_file = sys.argv[3]
    output_vcf = sys.argv[4]
except:
    print(__doc__)
    sys.exit(1)

if not filtering_type in ["w", "u", "wanted", "unwanted"]:
    print("ERROR: filtering_type must be 'wanted' or 'unwanted'")
    sys.exit(2)

# Get wanted or unwanted samples
listed_samples = set([x.strip() for x in open(info_file).readlines()])

# Filter
with myopen(input_vcf) as infile:
    with myopen(output_vcf, "wt") as outfile:
        for line in infile:
            l = line.strip().split("\t")

            if line.startswith("##"):
                outfile.write(line)
                continue

            if line.startswith("#CHROM"):

                samples = l[9:]
                sample_ids = set()

                for i, s in enumerate(samples):
                    if s in listed_samples:
                        sample_ids.add(i)

                if filtering_type in ["w", "wanted"]:
                    wanted_ids = [x for x in range(len(samples)) if x in sample_ids]

                elif filtering_type in ["u", "unwanted"]:
                    wanted_ids = [x for x in range(len(samples)) if x not in sample_ids]

            infos = l[:9]
            genotypes = l[9:]
            genotypes = [genotypes[i] for i in wanted_ids]
            filtered_line = "\t".join(infos + genotypes) + "\n"
            outfile.write(filtered_line)
