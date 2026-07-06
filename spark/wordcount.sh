#!/bin/bash
#SBATCH --job-name=spark-wordcount
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=00:10:00
#SBATCH --output=wordcount_%j.log
#SBATCH --partition=general

# ---------------------------------------------------------------------------
# wordcount.sh — Spark word count example for Easley (Slurm)
# Submit with:  sbatch wordcount.sh
# ---------------------------------------------------------------------------

module load spark/3.5.1-kn2k
export SPARK_HOME=$SPARK_ROOT

SCRATCHDIR="/tmp/spark-${SLURM_JOB_ID}"
mkdir -p "$SCRATCHDIR"

cp "$SLURM_SUBMIT_DIR/wordcount.py" "$SCRATCHDIR/"
cp "$SLURM_SUBMIT_DIR/big.txt"      "$SCRATCHDIR/"

cd "$SCRATCHDIR"

bash "$SLURM_SUBMIT_DIR/slurm-spark-submit" \
    wordcount.py big.txt > wordcount.log 2>&1

cp wordcount.log "$SLURM_SUBMIT_DIR/"
