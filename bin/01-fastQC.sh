
if [ ! -d fastQC ]; then mkdir fastQC; fi

function run_factQC {
fastq=$1
sample=$2

mkdir fastQC/${sample}
${fastqc} ${fastq} -o fastQC/${sample}
# _1 _2 represents two mates of the pair-end data
# -o --outdir     Create all output files in the specified output directory.
#                 Please note that this directory must exist as the program
#                 will not create it.  

}

