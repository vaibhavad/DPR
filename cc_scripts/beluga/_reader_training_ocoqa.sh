#!/bin/bash
#SBATCH --account=rrg-bengioy-ad

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/vaibhav/miniconda3/envs/DPR/lib

cd $HOME/DPR

export TRANSFORMERS_CACHE=/scratch/vaibhav/hf-models

HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
python train_extractive_reader.py \
encoder.sequence_length=350 \
train_files=$1 \
dev_files=$2 \
gold_passages_src=$3 \
gold_passages_src_dev=$4 \
output_dir=$5 \
train=extractive_reader_default_small
