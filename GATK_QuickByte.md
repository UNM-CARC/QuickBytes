# Parallel genomic variant calling with Genome Analysis Toolkit (GATK) #

This QuickByte outlines how to run a pipeline based on Genome Analysis Toolkit v4 (GATK4) best practices, a common pipeline for processing genomic data from Illumina platforms. Major modifications from “true” best practices are done to facilitate using this pipeline for both model and non-model organisms. Additionally, we show how to best parallelize these steps on CARC. Here we outline the steps for a single sample without parallelization, then with parallelization for specific steps, and finally provide an example of a fully parallelized script. Extensive documentation (including other Best Practices pipelines) can be found [here](https://gatk.broadinstitute.org/hc/en-us/sections/360007226651-Best-Practices-Workflows). Specifically, the Best Practices informing this pipeline are the [data pre-processing workflow](https://gatk.broadinstitute.org/hc/en-us/articles/360035535912-Data-pre-processing-for-variant-discovery) and the [germline short variant discovery workflow](https://gatk.broadinstitute.org/hc/en-us/articles/360035535932-Germline-short-variant-discovery-SNPs-Indels-). We aim to give you sample commands to emulate these scripts workflows, which will also allow you to easily modify the pipeline.

The goal of this pipeline is to output Single Nucleotide Polymorphisms (SNPs) and optionally indels for a given dataset. This same pipeline can be used for humans, model organisms, and non-model organisms. Spots that can leverage information from model organisms are noted, but those steps can be bypassed. Because sample size and depth of coverage are often lower in non-model organisms, filtering recommendations and memory requirements will vary. Note that this assumes you are using paired-end data and will differ slightly if you use unpaired.

The basic steps are aligning and processing raw reads into binary alignment map (BAM) files, optionally getting descriptive metrics about the samples’ sequencing and alignment, calling variants to produce genomic variant call format (GVCF) files, genotyping those GVCFs to produce VCFs, and filtering those variants for analysis.

For CARC users, we have provided some test data to run this on from a paper on [the conservation genomics of sagegrouse](https://academic.oup.com/gbe/article/11/7/2023/5499175). It is two sets of gzipped fastq files per species (i.e. eight total, 4 read and 4 read 2), a file with adapter sequences to trim, and a reference genome. They are located at /projects/tutorials/GATK/. Copy them into your space like "cp /projects/tutorials/quickbytes/GATK/* ~/path/to/directory". A .pbs script for running the pipeline (seen below) is also included, but you may learn more by running each step individually. The whole process with the script with 4 nodes on wheeler takes about 5.5 hours.

Please note that you must cite any program you use in a paper. At the end of this, we have provided citations you would include for the programs we ran here.

## Preliminary stuff ##

### Module and directories ###

We will be using conda to make an environment to load within our PBS script. First, if you haven’t already, set up conda as follows:

	module load miniconda3-4.7.12.1-gcc-4.8.5-lmtvtik
	# can also use other conda modules
	conda init bash
	<exit and re-log or restart shell>

This following line will create an environment and install the most recent versions of what we need. We assume you run this before starting up your job.

	conda create -n gatk-env -c bioconda -c conda-forge gatk4 bwa samtools picard trimmomatic

Alternatively, you can load these as modules if you are on Wheeler (Xena only has Samtools now), but they may not be the most recent versions:

	module load bwa-0.7.17-intel-18.0.2-7jvpfu2
	module load samtools-1.9-gcc-7.3.0-tnzvvzt
	module load picard-2.20.8-gcc-4.8.5-3yh2dzv
	module load gatk-4.1.4.1-gcc-4.8.5-python3-fqiavji
	module load trimmomatic-0.36-gcc-4.8.5-q3gx4rj

If you are parallelizing (see “Scatter-gather Parallel” and sample PBS script), you'll need this:

	module load parallel-20170322-gcc-4.8.5-2ycpx7e
	source $(which env_parallel.bash)

The directories we will need (other than the home directory) are a raw_reads directory for the demultiplexed reads and the following for various intermediate files to go into. Alternatively, if you don’t want to move around all your reads, just replace the path in the BWA call with that path. Note that a few of these are only used with scatter-gather parallelization (reccomended for larger datasets).

	mkdir clean_reads
	mkdir alignments
	# next three are only if you get optional metrics
	mkdir alignments/alignment_summary
	mkdir alignments/insert_metrics
	mkdir alignments/depth
	mkdir alignments/dedup_temp
	mkdir bams
	mkdir gvcfs
	mkdir combined_vcfs
	mkdir analysis_vcfs
	# scatter-gather only
	mkdir combined_vcfs/intervals
	mkdir gvcfs/combined_intervals

We will be using a few variables throughout this that we can set now. These are shortcuts for the path to our working directory and reference.

	src=$PBS_O_WORKDIR
	reference=$src/reference

### Sample Names ###

To keep our script short, and outputs easy to understand, we will use consistent sample names for each step, and keep the sample names in a file. We assume this file is named “sample_list”. The file should have one sample name per line. with a single blank line at the end. The one for the tutorial dataset looks like:

	GRSG_JHWY140
	GRSG_JHWY142
	GUSG_GGS1
	GUSG_GGS2
	
We will use this sample list in two ways. The first way is loops, and second is GNU parallel. You can see some examples in the PBS script at the end of the document. Here's a basic demonstration of how to us the list in a loop:

	while read sample; do
		RunTask -input ${sample}
	done < $src/sample_list

And this is what GNU parallel looks like (note it's different for BWA, as we need to specify a specific number of jobs). Remember, we need to use env_parallel if we are using conda.
	
	cat $src/sample_list | env_parallel --sshloginfile $PBS_NODEFILE \
		'RunTask -input {}.file'

For clarity, in most cases the commands are written as they would be for a for loop (i.e. with $sample instead of {}).

### Demultiplexing ###

Because it is not covered by best practices, and is often done by the sequencing center, we will not go into the details of demultiplexing here. We recommend you use Illumina’s software [bcl2fastq](https://support.illumina.com/sequencing/sequencing_software/bcl2fastq-conversion-software.html) if you have the data in .bcl format, and [saber](https://github.com/najoshi/sabre) if it has already been converted to fastq format and it does not have dual combinatorial barcodes. **We'll assume these reads will be in the raw_reads folder with the name SAMPLE_1.fastq.gz (or 2 for read 2).**

## The Pipeline ##

### Trimming Reads ###

Although not a part of GATK's best practices, it is common practice to trim your reads before using them in analyses. We'll use trimmomatic for this. Trimmomatic performs very poorly with its internal thread command, so we'll use GNU parallel to run it in the final script. Note that trimmomatic doesn't have many command line flags, so we'll name variables ahead of time to keep them straight:

	# note this assumes the provided fasta file is in your working directory.
	adapters=$src/TruSeq3-PE.fa

	read1=$src/raw_reads/${sample}_1.fastq.gz
	read2=$src/raw_reads/${sample}_2.fastq.gz
	paired_r1=$src/clean_reads/${sample}_paired_R1.fastq.gz
	paired_r2=$src/clean_reads/${sample}_paired_R2.fastq.gz
	unpaired_r1=$src/clean_reads/${sample}_unpaired_R1.fastq.gz
	unpaired_r2=$src/clean_reads/${sample}_unpaired_R2.fastq.gz
	# the minimum read length accepted, we do the liberal 30bp here
	min_length=30
	trimmomatic PE -threads 1 \
		$read1 $read2 $paired_r1 $unpaired_r1 $paired_r2 $unpaired_r2 \
		ILLUMINACLIP:${adapters}:2:30:10:2:keepBothReads \
		LEADING:3 TRAILING:3 MINLEN:${min_length}
	
If you don't have access to the CARC directory with the adapters file, it can be found in the conda install/spack package. The exact path will vary, but they'll be something like this:
	
	# spack
	adapters=/opt/spack/opt/spack/linux-centos7-x86_64/gcc-4.8.5/trimmomatic-0.36-q3gx4rjeruluf75uhcdfkjoaujqnjhzf/bin/TruSeq3-SE.fa
	# conda
	adapters=~/.conda/pkgs/trimmomatic-0.39-1/share/trimmomatic-0.39-1/adapters/TruSeq3-PE.fa

If you're using the spack module, you call trimmomatic using java:

	java -jar /opt/spack/opt/spack/linux-centos7-x86_64/gcc-4.8.5/trimmomatic-0.36-q3gx4rjeruluf75uhcdfkjoaujqnjhzf/bin/trimmomatic-0.36.jar PE ...

### Alignment and Pre-processing ###

This section prepares BAM files for variant calling. First, we need to index our reference and make a sequence dictionary. We'll index two ways, one for bwa and one for GATK:

	bwa index -p $reference ${reference}.fa
	samtools faidx ${reference}.fa -o ${reference}.fa.fai
	picard CreateSequenceDictionary \
       		R=${reference}.fa \
       		O=${reference}.dict

Then, we need to align demultiplexed reads to a reference. For this step, we will use the Burrough-Wheeler Aligner’s (BWA) mem algorithm. Another common option is [Bowtie](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml). One important flag here is the -R flag, which is the read group and sample ID for a given sample. We assume that these samples are in the same read group. We can get a node's worth of parallelization with the -t command (it can't work across nodes). Therefore, in the sample script at the end we will show you how to further parallelize BWA. The base command looks like this:

	bwa mem \
		-t [# threads] -M \
		-R "@RG\tID:${sample}\tPL:ILLUMINA\tLB:${sample}\tSM:${sample}" \
		$reference \
		$src/clean_reads/${sample}_paired_R1.fastq.gz \
		$src/clean_reads/${sample}_paired_R2.fastq.gz \
		> $src/alignments/${sample}.sam

The next step is to mark PCR duplicates to remove bias, sort the file, and convert it to the smaller BAM format for downstream use. GATK’s new MarkDuplicatesSpark performs all these tasks, but needs a temporary directory to store intermediate files:

	gatk MarkDuplicatesSpark \
		-I $src/alignments/${sample}.sam \
		-M $src/bams/${sample}_dedup_metrics.txt \
		--tmp-dir $src/alignments/dedup_temp \
		-O $src/bams/${sample}_dedup.bam

We recommend combining these steps per sample for efficiency and smoother troubleshooting. One issue is that we do not want large SAM files piling up. This can either be done by piping BWA output directly to MarkDuplicatesSpark or removing the SAM file after each loop. In case you want to save the SAM files, we did the latter (this isn’t a bad idea if you have the space, in case there is a problem with generating BAM files). If you are doing base recalibration, you can also add “rm ${sample}\_debup.bam” to get rid of needless BAM files. Later in the pipeline, we assume you did base recalibration, so will use the {sample}\_recal.bam file. If you did not use base recalibration, use {sample}\_dedup.bam file in its place.

#### Base Quality Score Recalibration (model organisms)

An optional step (and one not taken in the tutorial) is to recalibrate base call scores. This applies machine learning to find where quality scores are over or underestimated based on things like read group and cycle number of a given base. This is recommended, but is rarely possible for non-model organisms, as a file of known polymorphisms is needed. Note, however, that it can take a strongly filtered VCF from the end of the pipeline, before running the entire pipeline again (but [others haven’t found much success with this method](https://evodify.com/gatk-in-non-model-organism/)). Here is how it looks, with the first line indexing the input VCF file if you haven't already.

	gatk IndexFeatureFile -I $src[name-of-known-sites].vcf

	gatk BaseRecalibrator \
		-I $src/bams/${sample}_dedup.bam \
		-R ${reference}.fa \
		--known-sites $src/[name-of-known-sites].vcf \
		-O $src/bams/${sample}_recal_data.table
		
	gatk ApplyBQSR \
		-I $src/bams/${sample}_dedup.bam \
		-R ${reference}.fa \
		--bqsr-recal-file $src/bams/${sample}_recal_data.table \
		-O $src/bams/${sample}_recal.bam

### Collect alignment and summary statistics (optional)

This step is optional, and is not part of GATK’s best practices, but is good to have. It will output important stats for assessing sample quality. Picard’s “CollectAlignmentSummaryMetrics” gives several helpful statistics about the alignment for a given sample. Picard’s “CollectInsertSizeMetrics” gives information about the distribution of insert sizes. Samtools’s “depth” gives information about the read depth of the sample. Note that "depth" has huge output files, so it may be best to skip it until needed.

	picard CollectAlignmentSummaryMetrics \
		R=${reference}.fa \
		I=$src/bams/${sample}_recal.bam \
		O=$src/alignments/alignment_summary/${sample}_alignment_summary.txt
		
	picard CollectInsertSizeMetrics \
		INPUT=$src/bams/${sample}_recal.bam \
		OUTPUT=$src/alignments/insert_metrics/${sample}_insert_size.txt \
		HISTOGRAM_FILE=$src/${sample}_insert_hist.pdf
		
	samtools depth \
		-a $src/bams/${sample}_recal.bam \
		> $src/alignments/depth/${sample}_depth.txt

### Calling variants with HaplotypeCaller

The simplest way is individually going through BAM files and calling SNPs on them using HaplotypeCaller in GVCF mode (“-ERC GVCF” flag), resulting in GVCFs as output.

	gatk HaplotypeCaller \
		-R ${reference}.fa \
		-I $src/bams/${sample}_recal.bam \
		-O $src/gvcfs/${sample}_raw.g.vcf.gz \
		-ERC GVCF

One issue with HaplotypeCaller is that it takes a long time, but is not programmed to be parallelized by default. We can use GNU parallel to solve that problem in two ways. If you have many small inputs and don't want to do scatter-gather parallel, you can run one instance of HaplotypeCaller per core. Note that we restrict the memory such that each job can only max out the core it's on (you'll want to change from 6g based on the machine you're running this on):

	cat $src/sample_list | env_parallel --sshloginfline $PBS_NODEFILE \
		'gatk --java-options "-Xmx6g" HaplotypeCaller \
		-R ${reference}.fa \
		-I $src/bams/{}_recal.bam \
		-O $src/gvcfs/${}_raw.g.vcf.gz \
		-ERC GVCF'

If you are dealing with large files, HaplotypeCaller may take longer than your walltime. The Scatter-gather Parallel section will outline how to fix that by breaking the job (and the next section) into multiple intervals.

### Consolidating and Genotyping ###

This next step has two options, GenomicsDBImport and CombineGVCFs. GATK recommends GenomicsDBImport, as it is more efficient for large datasets, but it performs poorly on references with many contigs. CombineGVCFs can take a while for large datasets, but is easier to use. Overall, it seems that GenomicsDBImport is more suited for model organisms, while CombineGVCFs is more convenient for non-model organisms. Note that GenomicsDBImport must have intervals (generally corresponding to contigs or chromosomes) specified. GenomicsDBImport can take a file specifying GVCFs, but because CombineGVCFs cannot take this input, we just make a list of samples to combine programmatically and plug it in. Here is how we generate that command:

	gvcf_names=""
	while read sample; do
		gvcf_names="${gvcf_names}-V ${src}/gvcfs/${sample}_raw.g.vcf.gz "
	done < $src/sample_list

If you do use GenomicsDBImport, or want to genotype contigs/chromosomes independently, we'll need intervals for it to work with (the same used for scatter-gather parallelization). Also, you'll need to pre-make a temp directory for holding files:

	mkdir gendb_temp
	cut -f 1 ${reference}.fa.fai > $src/intervals.list	

For GenomicsDBImport, you'll need to get rid of the directory you use for the database (here genomic_database) if you already made it:

	gatk GenomicsDBImport \
		${gvcf_names} \
		--genomicsdb-workspace-path $src/genomic_database \
		--tmp-dir $src/gendb_temp \
		-L $src/intervals.list

And an example for CombineGVCFs is:

	gatk CombineGVCFs \
		-R ${reference}.fa \
		${gvcf_names} \
		-O $src/combined_vcfs/combined_gvcf.g.vcf.gz

The next step is to genotype the combined (cohort) GVCF file. Here’s a sample command for GenomicsDBImport:

	gatk GenotypeGVCFs \
		-R ${reference}.fa \
		-V gendb://$src/genomic_database \
		-O $src/combined_vcfs/combined_vcf.vcf.gz
	
And one for CombineGVCFs:

	gatk GenotypeGVCFs \
		-R ${reference}.fa \
		-V $src/combined_vcfs/combined_gvcf.g.vcf.gz \
		-O $src/combined_vcfs/combined_vcf.vcf.gz
		

### Selecting and filtering variants

This first step is optional, but here we separate out indels and SNPs. Note that we don’t use indels down the line, but similar filters can be applied.

	gatk SelectVariants \
		-R ${reference}.fa \
		-V $src/combined_vcfs/combined_vcf.vcf.gz \
		-select-yype SNP \
		-O $src/combined_vcfs/raw_snps.vcf.gz

	gatk SelectVariants \
		-R ${reference}.fa \
		-V $src/combined_vcfs/combined_vcf.vcf.gz \
		-select-type INDEL \
		-O $src/combined_vcfs/raw_indel.vcf.gz

Here are some good sample filters. The “DP_filter” is depth of coverage (you will probably want to change this), “Q_filter” is quality score, “QD_filter” is quality by depth (avoids artificial inflation of calls), and “FS_filter” is a strand bias filter (higher value means higher bias). Note that DP is better for low depth samples, while QD is better for high depth. More info can be found on [GATK’s website](https://gatk.broadinstitute.org/hc/en-us/articles/360035890471-Hard-filtering-germline-short-variants).

	gatk VariantFiltration \
		-R ${reference}.fa \
		-V $src/combined_vcfs/raw_snps.vcf.gz \
		-O $src/analysis_vcfs/filtered_snps.vcf  \
		-filter "DP < 4" --filter-name "DP_filter" \
		-filter "QUAL < 30.0" --filter-name "Q_filter" \
		-filter "QD < 2.0" --filter-name "QD_filter" \
		-filter "FS > 60.0" --filter-name "FS_filter"

This will give us our final VCF! Note that the filtered SNPs are still included, just with a filter tag. You can use something like SelectVariants' "exclude-filtered" flag or [VCFtools’](http://vcftools.sourceforge.net/) “--remove-filtered-all” flag to get rid of them.

### Scatter-gather Parallel

Scatter-gather is the process of breaking a job into intervals (i.e. contigs or scaffolds in a reference) and running HaplotypeCaller, CombineGVCFs, and GenotypeGVCFs on each interval in parallel. Then, at the end, all the invervals are gathered together with GatherGVCFs. This results in a massive speed-up due to the parallelization. This is fully implemented in the sample script below, with each step outlined here. The output of GatherVcfs is the same as what comes from GenotypeGVCFs in the non-parallel version. Here is how we run HaplotypeCaller, note that this is only one sample, see the sample script for running this on all samples:
	
	# make our interval list
	cut -f 1 ${reference}.fa.fai > $src/intervals.list
	
	while read sample; do
		mkdir ${src}/gvcfs/${sample}
		cat $src/intervals.list | env_parallel --sshloginfile $PBS_NODEFILE \
			'gatk --java-options "-Xmx6g" HaplotypeCaller \
			-R ${reference}.fa \
			-I $src/bams/${sample}_recal.bam \
			-O $src/gvcfs/${sample}/${sample}_{}_raw.g.vcf.gz \
			-L {} \
			-ERC GVCF'
	done < $src/sample_list
	
You'll run then run CombineGVCFs. For each interval, you'll make a list of GVCF file paths for each sample you're including (the while loop below).

	cat $src/intervals.list | env_parallel --sshloginfile $PBS_NODEFILE \
		'interval_list=""
		# loop to generate list of sample-specific intervals to combine
		while read sample; do
			interval_list="${interval_list}-V ${src}/gvcfs/${sample}/${sample}_{}_raw.g.vcf.gz "
		done < $src/sample_list
		gatk --java-options "-Xmx6g" CombineGVCFs \
			-R ${reference}.fa \
			${interval_list} \
			-O $src/gvcfs/combined_intervals/{}_raw.g.vcf.gz'
Next, you run GenotypeGVCFs to get VCFs to gather afterwards. No fancy lists needed!

	cat $src/intervals.list | env_parallel --sshloginfile $PBS_NODEFILE \
		'gatk --java-options "-Xmx6g" GenotypeGVCFs \
			-R ${reference}.fa \
			-V $src/gvcfs/combined_intervals/{}_raw.g.vcf.gz \
			-O $src/combined_vcfs/intervals/{}_genotyped.vcf.gz'
			
The final (gather) step uses GatherVcfs, for which we'll make a file containing the paths to all input genotyped VCFs (generated in the while loop). Note the first line initializes a blank file for the gather list. After we make the gathered VCF, we need to index it for future analyses.

	> $src/combined_vcfs/gather_list
	while read interval; do
   		echo ${src}/combined_vcfs/intervals/${interval}_genotyped.vcf.gz >> \
       			$src/combined_vcfs/gather_list
	done < $src/chromosomes.list
	
	gatk GatherVcfs \
    		-I $src/combined_vcfs/gather_list \
    		-O combined_vcfs/combined_vcf.vcf.gz
		
	gatk IndexFeatureFile \
		-I $src/combined_vcfs/raw_snps.vcf.gz

**NOTE THAT THIS FILE STILL NEEDS TO HAVE VARIANTS SELECTED AND FILTERED, SEE "Selecting and filtering variants" ABOVE**

## Sample PBS Script ##

Here is a sample PBS script combining everything we have above, with as much parallelization as possible. One reason to break up steps like we did is for improved checkpointing (without having to write code checking if files are already present). Once you are finished running a block of code, you can just comment it out. Similarly, if you can only get part way through your sample list, you can copy it and remove samples that have already completed a given step.
	
	#!/bin/bash

	#PBS -q default
	#PBS -l nodes=4:ppn=8
	#PBS -l walltime=10:00:00
	#PBS -N gatk_tutorial
	#PBS -m ae
	#PBS -M youremail@school.edu
	
	# the PBS lines are for the default queue, using 4 nodes, and has a conservative 10 hour wall time
	# it is named "gatk_tutorial" and sends an email to "youremail@school.edu" when done

	# load your conda environment
	module load miniconda3-4.7.12.1-gcc-4.8.5-lmtvtik
	source activate gatk-env
	
	src=$PBS_O_WORKDIR
	# this is "sagegrouse_reference" in the tutorial
	reference=${src}/reference
	
	# indexing reference
	bwa index -p $reference ${reference}.fa
	samtools faidx ${reference}.fa -o ${reference}.fa.fai
	picard CreateSequenceDictionary \
       		R=${reference}.fa \
       		O=${reference}.dict
	
	# Trimming section
	adapters=~/.conda/pkgs/trimmomatic-0.39-1/share/trimmomatic-0.39-1/adapters/TruSeq3-PE.fa
	cat $src/sample_list | env_parallel --sshloginfile $PBS_NODEFILE \
		'read1=$src/raw_reads/{}_1.fastq.gz
		read2=$src/raw_reads/{}_2.fastq.gz
		paired_r1=$src/clean_reads/{}_paired_R1.fastq.gz
		paired_r2=$src/clean_reads/{}_paired_R2.fastq.gz
		unpaired_r1=$src/clean_reads/{}_unpaired_R1.fastq.gz
		unpaired_r2=$src/clean_reads/{}_unpaired_R2.fastq.gz
		# the minimum read length accepted, we do the liberal 30bp here
		min_length=30
		trimmomatic PE -threads 1 \
			$read1 $read2 $paired_r1 $unpaired_r1 $paired_r2 $unpaired_r2 \
			ILLUMINACLIP:${adapters}:2:30:10:2:keepBothReads \
			LEADING:3 TRAILING:3 MINLEN:${min_length}'
	
	# Section for alignment and marking duplicates. 
	# Note we parallelize such that BWA uses exactly one node.
	# Then, we have a number of jobs equal to the number of nodes requested.
	# Note that MarkDuplicates doesn't take much time, but only uses one core, so it's a bit inefficient here.

	cat $src/sample_list | env_parallel -j 1 --sshloginfile $PBS_NODEFILE \
		'bwa mem \
			-t 8 -M \
			-R "@RG\tID:{}\tPL:ILLUMINA\tLB:{}\tSM:{}" \
			$reference \
			$src/clean_reads/{}_paired_R1.fastq.gz \
			$src/clean_reads/{}_paired_R2.fastq.gz \
			> $src/alignments/{}.sam
		gatk MarkDuplicatesSpark \
			-I $src/alignments/{}.sam \
			-M $src/bams/{}_dedup_metrics.txt \
			--tmp-dir $src/alignments/dedup_temp \
			-O $src/bams/{}_dedup.bam
		rm $src/alignments/{}.sam'

	# Collecting metrics in parallel
	# Remember to change from _recal to _dedup if you can’t do base recalibration.
	# Also, depth will take A LOT of room up, so you may not want to run it until you know what to do with it.

	cat $src/sample_list | env_parallel --sshloginfile $PBS_NODEFILE \
		'picard CollectAlignmentSummaryMetrics \
			R=${reference}.fa \
			I=$src/bams/{}_dedup.bam \
			O=$src/alignments/alignment_summary/{}_alignment_summary.txt
		picard CollectInsertSizeMetrics \
			INPUT=$src/bams/{}_dedup.bam \
			OUTPUT=$src/alignments/insert_metrics/{}_insert_size.txt \
			HISTOGRAM_FILE=$src/alignments/insert_metrics/{}_insert_hist.pdf
		samtools depth \
			-a $src/bams/{}_dedup.bam \
			> $src/alignments/depth/{}_depth.txt'

	# Scatter-gather HaploType Caller, probably the most likely to need checkpoints.
	# This can take a lot of different forms, this one is best for large files.
	# Go to the HaplotypeCaller section for more info. 
	
	cut -f 1 ${reference}.fa.fai > $src/intervals.list
	
	while read sample; do
		mkdir ${src}/gvcfs/${sample}
		cat $src/intervals.list | env_parallel --sshloginfile $PBS_NODEFILE \
			'gatk --java-options "-Xmx6g" HaplotypeCaller \
			-R ${reference}.fa \
			-I $src/bams/${sample}_dedup.bam \
			-O $src/gvcfs/${sample}/${sample}_{}_raw.g.vcf.gz \
			-L {} \
			-ERC GVCF'
	done < $src/sample_list

	# Run CombineGVCFs per interval, each step combines all samples into one interval-specific GVCF
	cat $src/intervals.list | env_parallel --sshloginfile $PBS_NODEFILE \
		'interval_list=""
		# loop to generate list of sample-specific intervals to combine
		while read sample; do
			interval_list="${interval_list}-V ${src}/gvcfs/${sample}/${sample}_{}_raw.g.vcf.gz "
		done < $src/sample_list
		gatk --java-options "-Xmx6g" CombineGVCFs \
			-R ${reference}.fa \
			${interval_list} \
			-O $src/gvcfs/combined_intervals/{}_raw.g.vcf.gz'
	
	# Run GenotypeGVCFs on each interval GVCF
	cat $src/intervals.list | env_parallel --sshloginfile $PBS_NODEFILE \
		'gatk --java-options "-Xmx6g" GenotypeGVCFs \
			-R ${reference}.fa \
			-V $src/gvcfs/combined_intervals/{}_raw.g.vcf.gz \
			-O $src/combined_vcfs/intervals/{}_genotyped.vcf.gz'
	
	# Make a file with a list of paths for GatherVcfs to use
	> $src/combined_vcfs/gather_list
	while read interval; do
   		echo ${src}/combined_vcfs/intervals/${interval}_genotyped.vcf.gz >> \
       			$src/combined_vcfs/gather_list
	done < $src/intervals.list
	
	# Run GatherVcfs
	gatk GatherVcfs \
    		-I $src/combined_vcfs/gather_list \
    		-O $src/combined_vcfs/combined_vcf.vcf.gz

	# Index the gathered VCF
	gatk IndexFeatureFile \
		-I $src/combined_vcfs/combined_vcf.vcf.gz

	# Select and filter variants
	gatk SelectVariants \
		-R ${reference}.fa \
		-V $src/combined_vcfs/combined_vcf.vcf.gz \
		-select-type SNP \
		-O $src/combined_vcfs/raw_snps.vcf.gz

	gatk SelectVariants \
		-R ${reference}.fa \
		-V $src/combined_vcfs/combined_vcf.vcf.gz \
		-select-type INDEL \
		-O $src/combined_vcfs/raw_indel.vcf.gz

	gatk VariantFiltration \
		-R ${reference}.fa \
		-V $src/combined_vcfs/raw_snps.vcf.gz \
		-O $src/analysis_vcfs/filtered_snps.vcf  \
		-filter "DP < 4" --filter-name "DP_filter" \
		-filter "QUAL < 30.0" --filter-name "Q_filter" \
		-filter "QD < 2.0" --filter-name "QD_filter" \
		-filter "FS > 60.0" --filter-name "FS_filter"

## Troubleshooting ##

If you need help troubleshooting an error, make sure to let us know the size of your dataset (number of individuals and approximate number of reads should suffice, unless coverage varies between individuals), GATK version, node details, and any error messages output.

## Citations ##

Bolger, A. M., Lohse, M., & Usadel, B. (2014). Trimmomatic: a flexible trimmer for Illumina sequence data. Bioinformatics, 30(15), 2114–2120. https://doi.org/10.1093/bioinformatics/btu170

Li, H., & Durbin, R. (2009). Fast and accurate short read alignment with Burrows-Wheeler transform. Bioinformatics, 25(14), 1754–1760. https://doi.org/10.1093/bioinformatics/btp324

Li, H., Handsaker, B., Wysoker, A., Fennell, T., Ruan, J., Homer, N., … Durbin, R. (2009). The Sequence Alignment/Map format and SAMtools. Bioinformatics, 25(16), 2078–2079. https://doi.org/10.1093/bioinformatics/btp352

McKenna, A., Hanna, M., Banks, E., Sivachenko, A., Cibulskis, K., Kernytsky, A., … DePristo, M. A. (2010). The genome analysis toolkit: A MapReduce framework for analyzing next-generation DNA sequencing data. Genome Research, 20(9), 1297–1303. https://doi.org/10.1101/gr.107524.110

Picard toolkit. (2019). Broad Institute, GitHub Repository. https://doi.org/http://broadinstitute.github.io/picard/

Tange, O. (2018). GNU Parallel 2018 [Computer software]. https://doi.org/10.5281/zenodo.1146014.
