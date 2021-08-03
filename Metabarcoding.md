# Processing Metabarcode reads #


### Different pipelines ###
1. Qiime2
2. USEARCH/UPARSE
3. Mothur
4. DADA2




### steps for each pipeline ###
1. install
2. join forward and reverse reads
3. remove primer regions
4. filter reads (remove chimeras)
5. Create OTUs/ASVs
6. Calculate Abundances per sample
7. Determine Taxonomy for OTUs/ASVs







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

# removing sequences 
mothur "#filter.seqs(fasta=stability.trim.contigs.good.unique.good.align, vertical=T, trump=.)"

```



