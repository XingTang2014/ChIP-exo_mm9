function run_intersect_GEM_MACS2 {
i=$1

${bedtools} window -w 1000 -u -a GEM/results/${i}/${i}_GEM_events.bed -b MACS2/results/${i}/${i}_summits.bed > GEM/results/${i}/${i}_GEM_events.overlap_MACS2.bed 
}

#-u	Write the original A entry _once_ if _any_ overlaps found in B.

                                              
