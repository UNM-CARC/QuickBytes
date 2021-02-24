# Running Stacks on CARC #

Stacks is a common and [well documented](https://catchenlab.life.illinois.edu/stacks/) pipeline for processing RADseq data. RADseq data is a method of reduced representation genomic sequencing, where genomic DNA is cut up with restriction enzymes, which are then targeted by sequencing adapters. This allows a researcher to get thousands of loci randomly scattered across the genome, which can be sequenced at moderate depths for low prices. This is sufficient for many population genomic analyses, such as tests of population structure, phylogenetics, gene flow, and even coarse attempts to locate regions of the genome that are under selection. Stacks can be run with or without a reference genome, but using a reference genome is reccomended for improved accuracy.

Stacks can easily be run on Wheeler with installed modules, and here we outline how with some simple "quality of life" adjustments and tips. We'll be focused on the reference based method, as the non-reference-based is sufficiently run through a driver script provided by the developers of Stacks (denovo_map.pl). We'll quickly mention it at the end. This can often be run on a single node on Wheeler, as the only intense step tends to be alignment, which is quick due to the small size of RADseq data. For example, a dataset of ~90 bird individuals with an average of 1 million reads/sample took four hours on one node. Organisms with larger genomes will take more time and memory.

## Preliminaries ##

### Sample list and Population maps ###

Before you get started, you'll need a list of sample names to run bwa conveniently. This is a file we'll call "sample_list", and it will just look like the following:

	<SAMPLE NAME>
	M_americana_Florida_MSBBIRD49539
	M_americana_NM_MSBBIRD39487
	......

Then, key to many pieces of population genetics software, Stacks needs a population map (popmap) for calculating metrics like F<sub>st</sub> and genetic dviersity. It will also allow the creation of certain imput files. It is simply a tab delimited file with one line per individual, with the first column representing the sample name and the second its population. Note that reduced versions of the popmaps can be made for running _gstacks_ and _populations_ for only a subset of your dataset.

	<SAMPLE NAME>\t<SAMPLE POPULATION>
	M_americana_Florida_MSBBIRD49539	EastBlackScoter
	M_americana_NewMexico_MSBBIRD39487	WestBlackScoter
	..................................	.....

### Demultiplexing with process_radtags ###

Demultiplexing with Stacks is comparatively easy. You just need a file of barcode information (we'll call it BARCODES.file) and your raw, multiplexed reads. The barcode information file can be paired or unapired, and should look like:

	<BARCODE1>\t<BARCODE2>\t<SAMPLE NAME>
	ATGCAT	GTACGT	M_americana_Florida_MSBBIRD49539
	ACGTAT	CTAGAT	M_americana_NewMexico_MSBBIRD39487
	......	......	......

Here is how to run it, assuming you are dealing with paired end reads, gzipped fastq files, and used a single enzyme (ndeI) for your restriction digest. Note the we assume you have a "raw_reads" directory:

	process_radtags -p $src/MULTIPLEXED_READS/ -b $src/BARCODES.file -o $src/raw_reads/ \
		-i gzfastq -e ndeI -c -q -r -E phred33 

The command is different for single end reads. You must specify each fastq input indiviually with the -f flag, as shown below. The rest is the same:

	process_radtags -f $src/MULTIPLEXED_READS/RAW_READS_01.fastq.gz -b $src/BARCODES.file -o $src/raw_reads/ \
		-i gzfastq -e ndeI -c -q -r -E phred33
	process_radtags -f $src/MULTIPLEXED_READS/RAW_READS_02.fastq.gz -b $src/BARCODES.file -o $src/raw_reads/ \
		-i gzfastq -e ndeI -c -q -r -E phred33
	.......

You can find full details on process_radtags [here](https://catchenlab.life.illinois.edu/stacks/comp/process_radtags.php).

## Reference Based Assembly ##

This method has several intermediate files, so we'll make directories to keep them separate (do this outside of script):

	mkdir raw_reads
	mkdir sam_files
	mkdir bam_files
	mkdir stacks_out
	mkdir populations_out

The modules you need are stacks, bwa, and samtools. All are availible on Conda, but you will almost certainly be running this on Wheeler (low resource use), which has recent versions of all three installed:

	module load stacks-2.41-gcc-7.4.0-7r6auk7
	module load bwa-0.7.17-intel-18.0.2-7jvpfu2
	module load samtools-1.10-gcc-9.3.0-python3-ikifznw

We'll also set some variables for refering to paths to stuff:

	src=$PBS_O_WORKDIR
	bwa_ref=$src/ReferenceBaseName
	threads=[number of threads]

Next, we need to index our reference:

	bwa index -p ${bwa_ref} ${bwa_ref}.fa

This is the big step, which uses the Burroughs-Wheeler Aligner to align our reads to our reference. Note that this should be able to be done using pipes, but I've had issues with that, so we just remove the files at the end of each loop.

	while read indiv
	do
		# echo is only to help you keep track of where the pipeline is
		echo ${indiv}
		bwa mem -t $threads $bwa_ref $src/raw_reads/${indiv}.fq.gz > $src/sam_files/${indiv}.sam
		samtools view -bS $src/sam_files/${indiv}.sam > $src/bam_files/${indiv}_unsort.bam
		samtools sort $src/bam_files/${indiv}_unsort.bam -o $src/bam_files/${indiv}.bam
		rm $src/sam_files/${indiv}.sam
		rm $src/bam_files/${indiv}_unsort.bam
	done < sample_list

The next step is to run gstacks, which runs these "traditional" genomics files into something Stacks can work with to make output files:

	gstacks -I $src/bam_files/ -M $src/popmap -O $src/stacks_out/ -t $threads

Finally, we run populations! This specific command will give us a 75% complete matrix of SNPs, one random SNP per locus, F<sub>st</sub> values, PLINK .bed and .map files, and use kernel smoothing for specific statistics. We also output a Variant Call Format (VCF) file, which can be used to generate inputs for most programs:
	
	populations -P $src/stacks_out/ -M $src/popmap -O $src/populations_out/ \
		--vcf -R .75 --write-random-snp --fstats --plink --smooth -t $threads
	
A quick note, if you want a quick phylogeny or fixed differences found in Stacks, you can get a interleaved phylip file by making a popmap file with each individual having its own population and specifying you want a phylip output. Please note that this is strict phylip format, meaning you want a maximum of 9 letters in your "population" column of the popmap (10 works, but will cause errors when input to certain programs). Also, this assumes you have a directory "populations_individual":

	populations -P $src/stacks_out/ -M $src/popmap_individual -O $src/popualtions_individual/ \
		-R .75 --phylip-var-all -t $threads

Learn more about the outputs and options for populations [on the Stacks website](https://catchenlab.life.illinois.edu/stacks/comp/populations.php). Also, as mentioned above, you can easily subset your data by changing the popmap used in gstacks and populations, as each sample has alignments performed separately.

## DeNovo Assembly ##

This is a lot simpler, but is generally considered less robust than a reference-based approach. It is described in full [here](https://catchenlab.life.illinois.edu/stacks/comp/denovo_map.php). There is a lot to think about for parameters when building loci, and we use default ones here, [read up on the Stacks website about them](https://catchenlab.life.illinois.edu/stacks/param_tut.php).

First, you only need the Stacks module and one new directory (assumes reads are in "raw_reads").

	mkdir stacks_denovo
	module load stacks-2.41-gcc-7.4.0-7r6auk7
	src=$PBS_O_WORKDIR
	threads=[number of threads]

Then you just run a single line!

	denovo_map.pl -T $threads -o $src/stacks_denovo/ --popmap $src/popmap --samples $src/raw_reads/ \
		-X "<Extra parameters for populations here>"

As I mentioned above, I mostly included this to demystify DeNovo Stacks, please read more on it before publishing anything!
