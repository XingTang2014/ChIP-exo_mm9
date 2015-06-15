function run_homer {
prefix=$1
cd $project_dir
if [ ! -d Homer/results/ ]; then mkdir -p Homer/results/; fi

export PATH=$homer_dir:$PATH
export PATH=$weblogo_dir:$PATH
export PERL5LIB=$weblogo_dir:$PERL5LIB

${homer_bin_dir}/makeTagDirectory Homer/results/${prefix}/tagDir bowtie2/results/${prefix}.bam

# Find enriched motifs within peak region
${homer_bin_dir}/findMotifsGenome.pl GEM/results/${prefix}/${prefix}_GEM_events.overlap_MACS2.bed mm9 Homer/results/${prefix}/ -size 100  2>&1 | tee Homer/results/log.txt
mv Homer/results/log.txt Homer/results/${prefix}/log.txt
# Creating Histograms from High-throughput Sequencing data 
${homer_bin_dir}/annotatePeaks.pl GEM/results/${prefix}/${prefix}_GEM_events.overlap_MACS2.bed \
	mm9 -size 500 -hist 1 -d Homer/results/${prefix}/tagDir > Homer/results/${prefix}/tagDistri.details.xls
# Plot the tag distribution and motif distribution
cd Homer/results/${prefix}/
${Rscript} ${project_dir}/bin/Homer_plot.R
cd ${project_dir}

}


