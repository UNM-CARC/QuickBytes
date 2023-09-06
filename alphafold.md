# Alphafold # 
Alphafold predicts the 3D structure of proteins from their amino acid sequence. A deep learning system that uses a combination of sequence alignment, evolutionary information, and physical principles to generate its predictions.
Primarily written in python, the first version of alphafold was released in 2016, and has been updated as recently as 2022.

## Download ##
The most recent version of alphafold can be found at [github.com/deepmind/alphafold]. Clone the repository to your machine with 
`git clone git@github.com:deepmind/alphafold.git`

## Running Alphafold ##
Inside the alphafold directory, you will be able to run the program using the slurm script, this script will differ based on the machine you are using. Xena is the machine at CARC that has GPU resources, so you will need to use xena if you hope to run using the gpus. 

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
    
    #SBATCH --mail-user < your unm email > 
    #SBATCH --mail-type all
    
    module load singularity
    
    # Specify input/output paths
    SINGULARITY_IMAGE_PATH=/projects/shared/singularity/
    ALPHAFOLD_DATA_PATH=/carc/scratch/shared/alphafold/data
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
     --pwd  /app/alphafold $SINGULARITY_IMAGE_PATH/alphafold.sif \
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

    #SBATCH --mail-user < your unm email > 
    #SBATCH --mail-type all
    
    module load singularity
    
    # Specify input/output paths
    SINGULARITY_IMAGE_PATH=/projects/shared/singularity/
    ALPHAFOLD_DATA_PATH=/carc/scratch/shared/alphafold/data
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
     --pwd  /app/alphafold $SINGULARITY_IMAGE_PATH/alphafold.sif \
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
     --preset=casp4

## TODO Parallel ##
@ryan can it be run parallel?
- adding `module load openmpi/4.1.4-7gqe` (newest openmpi version from `module spider mpi`) successfully submits the job, but only allocated one node. 
- swtiched run command from `singularity run --nv` to `mpurun -np 2 singularity run` which gives an "oversubscribing" error. can be bypassed by adding `--oversubscribe` to the mpi run command, which alloows the run to go through and start, but only actually runs on one node.
- link to paper on running alphafold parallel: [https://arxiv.org/pdf/2111.06340.pdf]

### Current run time estimates ###
- hopper: (pending) previously ~ 8hrs (2:02 am)
- xena singleGPU
 - job: 396593
 - runtime: 2:48 (1:12am -> 4:00 am)
- xena dualGPU
 - job: 396594 
 - runtime: 3:30 (1:13am -> 4:33am)




