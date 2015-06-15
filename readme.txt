###---------------------------------------------------------------------------------------------------------------------
### bowtie2 + GEM/MACS2 + HOMER	    pipeline for analysing ChIP-exo data.
### 06/15/2015            	    Xing Tang, The Ohio State University Comprehensive Cancer Center
###				    tangx1986@gmail.com
###---------------------------------------------------------------------------------------------------------------------


How to use this package?

1. Put the raw fastq files into the raw data folder

2. Revise samples.conf

3. Install all the required software and R package 
R
Rscript
java
fastqc
bowtie2
samtools
macs2
bedtools
gem
cisgenome
homer (Please install all the tools required by homer and set it up correctly)
weblogo
R packages: ggplot2, reshape2, plyr

4. Set up the path of installed software in software.conf file

5. Finally type “bash run_ChIP-exo_pipeline.sh” to start analysis.
