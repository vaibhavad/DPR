#!/bin/bash
#SBATCH --account=rrg-bengioy-ad
#SBATCH --nodes=1
#SBATCH --gres=gpu:4
#SBATCH --mem=0
#SBATCH --time=15:00:00
#SBATCH --job-name=dpr_reader_training_nq
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/vaibhav/miniconda3/envs/DPR/lib

cd $HOME/DPR

python train_extractive_reader.py encoder.sequence_length=350 train_files=$SCRATCH/DPR-data/data/retriever_results/nq/single/train.json dev_files=$SCRATCH/DPR-data/data/retriever_results/nq/single/dev.json gold_passages_src=$SCRATCH/DPR-data/data/gold_passages_info/nq_train.json gold_passages_src_dev=$SCRATCH/DPR-data/data/gold_passages_info/nq_dev.json output_dir=$SCRATCH/DPR-data/new-checkpoints
