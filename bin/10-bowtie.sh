function run_bowtie2 {
fq_file=$1
sam_prefix=$2
date=`date +%y%m%d`
log_file="$sam_prefix-$date.txt"

if [ ! -e bowtie2 ]; then mkdir -p bowtie2/results/; mkdir -p bowtie2/logs/; fi
${bowtie2} -x ./mm9/mm9 \
    -U $fq_file -N 1 -p 8 \
    -S bowtie2/results/$sam_prefix.sam \
    2>&1 | tee bowtie2/logs/$log_file

${samtools} view -F 4 -bS <(grep -v "XS:i:" bowtie2/results/$sam_prefix.sam) > bowtie2/results/$sam_prefix.bam 
rm bowtie2/results/$sam_prefix.sam
    
}

