# ONT_OTU_Table
## Description
Workflow for the generation of OTU-tables from demultiplexed ONT amplicon data.
The workflow is split into two parts. 
The first part is exploratory and generates stat-figures using Nanoplot version 1.42. It processes the ".fastq.gz" files by unzipping, moving and concatenating them before generating stat-figures for each sample/barcode.
It is useful for the user, to check in order to keep the true amplicons of interest and filter out artifacts and low-quality reads.
It is recommended for the user to check the generated scatter plots of read length vs average quality of the samples, in order to determine the proper filtering parameteres for the final part of the workflow.
The second part of the workflow filters the reads based upon user-input using chopper version 0.7.
Biologically meaningful reads from each sample/barcode are clustered into OTU's using Vsearch version 2.26.1 and algorithm UNOISE3 (https://doi.org/10.1093/bioinformatics/btv401).
OTU's from all samples/barcodes are concatenated and OTU's from each sample/barcode are polished using all concatenated OTU's and the non-clustered, filtered reads.
Taxonomy is infered to OTU's by Vsearch version 2.26.1, based on 97% and 99% identity using either a curated SINTAX database, such as MiDAS for 16S of microbes found in activated sludge and anaerobic digestors (insert reference) or by searching against a blastn database. This is dependent on user-input. Note that, when using blastn only the best hit will be used to infer taxonomy. Furthermore, when searching a common gene against an unspecific blast database, the query time can be very time consuming and memory-dependent.

## Example Part 1: Statistics for Read Filtering
This section will describe a use-case for the workflow including terminal arguments to achieve the output. 

We have prepared a barcoded library for sequencing using SQK-LSK114 and PCR-barcoding EXP-PBC096.
The output ".fastq.gz" files are now located in a folder called "fastq_pass" under our ONT sequencing run directory.
We want to check the size and quality of our two amplicons, for further filtering.
We use the first part of the workflow as follows:

```
bash ~/pipeline/ONT_OTU_Table_Main.sh -o ~/output_dir_name -i ~/nanopore_data/ONT_RUN_ID/fastq_pass -j 5 -t 10
```
The command will create the specified output folder and create directories beneath where output files will be located.
For ``` 0_stats ``` Figures showing key-statistics, generated by Nanoplot, for each sample/barcode will be located and ``` 1_raw ``` will contain unzipped and concatenated ".fastq" files for each sample/barcode.



<figure id="figref-nanoplot">
  <img src="Example_Figures/Nanoplot - example.png">
  <figcaption>
  <strong>Figure 1:</strong> Example plot of read length vs average quality generated by Nanoplot. This example shows two distinct amplicons. The amplicon ~600bp for a mcrA gene and 1100-1600bp for 16S (V1-V8) 
  </figcaption>
</figure>

For this case, we are interested in producing OTU-tables with taxonomy for both amplicons. Furthermore, we are interested in highest quality of reads, without filtering out the vast majority of the reads. In order to achieve this, we need to filter based on the mcrA amplicon. 


## Example Part 2: OTU-table Generation 


OTU-tables are generated based upon the results from 97% and 99% identity.
An example of an OTU-table generated using MiDAS 16S SINTAX database and 99% identity is illustrated in figxx

Fig xx..


Explanation of OTU-table in fig xx.




