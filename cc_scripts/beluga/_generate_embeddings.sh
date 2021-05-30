#!/bin/bash
#SBATCH --account=rrg-bengioy-ad
#SBATCH --gres=gpu:2
#SBATCH --mem=64G
#SBATCH --time=1:00:00

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/vaibhav/miniconda3/envs/DPR/lib

cd $HOME/DPR

export TRANSFORMERS_CACHE=/scratch/vaibhav/hf-models
HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
python generate_dense_embeddings.py \
model_file=$SCRATCH/DPR-data/checkpoint/retriever/single/nq/bert-base-encoder.cp \
ctx_src=dpr_wiki shard_id=$1 \
num_shards=50 \
out_file=$SCRATCH/DPR-data/new-results/retriever_results/nq/single/wikipedia_passages \
batch_size=128
