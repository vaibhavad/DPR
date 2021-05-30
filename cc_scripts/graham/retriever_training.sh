#!/bin/bash
#SBATCH --account=rrg-bengioy-ad
#SBATCH --nodes=1
#SBATCH --gres=gpu:v100:8
#SBATCH --mem=127G
#SBATCH --time=20:00:00
#SBATCH --cpus-per-task=40
#SBATCH --job-name=dpr_train_dense_encoder_biencoder_nq_small
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/vaibhav/miniconda3/envs/DPR/lib

cd $HOME/DPR

python -m torch.distributed.launch --nproc_per_node=8 train_dense_encoder.py train_datasets=[nq_train] dev_datasets=[nq_dev] train=biencoder_nq_small output_dir=$SCRATCH/DPR-data/new-checkpoints
