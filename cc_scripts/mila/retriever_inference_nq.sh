#!/bin/bash
#SBATCH --nodes=1
#SBATCH --gres=gpu:4
#SBATCH --mem=250G
#SBATCH --time=08:00:00
#SBATCH --job-name=dpr_retriever_inference_nq
#SBATCH --output=/miniscratch/vaibhav.adlakha/DPR-data/new-results/logs/%x-%j.out
#SBATCH --error=/miniscratch/vaibhav.adlakha/DPR-data/new-results/logs/%x-%j.err

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/mila/v/vaibhav.adlakha/miniconda3/envs/DPR/lib
export SCRATCH=/miniscratch/vaibhav.adlakha

cd $HOME/DPR

# HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
# python dense_retriever.py \
# model_file=$SCRATCH/DPR-data/new-checkpoints/dpr_biencoder.37 \
# qa_dataset=nq_train ctx_datatsets=[dpr_wiki] \
# encoded_ctx_files=[\"$SCRATCH/DPR-data/new-results/retriever_results/nq/single/wikipedia_passages_*\"] \
# out_file=$SCRATCH/DPR-data/new-results/nq/single/nq-train.json

HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
python dense_retriever.py \
model_file=$SCRATCH/DPR-data/new-checkpoints/nq/dpr_biencoder.37 \
qa_dataset=nq_dev ctx_datatsets=[dpr_wiki] \
encoded_ctx_files=[\"$SCRATCH/DPR-data/new-results/retriever_results/nq/single/wikipedia_passages_*\"] \
out_file=$SCRATCH/DPR-data/new-results/nq/single/nq-dev.json

HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
python dense_retriever.py \
model_file=$SCRATCH/DPR-data/new-checkpoints/nq/dpr_biencoder.37 \
qa_dataset=nq_test ctx_datatsets=[dpr_wiki] \
encoded_ctx_files=[\"$SCRATCH/DPR-data/new-results/retriever_results/nq/single/wikipedia_passages_*\"] \
out_file=$SCRATCH/DPR-data/new-results/nq/single/nq-test.json
