#!/bin/bash
#SBATCH --account=rrg-bengioy-ad
#SBATCH --nodes=1
#SBATCH --gres=gpu:4
#SBATCH --mem=0
#SBATCH --time=30:00:00
#SBATCH --job-name=dpr_train_dense_encoder_biencoder_nq_small
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/vaibhav/miniconda3/envs/DPR/lib

cd $HOME/DPR

python -m torch.distributed.launch --nproc_per_node=4 train_dense_encoder.py train_datasets=[nq_train] dev_datasets=[nq_dev] train=biencoder_nq_small output_dir=$SCRATCH/DPR-data/new-checkpoints
