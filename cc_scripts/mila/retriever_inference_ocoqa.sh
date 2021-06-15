#!/bin/bash
#SBATCH --nodes=1
#SBATCH --gres=gpu:4
#SBATCH --mem=250G
#SBATCH --cpus-per-task=40
#SBATCH --time=6:00:00
#SBATCH --job-name=dpr_retriever_inference_ocoqa
#SBATCH --output=/miniscratch/vaibhav.adlakha/DPR-data/new-results/logs/%x-%j.out
#SBATCH --error=/miniscratch/vaibhav.adlakha/DPR-data/new-results/logs/%x-%j.err

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/mila/v/vaibhav.adlakha/miniconda3/envs/DPR/lib
export SCRATCH=/miniscratch/vaibhav.adlakha

cd $HOME/DPR

export TRANSFORMERS_CACHE=/miniscratch/vaibhav.adlakha/hf-models

HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
python dense_retriever.py \
model_file=$SCRATCH/DPR-data/new-checkpoints/ocoqa/retriever/dpr_biencoder.33 \
qa_dataset=ocoqa_train_t5_qrecc \
ctx_datatsets=[dpr_wiki_ocoqa] \
encoded_ctx_files=[\"$SCRATCH/DPR-data/new-results/retriever_results/ocoqa/t5_rewrites_qrecc_trained/wikipedia_passages_*\"] \
out_file=$SCRATCH/DPR-data/new-results/ocoqa/t5_rewrites_qrecc_trained/retriever/results.json

HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
python dense_retriever.py \
model_file=$SCRATCH/DPR-data/new-checkpoints/ocoqa/retriever/dpr_biencoder.33 \
qa_dataset=nq_dev \
ctx_datatsets=[dpr_wiki_ocoqa] \
encoded_ctx_files=[\"$SCRATCH/DPR-data/new-results/retriever_results/ocoqa/t5_rewrites_qrecc_trained/wikipedia_passages_*\"] \
out_file=$SCRATCH/DPR-data/new-results/ocoqa/t5_rewrites_qrecc_trained/retriever/nq_dev_results.json
