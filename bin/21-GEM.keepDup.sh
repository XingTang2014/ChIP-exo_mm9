function run_gem_keepDup {
input_prefix=$1
out_dir=GEM/results/$input_prefix
mkdir -p $out_dir

cd $out_dir
${java} -Xmx20G -jar ${gem_dir}/gem.jar \
    --d ${gem_dir}/Read_Distribution_ChIP-exo.txt \
    --g ${gem_dir}/mm9.info --genome ../../../mm9/  --s 2000000000 \
    --expt ../../../bowtie2/results/$input_prefix.bam --f SAM --out $input_prefix \
    --k_min 6 --k_max 13 --smooth 3 --nrf
#--ctrl control.bam
paste <(cut -f 1 ${input_prefix}_GEM_events.txt | sed 's/^/chr/;s/:/\t/') \
	<(cut -f 1 ${input_prefix}_GEM_events.txt | sed 's/:/\t/' | cut -f 2 ) \
	<(cut -f 1 ${input_prefix}_GEM_events.txt ) \
	<(cut -f 6 ${input_prefix}_GEM_events.txt ) | sed '1d' > ${input_prefix}_GEM_events.bed 
cd ../../../
}

#In order to run the motif discovery of GEM algorithm, a genome sequence (UCSC download) is needed. The path to directory containing the genome sequence files (by chromosome, *.fa or *.fasta files, with the prefix "chr") can be specified using option --genome (for example, --genome your_path/mm8/). Note that the chromosome name should match those in the "--g" genome_info file, as well as those in your read alignment file.

