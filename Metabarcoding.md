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
   
   conda activate qiime2-2020.8
```


### join forward and reverse reads ###





