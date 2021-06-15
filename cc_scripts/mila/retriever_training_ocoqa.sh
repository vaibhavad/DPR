#!/bin/bash
#SBATCH --nodes=1
#SBATCH --gres=gpu:32gb:8
#SBATCH --mem=0
#SBATCH --time=20:00:00
#SBATCH --job-name=dpr_train_dense_encoder_biencoder_ocoqa
#SBATCH --output=/miniscratch/vaibhav.adlakha/DPR-data/new-results/logs/%x-%j.out
#SBATCH --error=/miniscratch/vaibhav.adlakha/DPR-data/new-results/logs/%x-%j.err

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/mila/v/vaibhav.adlakha/miniconda3/envs/DPR/lib
export SCRATCH=/miniscratch/vaibhav.adlakha

cd $HOME/DPR

export TRANSFORMERS_CACHE=/miniscratch/vaibhav.adlakha/hf-models

HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
python -m torch.distributed.launch --nproc_per_node=8 \
train_dense_encoder.py \
train_datasets=[ocoqa_train] \
dev_datasets=[nq_dev] \
train=biencoder_nq output_dir=$SCRATCH/DPR-data/new-checkpoints/ocoqa/retriever
