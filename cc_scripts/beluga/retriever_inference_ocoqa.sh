#!/bin/bash
#SBATCH --account=rrg-bengioy-ad
#SBATCH --nodes=1
#SBATCH --gres=gpu:4
#SBATCH --mem=0
#SBATCH --time=3:00:00
#SBATCH --job-name=dpr_retriever_inference_ocoqa
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/vaibhav/miniconda3/envs/DPR/lib

cd $HOME/DPR

export TRANSFORMERS_CACHE=/scratch/vaibhav/hf-models
# HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 python dense_retriever.py model_file=$SCRATCH/DPR-data/checkpoint/retriever/single/nq/bert-base-encoder.cp qa_dataset=ocoqa_qrecc ctx_datatsets=[dpr_wiki] encoded_ctx_files=[\"$SCRATCH/DPR-data/data/retriever_results/nq/single/wikipedia_passages_*\"] out_file=$SCRATCH/DPR-data/new-results/nq/single/ocoqa_qrecc.json
# HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 python dense_retriever.py model_file=$SCRATCH/DPR-data/checkpoint/retriever/single/nq/bert-base-encoder.cp qa_dataset=ocoqa_t5_canard ctx_datatsets=[dpr_wiki] encoded_ctx_files=[\"$SCRATCH/DPR-data/data/retriever_results/nq/single/wikipedia_passages_*\"] out_file=$SCRATCH/DPR-data/new-results/nq/single/ocoqa_t5_canard.json
# HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 python dense_retriever.py model_file=$SCRATCH/DPR-data/checkpoint/retriever/single/nq/bert-base-encoder.cp qa_dataset=ocoqa_t5_qrecc ctx_datatsets=[dpr_wiki] encoded_ctx_files=[\"$SCRATCH/DPR-data/data/retriever_results/nq/single/wikipedia_passages_*\"] out_file=$SCRATCH/DPR-data/new-results/nq/single/ocoqa_t5_qrecc.json

HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 python dense_retriever.py model_file=$SCRATCH/DPR-data/checkpoint/retriever/single/nq/bert-base-encoder.cp qa_dataset=ocoqa_t5_canard ctx_datatsets=[dpr_wiki_ocoqa] encoded_ctx_files=[\"$SCRATCH/DPR-data/new-results/retriever_results/ocoqa/wikipedia_passages_*\"] out_file=$SCRATCH/DPR-data/new-results/nq/single/ocoqa_t5_canard_wiki2.json
HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 python dense_retriever.py model_file=$SCRATCH/DPR-data/checkpoint/retriever/single/nq/bert-base-encoder.cp qa_dataset=ocoqa_t5_qrecc ctx_datatsets=[dpr_wiki_ocoqa] encoded_ctx_files=[\"$SCRATCH/DPR-data/new-results/retriever_results/ocoqa/wikipedia_passages_*\"] out_file=$SCRATCH/DPR-data/new-results/nq/single/ocoqa_t5_qrecc_wiki2.json