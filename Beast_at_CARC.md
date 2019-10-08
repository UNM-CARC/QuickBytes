# BEAST at CARC

Bayesian Evolutionary Analysis by Sampling Trees [(BEAST)](https://beast.community/index.html) is a software package that performs
phylogenetic tree analysis with user specified molecular clock models using the widely popular Bayesian Markov chain Monte Carlo 
(MCMC) methods. BEAST has its originsin modeling pathogen evolution in near real time but is also popular for other phylogenetic 
applications. BEAST is a well documented and flexible tool for modeling phylogenetics. Using BEAST at CARC offers more power for 
rigorous computations.

## Generating BEAST imput files: BEAUti

BEAST uses .xml files which contain sequences and model parameters. Because BEAST is capable of incorporating a diverse range of 
meta data and specific time modelign parameters, the graphical user interface [BEAUTi](https://beast.community/first_tutorial) 
allows users to upload nexus files and create .xml files with ease.  

## Running BEAST on Wheeler

Once a .xml file is generated, beast can be easily on CARC. an example .pbs script is as follows: 

```
#!/bin/bash

#PBS -q default
#PBS -N BEASTjob
#PBS -l nodes=1:ppn=1
#PBS -l walltime=24:00:00
#PBS -j oe
#PBS -V

cd $PBS_O_WORKDIR

module load beast2-2.5.2-intel-19.0.4-hcnoysj

beast my_data.xml
```

The output should be a job log (joined with any potential error file, and a .tree file for your downstream analysis. For more assistance 
with BEAST at CARC please email help@carc.unm.edu. 







