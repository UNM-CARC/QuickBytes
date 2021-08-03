# Processing Metabarcode reads #


### Different pipelines ###
1. Qiime2
2. USEARCH/UPARSE
3. Mothur
4. DADA2




### steps for each pipeline ###
1. install
2. join forward and reverse reads
3. filter reads (remove chimeras)
4. Create OTUs/ASVs
5. Calculate Abundances per sample
6. Determine Taxonomy for OTUs/ASVs







## Set up raw data ##

# create overal folder
mkdir metabarcoding
cd metabarcoding
src=~/metabarcoding

mkdir data
cd data

# dataset is called miseqsopdata
wget https://mothur.s3.us-east-2.amazonaws.com/wiki/miseqsopdata.zip
unzip miseqsopdata.zip

cd miseqsopdata
gzip >fa

# move back to main folder

cd src








## QIIME2 pipeline ##
need to finish to otu table
### install ###
```
   # load miniconda
   module load miniconda3-4.7.12.1-gcc-4.8.5-lmtvtik
   
   # enables conda activate to work
   eval "$(conda shell.bash hook)"
      

   #download the yml
   wget https://data.qiime2.org/distro/core/qiime2-2021.4-py38-linux-conda.yml
   
   # create conda environment called qiime2-2020.8
   conda env create -n qiime2-2021.4 --file qiime2-2021.4-py38-linux-conda.yml
   
   # delete yml
   rm qiime2-2020.8-py36-linux-conda.yml
   
   conda activate qiime2-2021.4
```


### join forward and reverse reads ###


```
cd scr

mkdir qiime2_tutorial

# merge reads
qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \
--input-path $src/data/MiSeq_SOP/fastqs/ \
--input-format CasavaOneEightSingleLanePerSampleDirFmt \
--output-path $src/qiime2_tutorial/demux-paired-end.qza

# summary figures online
qiime demux summarize \
  --i-data  $src/qiime2_tutorial/demux-paired-end.qza \
  --o-visualization $src/qiime2_tutorial/demux.qzv



qiime dada2 denoise-paired \
  --i-demultiplexed-seqs  $src/qiime2_tutorial/demux-paired-end.qza \
  --p-trunc-len-f 240 \
  --p-trunc-len-r 160 \
  --o-representative-sequences $src/qiime2_tutorial/rep-seqs-dada2.qza \
  --o-table  $src/qiime2_tutorial/table-dada2.qza \
  --o-denoising-stats  $src/qiime2_tutorial/stats-dada2.qza \
  --p-n-threads 0 # use all available cores

qiime feature-table tabulate-seqs \
  --i-data $src/qiime2_tutorial/rep-seqs-dada2.qza \
  --o-visualization $src/qiime2_tutorial/rep-seqs.qzv

qiime feature-table summarize \
  --i-table $src/qiime2_tutorial/table-dada2.qza \
  --o-visualization $src/qiime2_tutorial/table.qzv 

qiime metadata tabulate \
  --m-input-file $src/qiime2_tutorial/denoising-stats.qza \
  --o-visualization $src/qiime2_tutorial/denoising-stats.qzv
  
  # export rep seq sequenes.
 qiime tools export \
  --input-path $src/qiime2_tutorial/rep-seqs-dada2.qza \
  --output-path $src/qiime2_tutorial/rep-seqs.fasta



     
     
     
qiime tools export \
  --input-path $src/qiime2_tutorial/table-dada2.qza \
   --output-path $src/qiime2_tutorial/exported-feature-table
```




## Mothur pipeline ##
need to fix:
moving files out from data folder. 


### install ###

```
 # load miniconda
 module load miniconda3-4.7.12.1-gcc-4.8.5-lmtvtik
   
 # enables conda activate to work
 eval "$(conda shell.bash hook)"
      
conda env create -n mothur
conda install -n mothur -c bioconda mothur
conda activate mothur
 
 
```

### join forward and reverse reads ###

```
cd src
mkdir mothur_tutorial 

# unzip all files
cd $src/data/MiSeq_SOP/fastqs

# create a list of the files
mothur "#make.file(., type=gz, prefix=stability)"

# join forward and reverse reads. Gives you a count of reads of how many reads are assembled for each sample
mothur "#make.contigs(file=stability.files, processors=8)"

# summary stats on the merged reads
mothur "#summary.seqs(fasta=stability.trim.contigs.fasta)"

```



