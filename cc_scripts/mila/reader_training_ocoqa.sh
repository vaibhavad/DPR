#!/bin/bash
#SBATCH --nodes=1
#SBATCH --gres=gpu:32gb:8
#SBATCH --mem=0
#SBATCH --time=30:00:00
#SBATCH --job-name=dpr_train_reader_ocoqa
#SBATCH --output=/miniscratch/vaibhav.adlakha/DPR-data/new-results/logs/%x-%j.out
#SBATCH --error=/miniscratch/vaibhav.adlakha/DPR-data/new-results/logs/%x-%j.err

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/mila/v/vaibhav.adlakha/miniconda3/envs/DPR/lib
export SCRATCH=/miniscratch/vaibhav.adlakha

cd $HOME/DPR

export TRANSFORMERS_CACHE=/miniscratch/vaibhav.adlakha/hf-models

HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
python train_extractive_reader.py \
encoder.sequence_length=350 \
train_files=$SCRATCH/DPR-data/new-results/ocoqa/t5_rewrites_qrecc_trained/retriever/results.json \
dev_files=$SCRATCH/DPR-data/new-results/ocoqa/t5_rewrites_qrecc_trained/retriever/nq_dev_results.json \
gold_passages_src=$SCRATCH/DPR-data/data/gold_passages_info/ocoqa-rewrites-t5-qrecc.json \
gold_passages_src_dev=$SCRATCH/DPR-data/data/gold_passages_info/nq_dev.json \
output_dir=$SCRATCH/DPR-data/new-checkpoints/ocoqa/reader
