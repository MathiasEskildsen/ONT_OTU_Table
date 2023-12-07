# ONT_OTU_Table
Workflow for the generation of OTU-tables from demultiplexed ONT amplicon data. 

The workflow is split into two parts.
The first part is exploratory and generates stat-figures using Nanoplot version 1.42. It processes the ".fastq.gz" files by unzipping, moving and concatenating them before generating stat-figures for each sample/barcode.
It is recommended for the user to check the generated scatter plots of read length vs average quality of the samples, in order to determine the proper filtering parameteres for the last part of the workflow. 

Example figure from nanoplot below....

Explain the filtering parameters for the case above ...


The second part of the workflow filters the reads based upon user-input using chopper version 0.7.
Biologically meaningful reads from each sample/barcode are clustered into OTU's using Vsearch version 2.26.1 and algorithm UNOISE3 (https://doi.org/10.1093/bioinformatics/btv401).
OTU's from all samples/barcodes are concatenated and OTU's from each sample/barcode are polished using all concatenated OTU's and the non-clustered, filtered reads.
Taxonomy is infered to OTU's by Vsearch version 2.26.1, based on 97% and 99% identity using either a curated SINTAX database, such as MiDAS for 16S of microbes found in activated sludge and anaerobic digestors (insert reference) or by searching against a blastn database, based upon user-input. 

OTU-tables are generated based upon the results from 97% and 99% identity.
An example of an OTU-table generated using MiDAS 16S SINTAX database and 99% identity is illustrated in figxx

Fig xx..


Explanation of OTU-table in fig xx.