### filter reads, remove primer region, and remove chimeras ###
```
# removes reads that are longer than 275 bases. Likely to be errors
mothur "#screen.seqs(fasta=stability.trim.contigs.fasta, group=stability.contigs.groups, maxambig=0, maxlength=275)"


# find unique sequences in dataset

mothur "#unique.seqs(fasta=stability.trim.contigs.good.fasta)"

mothur "#count.seqs(name=stability.trim.contigs.good.names, group=stability.contigs.good.groups)"
mothur "#summary.seqs(count=stability.trim.contigs.good.count_table)"



# download reference database to trim reads
wget https://mothur.s3.us-east-2.amazonaws.com/wiki/silva.bacteria.zip
unzip silva.bacteria.zip


# trim to the V4 variable region of the silva bacteria dataset
mothur "#pcr.seqs(fasta=silva.bacteria/silva.bacteria.fasta, start=11894, end=25319, keepdots=F, processors=8)"

# align reads to Silva reference
mothur "#align.seqs(fasta=stability.trim.contigs.good.unique.fasta, reference=silva.bacteria/silva.bacteria.pcr.fasta)"


# summary of where the sequences align
mothur "#summary.seqs(fasta=stability.trim.contigs.good.unique.align, count=stability.trim.contigs.good.count_table)"

# trim sequences that extend beyond the Silva alignment (overhangs) and remove gap only columns. 
mothur "#filter.seqs(fasta=stability.trim.contigs.good.unique.align, vertical=T, trump=.)"


# find all unique sequences again in case there are some sequences that are now the same.
# creates:
# 1. stability.trim.contigs.good.unique.filter.count_table
# 2. stability.trim.contigs.good.unique.filter.unique.fasta
mothur "#unique.seqs(fasta=stability.trim.contigs.good.unique.filter.fasta, count=stability.trim.contigs.good.count_table)"



# pre-clustering to clean up sequencing errors. Differences of two nucleotides will be clustered. 

mothur "#pre.cluster(fasta=stability.trim.contigs.good.unique.filter.unique.fasta, count=stability.trim.contigs.good.unique.filter.count_table, diffs=2)"



# remove chimeras
Output files:
# 1. stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.count_table
# 2. stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.chimeras
# 3. stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.accnos
mothur "#chimera.vsearch(fasta=stability.trim.contigs.good.unique.filter.unique.precluster.fasta, count=stability.trim.contigs.good.unique.filter.unique.precluster.count_table, dereplicate=t)"

# remove chimeras from fasta
# output file
# 1. stability.trim.contigs.good.unique.filter.unique.precluster.pick.fasta
mothur "#remove.seqs(fasta=stability.trim.contigs.good.unique.filter.unique.precluster.fasta, accnos=stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.accnos)"


# downloading files to classifiy sequences and remove non-bacterial reads
wget https://mothur.s3.us-east-2.amazonaws.com/wiki/trainset18_062020.pds.tgz
tar zxvf  trainset18_062020.pds.tgz
 mv trainset18_062020.pds/* .
 

# remove sequences that are not bacteria. 
# output
# 1. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pds.wang.taxonomy
# 2. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pds.wang.tax.summary
mothur "#classify.seqs(fasta=stability.trim.contigs.good.unique.filter.unique.precluster.pick.fasta, count=stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.count_table, reference=trainset18_062020.pds.fasta, taxonomy=trainset18_062020.pds.tax, cutoff=80)"


# removing lineages here
# output
# 1. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pds.wang.pick.taxonomy
# 2. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pds.wang.accnos
# 3. stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.pick.count_table
# 4. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.fasta
mothur "#remove.lineage(fasta=stability.trim.contigs.good.unique.filter.unique.precluster.pick.fasta, count=stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.count_table, taxonomy=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pds.wang.taxonomy, taxon=Chloroplast-Mitochondria-unknown-Archaea-Eukaryota)"

# get summary of taxonomy by counts
mothur "#summary.tax(taxonomy=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pds.wang.pick.taxonomy, count=stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.pick.count_table)"


```


### Create OTUs/ASVs ###
```

# create file of distances between potential OTUs
# output
# 1. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.dist
mothur "#dist.seqs(fasta=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.fasta, cutoff=0.03)"

# create OTUs at 97% similarity.
# output 
# 1. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.list
# 2. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.steps
# 3. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.sensspec
mothur "#cluster(column=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.dist, count=stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.pick.count_table)"

# Creates OTU table with only OTUs
# output
# 1.  stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.shared
mothur "#make.shared(list=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.list, count=stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.pick.count_table, label=0.03)"

# create taxonomy for each OTU
# 1. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.0.03.cons.taxonomy
# 2. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.0.03.cons.tax.summary
mothur "#classify.otu(list=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.list, count=stability.trim.contigs.good.unique.filter.unique.precluster.denovo.vsearch.pick.pick.count_table, taxonomy=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pds.wang.pick.taxonomy, label=0.03)"

# get representative sequences files
# output 
# 1. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.0.03.rep.names
# 2. stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.0.03.rep.fasta
mothur "#get.oturep(column=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.dist, list=stability.trim.contigs.good.unique.filter.unique.precluster.pick.pick.opti_mcc.list, name=stability.trim.contigs.good.names,  fasta=stability.trim.contigs.good.unique.filter.unique.precluster.pick.fasta)
```


## USEARCH/UPARSE ##


### install ###
```
cd $src

mkdir usearch
cd usearch


# download the program
wget https://www.drive5.com/downloads/usearch11.0.667_i86linux32.gz

gunzip usearch11.0.667_i86linux32

# change permissions so you can run it
chmod +x usearch11.0.667_i86linux32

# rename so its shorter
 mv usearch11.0.667_i86linux32 usearch11.0.667
 
 ```
 
 
 ### 2. join forward and reverse reads ###
 ```
# need to unzip all the files first
cd $src/data/MiSeq_SOP/fastqs
gunzip *gz

cd $src/usearch

# merges forward and reverse reads. 
./usearch11.0.667 -fastq_mergepairs $src/data/MiSeq_SOP/fastqs/*R1*.fastq -fastqout merged.fq -relabel @


 
 # we can use this step to guide how we will filter the reads. 
 # this will tell us the size of the reads and the error rate. 
 # given the error rate is well below 0.5 and most reaads are above 250 bp, i will use that and 250 as the shortest size for length. 
  ./usearch11.0.667 -fastx_info merged.fq -secs 5 -output reads_info.txt
  
  

 # filter reads based off the suggestions above. This creates a fasta file which can be used for clustering
 ./usearch11.0.667 -fastq_filter merged.fq -fastaout reads.fasta -fastq_maxee 0.5 -fastq_minlen 250
```

### Create OTUs/ASVs #### 

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


### Calculate Abundances per sample ###
 ```

# map back reads and create OTU table
# the otutab.txt is the OTU table 
# the map.txt shows you how each read is mapped to what OTU
./usearch11.0.667 -otutab merged.fq -otus otus.fasta -otutabout otutab.txt -mapout map.txt

```

