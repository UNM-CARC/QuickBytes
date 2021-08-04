# Pairwise Sequentially Markovian Coalescent

The [pairwise sequentially Markovian coalescent model](https://www.nature.com/articles/nature10231) is a popular method of leveraging single high-quality diploid genomes to infer the demographic history of a lineage over thousands to hundreds of thousands of years. It can be a great exploratory tool for genomic data, and can help you understand and generate biogeographic and evolutionary hypotheses. It leverages heterozygosity information to estimate local times of most recent common ancestor across the genome, which is then used to reconstruct demographic "stairway plots".

It is implemented [by the authors of the original paper on GitHub](https://github.com/lh3/psmc), but the documentation is difficult to understand and the method of calling variants is a bit outdated. Here I'll outline a simple pipeline for generating a consensus sequence using [high coverage (>18x) reads and sites with a depth of at least 10 reads](https://onlinelibrary.wiley.com/doi/10.1111/mec.13540) and a reference genome. Then, I'll go over how to run PSMC and perform bootstrapping. Note that nothing but the bootstrapping can work across different nodes, so if you find bootstrapping takes too long you can run it as a seperate job with more nodes.


## Installation and setup

Due to the inavailibility of PSMC on conda, high number of included utilities, and ease of installing locally, we suggest you install PSMC as shown below. You can install it anywhere, but we'll assume it's in the working directory you're using to run everything:

	git clone https://github.com/lh3/psmc.git
	cd psmc
	make
	cd utils
	make
	cd ../..

Then we'll install some dependencies with conda as below.

	conda create -n psmc-env -c bioconda -c conda-forge picard bcftools samtools bwa

At the top of any scripts used for this, change to your working directory and activate the environment like:

	cd $SLURM_SUBMIT_DIR
	# if using PBS, 'cd $PBS_O_WORKDIR'
	module load miniconda3/4.8.2-pilj
	eval "$(conda shell.bash hook)"
	conda activate psmc-env

Then, we'll make a subdirectory for future bootstraps with "mkdir boot". If you are testing multiple references for consistency, I suggest putting everything for each reference in its own subdirectory.

## Generating input

Generating input is essentially a simplified version of [GATK's widely used pipeline](https://github.com/UNM-CARC/QuickBytes/blob/master/GATK_QuickByte.md) using [bcftools](http://samtools.github.io/bcftools/bcftools.html) to leverage its simplicity and ability to generate a consensus FASTA file with heterozygosity. First, reads are alligned to the reference with BWA. Then, bcftools' mpileup and call are used to obtain variant calls, which are filtered using bcftools' view command. Finally, a consensus sequence is generated and converted to a "PSMC FASTA" for use in PSMC itself. Code for running these steps is below, assuming your reference is "reference.fa" and read files are called "sample_R1.fastq.gz" and "sample_R2.fastq.gz".

	# Align with BWA
	bwa index -bwtsw reference.fa
	# assuming you have 16 threads, not that this .sam file will be huge, and we'll remove it at the end
	bwa mem -t 16 reference.fa sample_R1.fastq.gz sample_R2.fastq.gz > bwa_alignment.sam
	# convert .sam to .bam
	samtools view -S -b bwa_alignment.sam > unsorted_alignment.bam
	# sort the .bam file
	picard SortSam I=unsorted_alignment.bam.bam O=sorted_alignment.bam SORT_ORDER=coordinate
	# remove old files, comment out if you want to keep them to troubleshoot
	rm bwa_alignment.sam
	rm unsorted_alignment.bam
	
	# pipeline combining bcftool's mpileup and call (consensus mode) using 16 threads, then samtools's vcfutils.pl
	# the latter filters variants with a depth less than 10 or greater than 50, and those with quality score under 30
	bcftools mpileup -Q 30 -q 30 -Ovu -f reference.fa sorted_alignment.bam --threads 16 | \
		bcftools call -c --threads 16 | \
		vcfutils.pl vcf2fq -d 10 -D 50 -Q 30 > variant_consensus.fq
	
	# generate PSMC input
	./psmc/utils/fq2psmcfa variant_consensus.fq > psmc_input.psmcfa

## Running PSMC

A basic PSMC run is outlined in the GitHub, but optimization is required to avoid overfitting problems. You can start with the default parameters and work from there. The first flag, -N, is the number of iterations to use. The second, -t, is the maximum coalescence time permitted. The third, -r, is the initial theta/rho ratio (effectively the per-base mutation rate divided by the per-base recombination rate). The final, -p, is the most complicated, but effectively delimits the number of time intervals per parameter. Using, say, '-p "25\*1"' would mean 25 parameters each spanning one time interval. The example has 28 parameters spanning 64 intervals (one spanning 4, 25 spanning 2, one spanning 4, then one spanning 6). The more recent intervals are on the left side of the expression. You can start with a set-up like below:

    ./psmc/psmc -N25 -t15 -r5 -p "4+25*2+4+6" -o sample.psmc sample.psmcfa

However, before we run bootstrapping and plot this, we want to make sure out runs are optimized.

#### Optimization

After our first run, we will view the end of the resulting .psmc file, which will look something like the table below (with many lines skipped for brevity). Each line represents a time interval, and the fifth column (i.e. 3651.038295 in the first row) the number of recombinations that occur. You want to make sure this number is at least 20 in all intervals, although the GitHub says 10 is sufficient. An example of a good result is below, keep repeating until you get a sufficient result:
	
	RS	0	0.000000	1.282590	3651.038295	0.004395	0.002875
	RS	1	0.005884	0.570172	8631.229543	0.010389	0.010062
	RS	2	0.012114	0.786536	6563.160557	0.007900	0.006705
	...
	RS	75	7.181803	0.765618	56.699641	0.000068	0.000064
	RS	76	7.610256	0.765618	34.277873	0.000041	0.000038
	RS	77	8.063918	0.765618	43.762351	0.000053	0.000049

An example of what worked well for me is below, with a notably different maximum coalescent time (biggest difference for me) and free parameters spanning shorter time intervals toward the present:

	./psmc/psmc -N25 -t10 -r5 -p "8*1+30*2+4+6" -o sample.psmc sample.psmcfa

Next, we want to bootstrap our results and plot them.

#### Bootstrapping and plotting

Bootstrapping is a step that can fortunately be run in parallel. There's no set number of bootstraps needed, but we'll do 50 here. We'll run this with GNU parallel. First, you'll need to load a parallel module. Then, you'll run what is essentially the same command as before, but with the -b flag:

	module load parallel/20190222-wsvg
	
	parallel '$SLURM_SUBMIT_DIR/psmc/psmc -N25 -t10 -r5 -b -p "8*1+30*2+4+6" \
		-o $SLURM_SUBMIT_DIR/boot/sample_r{}.psmc $SLURM_SUBMIT_DIR/sample.psmcfa' \
		::: $(seq 50)
	cat sample.psmc boot/sample_r*.psmc > sample_combined.psmc
	
Unfortunately, perl issues make it difficult to plot the output on CARC, so we suggest you transfer the 'sample_combined.psmc' file to your personal computer. Then, install psmc on your computer like above, and run the command as follows. The -g flag specifies your organism's generation time, and -u the per-generation mutation rate (no scientific notation sadly):

	/path/to/psmc/utils/psmc_plot.pl -p -g 2.2 -u 0.00000000506 bootstrapped_plot  sample_combined.psmc

Then you'll get an estimate of your focal population's detailed demographic history!

## Citations

Li, H., & Durbin, R. (2009). Fast and accurate short read alignment with Burrows-Wheeler transform. Bioinformatics, 25(14), 1754–1760. https://doi.org/10.1093/bioinformatics/btp324

Li, H., & Durbin, R. (2011). Inference of human population history from individual whole-genome sequences. Nature, 475(7357), 493–496. https://doi.org/10.1038/nature10231

Li, H., Handsaker, B., Wysoker, A., Fennell, T., Ruan, J., Homer, N., … Durbin, R. (2009). The Sequence Alignment/Map format and SAMtools. Bioinformatics, 25(16), 2078–2079. https://doi.org/10.1093/bioinformatics/btp352

Picard toolkit. (2019). Broad Institute, GitHub Repository. https://doi.org/http://broadinstitute.github.io/picard/

Tange, O. (2018). GNU Parallel 2018. https://doi.org/10.5281/ZENODO.1146014
