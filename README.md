# Stacks Workflow

RADseq workflow using [STACKS](http://creskolab.uoregon.edu/stacks/)

Developed by [Eric Normandeau](https://github.com/enormandeau) in
[Louis Bernatchez](http://www.bio.ulaval.ca/louisbernatchez/presentation.htm)'s
laboratory.

This fork is a development repo for moving from stacks v1 to v2, developed by [Ben Sutherland](https://github.com/bensutherland).       

## Important Note 
**WARNING!** This fork is not stable and is in **DEVELOPMENT MODE ONLY**

**Warning!**: this software is provided "as is", without warranty of any kind,
express or implied, including but not limited to the warranties of
merchantability, fitness for a particular purpose and noninfringement. In no
event shall the authors or copyright holders be liable for any claim, damages
or other liability, whether in an action of contract, tort or otherwise,
arising from, out of or in connection with the software or the use or other
dealings in the software.

## Licence

The stacks_workflow is licensed under the gpl3 license. See the licence file
for more details.

# Stacks workflow tutorial

The goal of this workflow is to simplify the use of the STACKS pipeline and to
create a folder architecture and code structure to help people analysing RADseq
data. It was developed with the needs of our research group in mind as well as
with an emphasis on non-model species studies. We make no claim about its
usefulness to other groups or in other contexts, but we still believe it may be
of use to some.

## About STACKS
 
The [stacks analysis pipeline](http://creskolab.uoregon.edu/stacks/) is used
for snp discovery in genotyping by sequencing (gbs) and restriction-site
associated dna sequencing (rad) studies, with and without a reference genome.

Before starting to use STACKS, it is highly suggested to read the two official
STACKS papers:

[catchen, j. m., amores, a., hohenlohe, p. a., cresko, w. a., postlethwait, j.
h., & de koning, d. j. (2011). stacks: building and genotyping loci de novo
from short-read sequences. g3, 1(3), 171–182.
doi:10.1534/g3.111.000240](http://www.g3journal.org/content/1/3/171.full)

[catchen, j. m., hohenlohe, p. a., bassham, s., amores, a., & cresko, w. a.
(2013). stacks: an analysis tool set for population genomics. molecular
ecology, 22(11), 3124–3140.
doi:10.1111/mec.12354](http://onlinelibrary.wiley.com/doi/10.1111/mec.12354/abstract)

Also very useful paper to read before attempting to run stacks:

[mastretta yanes a, arrigo n, alvarez n et al. (2014) rad sequencing,
genotyping error estimation and de novo assembly optimization for population
genetic inference. molecular ecology resources,
n/a–n/a.](http://onlinelibrary.wiley.com/doi/10.1111/1755-0998.12291/abstract;jsessionid=a32722e1462a2a2714ee53a6fd4c7194.f04t04)
 
## Overview of the steps

1. Install stacks_workflow and STACKS with its dependencies
1. Download your raw data files (illumina lanes or ion proton chips)
1. Clean the reads and assess their quality
1. Extract individual data with process_radtags
1. Rename the sample files
1. Align reads to a reference genome and sort
1. Stacks pipeline
1. Filtering the results
1. Further analyses

## Where to find this manual

To read a html version of this file, go to the 
[stacks_workflow project page](https://github.com/enormandeau/stacks_workflow)
on GitHub.

## Installing stacks_workflow
Download and install the most recent version of this workflow.      
For the rest of the project, use the extracted or cloned folder as your working
directory. **All the commands in this manual are launched from that
directory.**

### Download and install [STACKS](http://creskolab.uoregon.edu/stacks/)

#### Install programs
Install the following programs from each source website:      
- Cutadapt
- Stacks (v2)
- FastQC
- bwa <http://bio-bwa.sourceforge.net>

## Prepare your raw datafiles

### Downloading your data 

Download your raw Illumina or Ion Proton data files from your sequencing
service provider.

### Copy your raw files

Put a copy of (or a link to) your raw data files in the `02-raw` folder of
stacks_workflow.

All file names **must** end with **.fastq.gz** for the following scripts to
work.

### Preparing the `lane_info.txt` file

This file will contains the names of the raw data files and is used by
stacks_workflow later.  From the stacks_workflow folder, run:

```bash
./00-scripts/00_prepare_lane_info.sh
```

### Running Cutadapt

We trim our data using Cutadapt **in single-end mode** with the following
command:

```bash
./00-scripts/01_cutadapt.sh numCPUs
```

Where `numCPUs` is the number of CPUs you wish to use in parallel. If you do
not put a number, the script will use only one CPU (for backward
compatibility).

### Scan the cutadapt logs

The cutadapt log files can be found in the `10-log_files` folder. Scan them
to confirm that cutadapt has done an appropriate job.

There may be difference in adapters and filter parameters to use with data
produced by Illumina and Ion Proton sequencers.

## Extract individual data with `process_radtags`

### Prepare a file named `sample_information.csv`

Use the same format found in the `example_sample_information.csv` file in
the `01-info_files` folder. 

Save this file in the `01-info_files` folder and name it exactly
`sample_information.csv`.

The `sample_information.csv` file will be used to extract the samples and
rename the extracted sample files automatically. 

The first column **MUST** contain the **EXACT** name of the data file for the
lane of each sample. 

**Notes:**

- The **columns are separated by tabulations** (even if the extension is .csv)
- The second column contains the barcode sequence of each sample. 
- The third column contains the population name of each sample. 
- The fourth column contains the name of the sample (do not include the
population name or abbreviation in the sample name). 
- Neither the population name nor the sample name should contain underscores `_`
- The fifth column contains a number identifying the populations. 

Columns three and four are treated as text, so they can contain either text or
numbers. Other columns can be present after the fifth one and will be ignored.
However, it is crucial that the five first columns respect the format in the
example file exactly. Be especially careful not to include errors in this file,
for example mixing lower and capital letters in population or sample names
(e.g.: Pop01 and pop01), since these will be treated as two different
populations.

### Launch process_radtags with:

#### One restriction enzyme

```bash
./00-scripts/02_process_radtags.sh <trimLength> <enzyme>
```

Where:  

 - **trimLength** = length to trim all the sequences. This should be the length
   of the Illumina reads minus the length of the longest tag or MID.  
 - **enzyme** = name of enzyme (run `process_radtags`, without options, for a
   list of the supported enzymes)

#### Two restriction enzymes

```bash
./00-scripts/02_process_radtags_2_enzymes.sh <trimLength> <enzyme1> <enzyme2>
```

Where:  

 - **trimLength** = length to trim all the sequences. This should be the length
   of the Illumina reads minus the length of the longest tag or MID.  
 - **enzyme1** = name of the first enzyme (run `process_radtags`, without
   options, for a list of the supported enzymes)
 - **enzyme2** = name of the second enzyme (run `process_radtags`, without
   options, for a list of the supported enzymes)

#### Testing different trim lengths

If you are using Ion Proton data, the effect of the trimLength parameter used
above on the number of usable SNPs you recover at the end may not be trivial.
As a rule of thumb, a trim length of 80bp should produce good results. We
suggest you run tests with a smaller group of samples to determine what length
to trim to. For highly variant species, short loci will be more likely to
contain SNPs and long loci to contain more than one SNP, which is not always
informative. Thus, trimming to shorter lengths may be more interesting for
highly variant species.

### Rename samples

#### Rename and copy the samples

We provide a scripts to rename the extracted samples and move them into the
`04-all_samples` folder. The script behaves differently for samples that are
present only once in the `01-info_files/sample_information.csv` and for those
that are present more than once. If a sample is present only once, a link is
created, thus using no additional disk space. If it is present more than once,
all the copies are concatenated into one file, doubling the amount of disk
space taken by this sample (all the individual files PLUS the combined one).

```bash
./00-scripts/03_rename_samples.sh
```

#### Deleting samples with too few reads

If after splitting your samples you notice that some of have too few reads, you
can remove these from the `04-all_samples` folder. The threshold for the
minimum number of reads will depend on your project, including on the number of
expected cut sites generated by your library preparation protocol.

#### Align reads to a reference genome (optional)



#### Download reference genome to the `01-info_files`

#### Index the reference genome

```bash
bwa index -p genome -a bwtsw ./01-info_files/<genome reference>
mv genome.* 01-info_files
```

###Align samples

```bash
./00-scripts/bwa_commands.sh
```

## STACKS pipeline

### Prepare population info file

```bash
./00-scripts/04_prepare_population_map.sh
```

## Edit script parameters

You will need to go through all the scripts named `stacks_*` in the `00-scripts
folder` and edit the options to suite your needs.

**Warning!** This step is most important. Choosing appropriate parameters for
your study is crucial in order to generate meaninful and optimal results. Read
the STACKS documentation on their website to learn more about the different
options.

## Run the STACKS programs

Only the version with a reference genome has been updated to stacks v2 thus far.     

### Without a reference genome (still uses stacks v1 currently)    

```bash
./00-scripts/stacks_1a_ustacks.sh
./00-scripts/stacks_2_cstacks.sh
./00-scripts/stacks_3_sstacks.sh
./00-scripts/stacks_4_populations.sh
./00-scripts/stacks_5a_rxstacks_likelihoods.sh
```

Visualize the distribution of log likelihoods in
`rxstacks_log_likelihoods.png` and choose a cutoff to use in the next script
(`./00-scripts/stacks_5b_rxstacks.sh`). Then launch:

```bash
./00-scripts/stacks_5b_rxstacks.sh
./00-scripts/stacks_6_cstacks_rx.sh
./00-scripts/stacks_7_sstacks_rx.sh
./00-scripts/stacks_8_populations_rx.sh
```

### With a reference genome

Update the gstacks script below with your own map, currently acts on
`01-info_files/population_map_retained.txt`       

```bash
./00-scripts/bwa_mem_align_reads.sh
./00-scripts/stacks2_1_gstacks.sh
<populations module here>
```

## Filtering the results

`Stacks_workflow` includes a script to filter the VCF file output by STACKS.
To print the short documentation of the filtering script, launch the script
without options.

```bash
./00-scripts/05_filter_vcf.py
```

For the long documentation, use the -h option.

```bash
./00-scripts/05_filter_vcf.py -h
```

The following example shows how to use the script with some of the options.
These parameter values are only for demonstration purpose. Choose your
own values carefully.

```bash
./00-scripts/05_filter_vcf.py \  
   -i 05-stacks/batch_1.vcf \  
   -o filtered.vcf \  
   -c 1 -m 7 -l 10 -I 8 -p 70 --use_percent \
   -a 0.01 -A 0.05 -H 0.5 -f -0.3 -F 0.3 -s 10
```

## Conclusion

### Running into problems

1. Consider joining the [Stacks Google
   group](https://groups.google.com/forum/#!forum/stacks-users)
1. [Biostar](https://www.biostars.org) is a useful bioinformatics forum.
1. [SEQanswers](http://seqanswers.com) is another useful forum for all things
   related to Next Generation Sequencing.
1. Of course, you can always ask [Google](https://www.google.com) for help.
