# Metabarcoding Tutorial #

Metabarcoding is the process of using next-generation sequencing platforms (Illumina, PacBio, or Oxford Nanopore) to sequence amplicons and determine the ecological community that is present. The most common applications are microbiome analyses to study the community of bacteria or fungi. Given that metabarcoding relies upon PCR, biases do occur (e.g. primer biases, variation in loci copy number, incomplete lineage sorting, etc.). However, other techniques such as metagenomic sequencing cannot fully assemble larger genomes such as fungal genomes and fail to capture all of the species present in high diversity samples. Thus, metabarcoding remains the best option to characterize microbial communities. 

This tutorial is designed to give you an example of how to take the sequences you get from the sequencing facility and generate:

1. a fasta file of all of the unique sequences known as the representative sequence file (abbreviated to rep-seq) 
2. a table with the abundance of each of the representative sequences for every sample. Often referred to as an OTU/ASV table.  


One point of contention for metabarcoding projects is how to define which sequences are unique. The traditional view was to  cluster any sequences that diverged by less than 3% of sequence similarity into a species known as an OTU (operational taxon unit). However, other people reject the clustering step as being arbitrary and define any divergence as noteworthy. This approach is known as ASVs, (amplicon sequence variants). While the debate between clustering to OTUs or using ASVs remains contentious, for most community analyses, each will give you the same biological answer. The right choice will depend on your question and your system. For example, fungal metabarcoding studies use a highly variable region called the internal transcribed spacer (ITS) which is known to diverge by 3% within an individual (they have many copies of the ITS region) and among members of the same species. Thus, clustering to OTUs is more logical for fungal taxa to avoid oversplitting species. However, if you were using a conserved gene such as the 18S, ASV's might give you a better approximation of species.

 Final note: make sure you are runing the commands in a pbs script or on an interactive node!
 
### Different pipelines ###
There are many different pipelines to process metabarcoding samples. For this tutorial we will focus on the three main ones:
1. QIIME2 (using DADA2)
2. Mothur
3. USEARCH




### Steps for each pipeline ###
For eachof them, they will follow these key steps:
1. install
      * how to set up the environments. 
3. join forward and reverse reads
      * Illumina sequencing produces forward and reverse reads for every sequence.
5. filter reads (remove chimeras)
      * The merged reads will need to be trimmed of extraneous sequence, poor quality sequences will need be removed, and chimera, the generation of DNA sequences           from disparate organisms due to errors in the PCR process, will also need to be removed. 
7. create OTUs/ASVs
      * The unique sequences will be determined based on the chosen algorithm. 
9. Creation of OTU/ASV table
      * The abundances of the OTUs or ASVs will be tabulated per sample to create the table. 
11. determine Taxonomy for OTUs/ASVs
      * The taxonomy of each of the OTUs/ASVs will be inferred by comparing the sequences against commonly used databases.



## Data for tutorial ##
For each of the pipelines we will use 16S bacterial of the V4 region provided by the Mothur pipeline. 

### create folder structure ###
```
mkdir metabarcoding
cd metabarcoding
src=~/metabarcoding

mkdir data
cd data

# dataset is called miseqsopdata
wget https://mothur.s3.us-east-2.amazonaws.com/wiki/miseqsopdata.zip
unzip miseqsopdata.zip

cd miseqsopdata
# gzip all fastq files to save space.
gzip *fa

# move back to main folder
cd $src
```







## QIIME2 (using DADA2) pipeline ##
For QIIME2, every file created is either uses a .qsv or .qsa extension. the .qsv is a zip file that contains data and the metadata. The .qsv are visualizations that can be viewed by uploading the file to https://view.qiime2.org/. QIIME2 prefers to create ASVs using the DADA2 method, so this tutorial will do that.


### install ###
We will create a conda environment called qiime2-2021.4. 
```
   # To install QIIME2 on the Wheeler, Xena, or Hopper clusters, use the following command:
   module load miniconda3
   
   # To do a similar installation on the Taos cluster, use the following command instead:
   module load miniconda3-4.10.3-gcc-10.2.0-gu6ytpa
   
   #download the yml
   wget https://data.qiime2.org/distro/core/qiime2-2021.4-py38-linux-conda.yml
   
   # create conda environment called qiime2-2020.8
   conda env create -n qiime2-2021.4 --file qiime2-2021.4-py38-linux-conda.yml
   
   # delete yml
   rm qiime2-2020.8-py36-linux-conda.yml
   
```


### join forward and reverse reads ###


```
conda activate qiime2-2021.4
cd $scr

mkdir qiime2_tutorial
cd qiime2_tutorial

# merge reads
qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \
--input-path $src/data/MiSeq_SOP/fastqs/ \
--input-format CasavaOneEightSingleLanePerSampleDirFmt \
--output-path $src/qiime2_tutorial/demux-paired-end.qza

# summary figures online
# open visual at this link: https://view.qiime2.org/
qiime demux summarize \
  --i-data  $src/qiime2_tutorial/demux-paired-end.qza \
  --o-visualization $src/qiime2_tutorial/demux.qzv
```


