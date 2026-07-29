# BEAST at CARC

Bayesian Evolutionary Analysis by Sampling Trees [(BEAST)](https://beast.community/index.html) is a software package that performs
phylogenetic tree analysis with user specified molecular clock models using the widely popular Bayesian Markov chain Monte Carlo 
(MCMC) methods. BEAST has its origins in modeling pathogen evolution in near real time but is also popular for other phylogenetic 
applications. BEAST is a well documented and flexible tool for modeling phylogenetics. Using BEAST at CARC offers more power for 
rigorous computations.

## Generating BEAST imput files: BEAUti

BEAST uses .xml files which contain sequences and model parameters. Because BEAST is capable of incorporating a diverse range of 
meta data and specific time modeling parameters, the graphical user interface [BEAUTi](https://beast.community/first_tutorial) 
allows users to upload nexus files and create .xml files with ease. Make sure that the version of beast in the module you load 
matches the version of BEAUTi used to generate the .xml files. 

## Running BEAST on Easley

Once a .xml file is generated, beast can be easily run on CARC. An example Slurm script is as follows: 

```
#!/bin/bash

#SBATCH --job-name BEASTjob
#SBATCH --partition general
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 8
#SBATCH --time 24:00:00
#SBATCH --output BEASTjob.out
#SBATCH --error BEASTjob.err

cd $SLURM_SUBMIT_DIR

module load llvm/17.0.6-ahyd
module load beast2/2.7.4-mh57

beast my_data.xml
```

Submit it with `sbatch beast_job.sh`.

Note: as of this writing there's also a flat `beast/2.7.7` module listed by `module avail`, but it currently fails to load on Easley ("exist but cannot be loaded as requested") — this looks like a broken module install, not a user error. `beast2/2.7.4-mh57` (loaded via its `llvm/17.0.6` prerequisite, as shown above) is the version confirmed working; report the broken `beast/2.7.7` module to help@carc.unm.edu if you run into it.

The output should be a job log (joined with any potential error file), and a .tree file for your downstream analysis. For more assistance 
with BEAST at CARC please email help@carc.unm.edu. 







