# ONT_OTU_Table
This repository is deprecated. It has been migrated to a snakemake workflow, this can be found [here](https://github.com/MathiasEskildsen/ONT-AmpSeq). 

## Description
Workflow for the generation of OTU-tables from demultiplexed ONT amplicon data.
The workflow is split into two parts. 
The first part is exploratory and generates stat-figures using [Nanoplot](https://github.com/wdecoster/NanoPlot) version 1.42. It processes the ``` ".fastq.gz" ``` files by unzipping, moving and concatenating them before generating stat-figures for each sample/barcode.
It is recommended for the user to check the generated scatter plots of read length vs average quality of the samples, in order to determine the proper filtering parameteres for the last part of the workflow.
The second part of the workflow filters the reads based upon user-input using [chopper](https://github.com/wdecoster/chopper) version 0.7.
Biologically meaningful reads from each sample/barcode are clustered into OTU's using [Vsearch](https://github.com/torognes/vsearch) version 2.26.1 and algorithm [UNOISE3](https://doi.org/10.1093/bioinformatics/btv401).
OTU's from all samples/barcodes are concatenated and OTU's from each sample/barcode are polished using [Medaka](https://github.com/nanoporetech/medaka) version 1.11.1.
Taxonomy is infered to OTU's by Vsearch version 2.26.1, based on 97% and 99% identity using either a curated SINTAX database, such as MiDAS 5.1 for 16S of microbes found in activated sludge and anaerobic digestors (https://doi.org/10.1101/2023.08.24.554448) or by searching against a blastn database, using [blast](https://blast.ncbi.nlm.nih.gov/doc/blast-help/) version 2.15.0. This is dependent on user-input. Note, when using blastn only the best hit will be used to infer taxonomy. Furthermore, when searching a common gene against an unspecific blast database, the query time can be very time and memory-consuming.

## Installation 

## Usage
The workflow works on ``` ".fastq.gz" ``` files produced by ONT sequencing devices.
Terminal commands for the statistics workflow:
``` 
ONT_OTU_Table_Stats: NanoPlot statistics of individual samples/barcodes
    -h Show this help message.
    -o Path where directories should be created and files should be stored
    -i Full path to .fastq.gz files from Nanopore, example: /Full/Path/to/nanopore_data/ONT_RUN_ID/fastq_pass  
    -j Number of parallel jobs [default = 1]
    -t Number of threads [default = 1]
```
Example command:
   
``` 
ONT_OTU_Table_Stats.sh -o /my/directory/for/OTUtable -i /Full/Path/to/nanopore_data/ONT_RUN_ID/fastq_pass -j 1 -t 1
```
   
The example command will unzip input files in ``` /Full/Path/to/nanopore_data/ONT_RUN_ID/fastq_pass ``` move them to ``` /my/directory/for/OTUtable/1_raw ``` keeping the original files in their respective directory. Then it will create individual sub-directories, for each sample/barcode in ``` /my/directory/for/OTUtable/0_stats ``` where statistics will be stored.

Terminal commands for the generation of OTU-tables:
``` 
ONT_OTU_Table_Main: Workflow for generation of OTU tables from SINTAX or blastn databases.
    -h Show this help message.
    -i Directory path of unzipped raw ".fastq" files, from statistics workflow, /my/directory/for/OTUtable/1_raw
    -o Path where directories and files should be stored
    -t Number of threads [default = 10] Maximum number of threads
    -j Number of parallel jobs [default = 1]
    -l Minimum length of reads (Check size distribution from statistics)
    -u Maximum length of reads (Check size distribution from statistics)
    -q Minimum q-score of reads (Check quality distribution of reads)
    -m ONT Device and basecalling model [default = r1041_e82_400bps_sup_v4.2.0]
    -M List available models for medaka polishing.
    -r Method for taxonomic classification, SINTAX or blastn.
    -d Full path to database for taxonomic classication, examples: /space/databases/midas/MiDAS4.8.1_20210702/output/FLASVs_w_sintax.fa or /space/databases/blast/nt_2022_07_28/nt
```
Example command:
```
ONT_OTU_Table_stats.sh -i /my/directory/for/OTUtable/1_raw -o /my/directory/for/OTUtable -t 10 -j 1 -l 1100 -u 1600  -q 20 -m r1041_e82_400bps_sup_v4.2.0 -r SINTAX -d /full/path/to/database/MiDAS_w_sintax.fa  
```
The example command will filter the reads from each sample/barcode based upon parameters ``` -l -u -q ```. It will create 97% and 99% clustered OTU-tables based upon SINTAX database found in ``` /full/path/to/database/MiDAS_w_sintax.fa ```. The OTU tables are saved in ``` /my/directory/for/OTUtable/8_OTUtable/97 ``` and ``` /my/directory/for/OTUtable/8_OTUtable/99 ``` respectively. The produced OTU-tables are ready to be loaded into [Ampvis2](https://kasperskytte.github.io/ampvis2/index.html) which is a great R-package that can be utilized to visualize your data. 


## Example Case
### Generating Statistics
This section will describe a use-case for the workflow including terminal commands to achieve the output. 

We have prepared a barcoded library for sequencing using SQK-LSK114 and PCR-barcoding EXP-PBC096. The library has been prepared from samples stemming from anaerobic digestors, with two diffrent amplicons from each sample/barcode.
The output ".fastq.gz" files are now located in a folder called "fastq_pass" under our ONT sequencing run directory.
We want to check the size and quality of our two amplicons, for further filtering.
We use the first part of the workflow as follows:

```
~/pipeline/ONT_OTU_Table_Stats.sh -o ~/output_dir_name -i ~/nanopore_data/ONT_RUN_ID/fastq_pass -j 5 -t 10
```
The command will create a user-specified output folder and create directories beneath where output files will be located.
In the sub-directory ``` 0_stats ``` figures showing key-statistics, for each sample/barcode will be located. The sub-directory ``` 1_raw ``` will contain unzipped and concatenated ".fastq" files for each sample/barcode.

Figure 1 shows an example of the read length vs average read quality for one of the samples in this case.
<figure id="figref-nanoplot">
  <img src="Example_Figures/Nanoplot - example.png">
  <figcaption>
  <strong>Figure 1:</strong> Example plot of read length vs average quality generated by Nanoplot. This example shows two distinct amplicons. The amplicon ~600bp for a mcrA gene and 1100-1600bp for 16S (V1-V8) 
  </figcaption>
</figure>


### Generating OTU-table
For this case, we are interested in producing OTU-tables with taxonomy for both amplicons. Furthermore, we are interested in highest quality of reads, without filtering out the vast majority of the reads. In order to achieve this, we need to filter and create OTU-tables for each amplicon of interest.

For the V1-V8 amplicon, we had a curated 16S SINTAX database, from waste-water treatment plants (insert MiDAS reference), so the following terminal command was used:

```
~/pipeline/ONT_OTU_Table_Main.sh -o ~/output_dir_name -t 10 -j 5 -l 1100 -u 1600 -q 18 -m r1041_e82_400bps_hac_v4.2.0 -r SINTAX -d ~/path/to/database/MiDAS_w_sintax.fa
```

For the mcrA amplicon, we did not have a curated SINTAX database at our disposal, therefore a blastn search was used:

```
bash ~/pipeline/ONT_OTU_Table_Main.sh -o ~/output_dir_name -t 10 -j 5 -l 400 -u 600 -q 18 -m r1041_e82_400bps_hac_v4.2.0 -r blastn -d ~/path/to/database/blast/nt_2022_07_28/nt
```


OTU-tables are generated based upon the results from 97% and 99% identity.
An example of an OTU-table generated using MiDAS 16S SINTAX database and 99% identity is illustrated in figxx

Fig xx..


Explanation of OTU-table in fig xx.