### filter reads (remove chimeras) and create ASVs ###
This step does all of the filtering and creation of ASVs at once. 
```
# following what we see in the visualization we will trim the reads and denoise the reads. 
# this will also create the rep seq qiime file wiht the ASVs. 
# This method denoises paired-end sequences, dereplicates them, and filters chimeras.
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs  $src/qiime2_tutorial/demux-paired-end.qza \
  --p-trunc-len-f 240 \
  --p-trunc-len-r 160 \
  --o-representative-sequences $src/qiime2_tutorial/rep-seqs-dada2.qza \
  --o-table  $src/qiime2_tutorial/table-dada2.qza \
  --o-denoising-stats  $src/qiime2_tutorial/stats-dada2.qza \
  --p-n-threads 0 # use all available cores

# create rep-seq file.
qiime feature-table tabulate-seqs \
  --i-data $src/qiime2_tutorial/rep-seqs-dada2.qza \
  --o-visualization $src/qiime2_tutorial/rep-seqs.qzv

# create summary table 
qiime feature-table summarize \
  --i-table $src/qiime2_tutorial/table-dada2.qza \
  --o-visualization $src/qiime2_tutorial/table.qzv 

```

### Creation of ASV table ###
```
  # export rep seq sequences.
  # it is exported in the rep-seqs wiht 
 qiime tools export \
  --input-path $src/qiime2_tutorial/rep-seqs-dada2.qza \
  --output-path $src/qiime2_tutorial/rep-seqs
     
# creates OTU table
qiime tools export \
  --input-path $src/qiime2_tutorial/table-dada2.qza \
   --output-path $src/qiime2_tutorial/exported-feature-table
```






## Mothur pipeline ##
Mothur uses a unique syntax in which each command begins is structured liek this: mothur "#command here(parameters_here=X)". Mothur can do ASVs but the preference of the its creator is to use OTUS so we will do that here. 

### install ###

```
 # load miniconda
 module load miniconda3-4.7.12.1-gcc-4.8.5-lmtvtik
   
      
conda env create -n mothur
conda install -n mothur -c bioconda mothur

 
 
```

### join forward and reverse reads ###

```
conda activate mothur
cd $src
mkdir mothur_tutorial 

cd mothur_tutorial
# copy files into mothur folder
scp $src/data/MiSeq_SOP/fastqs/*gz .

# create a list of the files
# output
#     1. stability.files
mothur "#make.file(inputdir=., type=gz, prefix=stability)"


# join forward and reverse reads. Gives you a count of reads of how many reads are assembled for each sample
# output
#     1. stability.trim.contigs.fasta
#     2. stability.scrap.contigs.fasta
#     3. stability.contigs.report
#     4. stability.contigs.groups
mothur "#make.contigs(file=stability.files, processors=8)"

# summary stats on the merged reads
mothur "#summary.seqs(fasta=stability.trim.contigs.fasta)"

```



