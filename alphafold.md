# Alphafold # 
Alphafold predicts the 3D structure of proteins from their amino acid sequence. A deep learning system that uses a combination of sequence alignment, evolutionary information, and physical principles to generate its predictions.
Primarily written in python, the first version of alphafold was released in 2016, and has been updated as recently as 2022. There are two ways to run alphafold here at CARC. Option 1 is to use [localcolabfold.](https://github.com/YoshitakaMo/localcolabfold) You may find that Localcolabfold is easier to get running, however it will come with tradeoffs in certain areas, For Example, localcolabfold uses the pdb70 database, and there is not a great way to choose a different database to use. If you are unsure which version is best for you, we recommend you review the readme & issues for localcolabfold to determine if there are any features you may need. 

# Alphafold w/ LocalColabFold:

Localcolabfold is set up as part of our module system at CARC. As with anything as part of the module system, you can use `module spider localcolabfold` to get more information about the module. This will also list other dependencies, if any, such as a different compiler. 

localColabFold runs with the command `colabfold_batch`. The only other thing you will need to provide is the input fasta file. Below is an example of a slurm script to run using localcolabfold on Hopper. 


     #!/bin/bash
     #SBATCH --job-name alphafold
     #SBATCH --mail-user=<your_email>
     #SBATCH --partition general
     #SBATCH --Nodes 1
     #SBATCH --ntasks 1
     #SBATCH --cpus-per-task 64
     #SBATCH --time 1:00:00
     
     module load localcolabfold
     
     INPUT_FILE_PATH=/path/to/input.fasta
     now=$(date +"%m_%d_%H_%M_%S")
     OUTPUTDIR=$SLURM_SUBMIT_DIR/$SLURM_JOB_NAME-$now
     
     mkdir -p $OUTPUTDIR
     
     cd $SLURM_SUBMIT_DIR
     
     srun colabfold_batch $INPUT_FILE_PATH $OUTPUTDIR

Reference the [localcolabfold documentation](https://github.com/YoshitakaMo/localcolabfold?tab=readme-ov-file#flags) for flags you may find useful.


# Alphafold w/ Singularity Image:

## Choose your alphafold version ## 
There are multiple versions of alphafold installed using singularity images. You can view each of the versions installed with the command:

     ls /projects/shared/singularity/alphafold*

 and hit tab. You'll see below we currently have version 2.0 and 2.3.1 installed. For this tutorial we will be using version 2.0. 
For this tutorial we will be using version 2.0. 


Now we can create a new directory with

    mkdir alphafold
    
and move into that directory with

    cd alphafold

## Running Alphafold ##
Inside the alphafold directory, you will be able to run the program using the slurm script, this script will differ based on the machine you are using. Xena is the machine at CARC that has GPU resources, so you will need to use xena if you hope to run using the gpus. 

Choose one of the scripts below, in this case we will be using Hopper. Create a new file using your favorite editor. For example, 

    vim alphafold.sh
    
then hit `i` to go into insert mode, and past the contents from the below script into this file. You can then add your email to get alerts about the run. When you are finished editing this file, type `ESC` to exit insert mode, followed by `:wq` to write & quite the file, this will save your changes. 

### Xena Script ###
Here, we are passing two additional flags when running the script, the first is `--partition=singleGPU` which will make sure we are assigned a node that only has a single gpu. The second is `-G 1` which is what tells the program to use the gpu. 
While optimizing, you might find that switching to one of the nodes with multiple gpus will increase your speed. You can achieve this by instead adding the `--partition=dualGPU` as well as `-G 2`.

    #SBATCH --job-name alphafold
    #SBATCH --time=08:00:00
    #SBATCH --ntasks=1
    #SBATCH --cpus-per-task=8
    #SBATCH --mem=20G
    #SBATCH --partition=singleGPU
    #SBATCH --output alphafold.out
    #SBATCH --error alphafold.err
    #SBATCH -G 1
    
    #SBATCH --mail-user < your email > 
    #SBATCH --mail-type all
    
    module load singularity
    
    # Specify input/output paths
    SINGULARITY_IMAGE_PATH=/projects/shared/singularity/
    ALPHAFOLD_DATA_PATH=/carc/scratch/shared/alphafold/data/70
    ALPHAFOLD_MODELS=$ALPHAFOLD_DATA_PATH/params
    ALPHAFOLD_INPUT_FASTA=$SLURM_SUBMIT_DIR/input_test.fasta
    NOW=$(date +"%Y_%m_%d_%H_%M_%S")
    ALPHAFOLD_OUTPUT_DIR=$SLURM_SUBMIT_DIR/alphafold_output-$NOW
    
    mkdir -p $ALPHAFOLD_OUTPUT_DIR
    
    #Run the command
    singularity run  --nv \
     --bind $ALPHAFOLD_DATA_PATH:/data \
     --bind $ALPHAFOLD_MODELS \
     --bind $ALPHAFOLD_OUTPUT_DIR:/alphafold_output \
     --bind $ALPHAFOLD_INPUT_FASTA:/input.fasta \
     --bind .:/etc \
     --pwd  /app/alphafold $SINGULARITY_IMAGE_PATH/alphafold-2.0.sif \
     --fasta_paths=/input.fasta  \
     --uniref90_database_path=/data/uniref90/uniref90.fasta  \
     --data_dir=/data \
     --mgnify_database_path=/data/mgnify/mgy_clusters.fa   \
     --bfd_database_path=/data/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt \
     --uniclust30_database_path=/data/uniclust30/uniclust30_2018_08/uniclust30_2018_08 \
     --pdb70_database_path=/data/pdb70/pdb70  \
     --template_mmcif_dir=/data/pdb_mmcif/mmcif_files  \
     --obsolete_pdbs_path=/data/pdb_mmcif/obsolete.dat \
     --max_template_date=2020-05-14   \
     --output_dir=/alphafold_output  \
     --model_names='model_1' \
     --preset=casp14

### Hopper Script ###

    #!/bin/bash
    #SBATCH --job-name alphafold
    #SBATCH --time=08:00:00
    #SBATCH --ntasks=1
    #SBATCH --cpus-per-task=32
    #SBATCH --mem=0G
    #SBATCH --partition=general
    #SBATCH --output alphafold.out
    #SBATCH --error alphafold.err

    #SBATCH --mail-user < your email > 
    #SBATCH --mail-type all
    
    module load singularity
    
    # Specify input/output paths
    SINGULARITY_IMAGE_PATH=/projects/shared/singularity/
    ALPHAFOLD_DATA_PATH=/carc/scratch/shared/alphafold/data/70
    ALPHAFOLD_MODELS=$ALPHAFOLD_DATA_PATH/params
    ALPHAFOLD_INPUT_FASTA=$SLURM_SUBMIT_DIR/input_test.fasta
    NOW=$(date +"%Y_%m_%d_%H_%M_%S")
    ALPHAFOLD_OUTPUT_DIR=$SLURM_SUBMIT_DIR/alphafold_output-$NOW
    
    mkdir -p $ALPHAFOLD_OUTPUT_DIR
    
    #Run the command
    singularity run --nv \
     --bind $ALPHAFOLD_DATA_PATH:/data \
     --bind $ALPHAFOLD_MODELS \
     --bind $ALPHAFOLD_OUTPUT_DIR:/alphafold_output \
     --bind $ALPHAFOLD_INPUT_FASTA:/input.fasta \
     --bind .:/etc \
     --pwd  /app/alphafold $SINGULARITY_IMAGE_PATH/alphafold-2.0.sif \
     --fasta_paths=/input.fasta  \
     --uniref90_database_path=/data/uniref90/uniref90.fasta  \
     --data_dir=/data \
     --mgnify_database_path=/data/mgnify/mgy_clusters.fa   \
     --bfd_database_path=/data/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt \
     --uniclust30_database_path=/data/uniclust30/uniclust30_2018_08/uniclust30_2018_08 \
     --pdb70_database_path=/data/pdb70/pdb70  \
     --template_mmcif_dir=/data/pdb_mmcif/mmcif_files  \
     --obsolete_pdbs_path=/data/pdb_mmcif/obsolete.dat \
     --max_template_date=2020-05-14   \
     --output_dir=/alphafold_output  \
     --model_names='model_1' \
     --preset=casp14

#### Input File ####
These scripts expect you to have a file named `input_test.fasta` where you will give your input sequence. This should be in the format:

(alphafold/input_test.fasta)

    > 350 residue example sequence   
    MTANHLESPNCDWKNNRMAIVHMVNVTPLRMMEEPRAAVEAAFEGIMEPAVVGDMVEYWNKMISTCCNYYQMGSSRSHLEEKAQMVDRFWFCPCIYYASGKWRNMFLNILHVWGHHHYPRNDLKPCSYLSCKLPDLRIFFNHMQTCCHFVTLLFLTEWPTYMIYNSVDLCPMTIPRRNTCRTMTEVSSWCEPAIPEWWQATVKGGWMSTHTKFCWYPVLDPHHEYAESKMDTYGQCKKGGMVRCYKHKQQVWGNNHNESKAPCDDQPTYLCPPGEVYKGDHISKREAENMTNAWLGEDTHNFMEIMHCTAKMASTHFGSTTIYWAWGGHVRPAATWRVYPMIQEGSHCQC

#### localtime ####
Your job will fail within the first few moments if the input file is not formatted properly. It will also require you to have a `localtime` file in the directory in which you are running, which you can create with 

    touch localtime
    
This file does not directly impact the simulation in any way, but is used to track the time to make your tests reproducible. If this file is empty, it will default to using the current time in UTC, but you could also place the correct time in:

(alphafold/localtime)

    2022-10-28T16:15:29
    
## Run ##
You can now run your alphafold sequence with the command 

    sbatch alphafold.sh 

This will hand your script you made above to the slurm scheduler. If you added your email to the script, you will receive an email that it has been added to the queue, once it starts, and once it ends. It will also email if it fails before a successful completion. If your run fails, more information can be found in the `alphafold.out` & `alphafold.err` files which will be generated as each run begins.

You can check if your run is still running with 

    squeue --me 

This will list all jobs you currently have both queued & running. On the general partitions your time will be [limited to between 4 and 48 hours](https://github.com/UNM-CARC/webinfo/blob/main/resource_limits.md) of runtime.


## Output ##
After a successful job, you will notice multiple output files. They will be placed in the `./alphafold_output-<Timestamp>/input/*` Where you will have the resulting .pdb, .pkl, and .json files. 
    
Now that it is on your local computer, you can now view this file on your computer if you have the proper software to view a pdb file. 
