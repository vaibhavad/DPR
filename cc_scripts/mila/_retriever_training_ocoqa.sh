#!/bin/bash

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/mila/v/vaibhav.adlakha/miniconda3/envs/DPR/lib

cd $HOME/DPR

export TRANSFORMERS_CACHE=/miniscratch/vaibhav.adlakha/hf-models

HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
python -m torch.distributed.launch --nproc_per_node=2 \
train_dense_encoder.py \
train_datasets=$1 \
dev_datasets=$2 \
train=biencoder_ocoqa \
output_dir=$3