### filter reads, remove primer region, and remove chimeras ###
```
# removes reads that are longer than 275 bases. Likely to be errors
# output files
#        1. stability.contigs.pick.groups
#        2. stability.trim.contigs.good.fasta
#        3. stability.trim.contigs.bad.accnos
#        4. stability.contigs.good.groups
mothur "#screen.seqs(fasta=stability.trim.contigs.fasta, group=stability.contigs.groups, maxambig=0, maxlength=275)"



# find unique sequences in dataset. This is to reduce the size of the dataset and reduce redundancies. 
# output files
#        1.stability.trim.contigs.good.names
         2. stability.trim.contigs.good.unique.fasta
mothur "#unique.seqs(fasta=stability.trim.contigs.good.fasta)"


# count up how many reads are match the good names. 
# output file
#        1. stability.trim.contigs.good.count_table
mothur "#count.seqs(name=stability.trim.contigs.good.names, group=stability.contigs.good.groups)"


# now going to trim unique reads to silva dataset. 

# download reference database to trim reads
wget https://mothur.s3.us-east-2.amazonaws.com/wiki/silva.bacteria.zip
unzip silva.bacteria.zip


# trim to the V4 variable region of the silva bacteria dataset. This is the reigon we sequenced
# output file
#        1. silva.bacteria/silva.bacteria.pcr.fasta
mothur "#pcr.seqs(fasta=silva.bacteria/silva.bacteria.fasta, start=11894, end=25319, keepdots=F, processors=8)"

# align unique reads to Silva reference
# output files. 
#        1. stability.trim.contigs.good.unique.align
#        2. stability.trim.contigs.good.unique.align.report
mothur "#align.seqs(fasta=stability.trim.contigs.good.unique.fasta, reference=silva.bacteria/silva.bacteria.pcr.fasta)"


# summary of where the sequences align
# output file
#        1. stability.trim.contigs.good.unique.summary
mothur "#summary.seqs(fasta=stability.trim.contigs.good.unique.align, count=stability.trim.contigs.good.count_table)"

# trim sequences that extend beyond the Silva alignment (overhangs) and remove gap only columns. 
# output file
#        1. stability.filter
#        2. stability.trim.contigs.good.unique.filter.fasta
mothur "#filter.seqs(fasta=stability.trim.contigs.good.unique.align, vertical=T, trump=.)"


# find all unique sequences again in case there are some sequences that are now identical.
# creates:
#     1. stability.trim.contigs.good.unique.filter.count_table
#     2. stability.trim.contigs.good.unique.filter.unique.fasta
mothur "#unique.seqs(fasta=stability.trim.contigs.good.unique.filter.fasta, count=stability.trim.contigs.good.count_table)"



# pre-clustering to clean up sequencing errors. Differences of two nucleotides will be clustered. 
# creates an output file for each sample so it can create a lot of files.
# output files
#        1. stability.trim.contigs.good.unique.filter.unique.precluster.fasta
#        2. stability.trim.contigs.good.unique.filter.unique.precluster.count_table
#        3. stability.trim.contigs.good.unique.filter.unique.precluster.F3D0.map
#        4. stability.trim.contigs.good.unique.filter.unique.precluster.F3D1.map
#        5. stability.trim.contigs.good.unique.filter.unique.precluster.F3D141.map
#        6. stability.trim.contigs.good.unique.filter.unique.precluster.F3D142.map
#        7. stability.trim.contigs.good.unique.filter.unique.precluster.F3D143.map
#        8. stability.trim.contigs.good.unique.filter.unique.precluster.F3D144.map
#        9. stability.trim.contigs.good.unique.filter.unique.precluster.F3D145.map
#        10. stability.trim.contigs.good.unique.filter.unique.precluster.F3D146.map
#        11. stability.trim.contigs.good.unique.filter.unique.precluster.F3D147.map
#        12. stability.trim.contigs.good.unique.filter.unique.precluster.F3D148.map
#        13. stability.trim.contigs.good.unique.filter.unique.precluster.F3D149.map
#        14. stability.trim.contigs.good.unique.filter.unique.precluster.F3D150.map
#        15. stability.trim.contigs.good.unique.filter.unique.precluster.F3D2.map
#        16. stability.trim.contigs.good.unique.filter.unique.precluster.F3D3.map
#        17. stability.trim.contigs.good.unique.filter.unique.precluster.F3D5.map
#        18. stability.trim.contigs.good.unique.filter.unique.precluster.F3D6.map
#        19. stability.trim.contigs.good.unique.filter.unique.precluster.F3D7.map
#        20. stability.trim.contigs.good.unique.filter.unique.precluster.F3D8.map
#        21. stability.trim.contigs.good.unique.filter.unique.precluster.F3D9.map
#        22. stability.trim.contigs.good.unique.filter.unique.precluster.Mock.map
mothur "#pre.cluster(fasta=stability.trim.contigs.good.unique.filter.unique.fasta, count=stability.trim.contigs.good.unique.filter.count_table, diffs=2)"



# remove chimeras
Output files:
#     1. stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.count_table
#     2. stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.chimeras
#     3. stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.accnos
mothur "#chimera.vsearch(fasta=stability.trim.contigs.good.unique.filter.unique.precluster.fasta, count=stability.trim.contigs.good.unique.filter.unique.precluster.count_table, dereplicate=t)"

# remove chimeras from fasta
# output file
# 1. stability.trim.contigs.good.unique.filter.unique.precluster.pick.fasta
mothur "#remove.seqs(fasta=stability.trim.contigs.good.unique.filter.unique.precluster.fasta, accnos=stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.accnos)"


# downloading files to classifiy sequences and remove non-bacterial reads
wget https://mothur.s3.us-east-2.amazonaws.com/wiki/trainset18_062020.pds.tgz
tar zxvf  trainset18_062020.pds.tgz
 

# remove sequences that are not bacteria. 
# output
#     1. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pds.wang.taxonomy
#     2. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pds.wang.tax.summary
mothur "#classify.seqs(fasta=stability.trim.contigs.good.unique.filter.unique.precluster.pick.fasta, count=stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.count_table, reference=trainset18_062020.pds/trainset18_062020.pds.fasta, taxonomy=trainset18_062020.pds/trainset18_062020.pds.tax, cutoff=80)"


# removing lineages here
# output
#     1. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pds.wang.pick.taxonomy
#     2. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pds.wang.accnos
#     3. stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.pick.count_table
#     4. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.fasta
mothur "#remove.lineage(fasta=stability.trim.contigs.good.unique.filter.unique.precluster.pick.fasta, count=stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.count_table, taxonomy=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pds.wang.taxonomy, taxon=Chloroplast-Mitochondria-unknown-Archaea-Eukaryota)"

# get summary of taxonomy by counts
mothur "#summary.tax(taxonomy=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pds.wang.pick.taxonomy, count=stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.pick.count_table)"


```


