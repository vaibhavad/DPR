#!/bin/bash

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/mila/v/vaibhav.adlakha/miniconda3/envs/DPR/lib

cd $HOME/DPR

export TRANSFORMERS_CACHE=/miniscratch/vaibhav.adlakha/hf-models

HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
python dense_retriever.py \
model_file=$1 \
qa_dataset=$2 \
ctx_datatsets=$3 \
encoded_ctx_files=$4 \
out_file=$5
