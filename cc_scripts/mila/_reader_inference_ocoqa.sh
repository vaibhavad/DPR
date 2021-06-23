#!/bin/bash

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/mila/v/vaibhav.adlakha/miniconda3/envs/DPR/lib

cd $HOME/DPR

export TRANSFORMERS_CACHE=/miniscratch/vaibhav.adlakha/hf-models

HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
python train_extractive_reader.py \
prediction_results_file=$1 \
eval_top_docs=[10,20,40,50,80,100] \
dev_files=$2 \
model_file=$3 \
train.dev_batch_size=20 passages_per_question_predict=100 \
encoder.sequence_length=350