### create OTUs ###
```

# create file of distances between potential OTUs
# output
#     1. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.dist
mothur "#dist.seqs(fasta=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.fasta, cutoff=0.03)"

# create OTUs at 97% similarity.
# output 
#     1. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.list
#     2. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.steps
#     3. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.sensspec
mothur "#cluster(column=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.dist, count=stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.pick.count_table)"

# Creates OTU table with only OTUs
# output
#     1.  stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.shared
mothur "#make.shared(list=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.list, count=stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.pick.count_table, label=0.03)"

# create taxonomy for each OTU
#     1. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.0.03.cons.taxonomy
#     2. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.0.03.cons.tax.summary
mothur "#classify.otu(list=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.list, count=stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.pick.count_table, taxonomy=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pds.wang.pick.taxonomy, label=0.03)"

# get representative sequences files
# output 
#     1. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.0.03.rep.names
#     2. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.0.03.rep.fasta
mothur "#get.oturep(column=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.dist, list=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.list, name=stability.trim.contigs.good.names,  fasta=stability.trim.contigs.good.unique.filter.unique.precluster.pick.fasta)"
```





## USEARCH ##
USEARCH is a proprietary software developed by Robert Edgar. For this tutorial, we will use the free, 32-bit version. However, if you have multiple sequencing runs, you will likely need to upgrade to the paid, 64-bit version. USEARCH can do OTUs or ASVs. For this example I stuck with OTUs. Many of the commands can easily be changed to VSEARCH, an alternative that is open-source.

### install ###
```
cd $src

mkdir usearch_tutorial
cd usearch_tutorial


# download the program
wget https://www.drive5.com/downloads/usearch11.0.667_i86linux32.gz

gunzip usearch11.0.667_i86linux32

# change permissions so you can run it
chmod +x usearch11.0.667_i86linux32

# rename so its shorter
 mv usearch11.0.667_i86linux32 usearch11.0.667
 
 ```
 
 
 ### join forward and reverse reads ###
 ```
# need to unzip all the files first
cd $src/data/MiSeq_SOP/fastqs
gunzip *gz

cd $src/usearch_tutorial

# merges forward and reverse reads. 
./usearch11.0.667 -fastq_mergepairs $src/data/MiSeq_SOP/fastqs/*R1*.fastq -fastqout merged.fq -relabel @


 
 # we can use this step to guide how we will filter the reads. 
 # this will tell us the size of the reads and the error rate. 
 # given the error rate is well below 0.5 and most reaads are above 250 bp, i will use that and 250 as the shortest size for length. 
  ./usearch11.0.667 -fastx_info merged.fq -secs 5 -output reads_info.txt
  
  

 # filter reads based off the suggestions above. This creates a fasta file which can be used for clustering
 ./usearch11.0.667 -fastq_filter merged.fq -fastaout reads.fasta -fastq_maxee 0.5 -fastq_minlen 250
```

### Create OTUs #### 

```
# dereplicate sequences so we only have unique reads. 
# creates file with uniques.fasta which each read relabeled as uniq
./usearch11.0.667 -fastx_uniques reads.fasta -fastaout uniques.fasta -sizeout -relabel Uniq

# creates otus at 97% and removes chimeras via UPARSE
# warning: this will throw out singletons so change -minsize to 1. 
# creates uparse.txt - log of how the clustering went for each unique read.
# creates otus.fasta - representative OTUs. 
./usearch11.0.667 -cluster_otus uniques.fasta -otus otus.fasta -uparseout uparse.txt -relabel Otu -minsize 2


```


### create OTU table ###
 ```
# map back reads and create OTU table
# the otutab.txt is the OTU table 
# the map.txt shows you how each read is mapped to what OTU
./usearch11.0.667 -otutab merged.fq -otus otus.fasta -otutabout otutab.txt -mapout map.txt

```


### determine Taxonomy for OTUs ###
```
# downloaad rdp database
wget https://drive5.com/sintax/rdp_16s_v16.fa.gz
gunzip rdp_16s_v16.fa.gz

# Creates taxonomy file with OTU and the taxonomy in the reads.sintax file
./usearch11.0.667 -sintax otus.fasta -db rdp_16s_v16.fa -tabbedout reads.sintax -strand both -sintax_cutoff 0.8
```




