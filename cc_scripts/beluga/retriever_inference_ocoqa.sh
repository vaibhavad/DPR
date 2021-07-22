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

dataset=rewrites_t5_qrecc
qa_dataset="ocoqa_test_${dataset}"
model_file=$SCRATCH"/DPR-data/new-checkpoints/ocoqa/${dataset}/retriever/final_checkpoint"
ctx_dataset="[dpr_wiki_ocoqa]"
encoded_ctx_files="[\"$SCRATCH/DPR-data/new-results/retriever_results/ocoqa/trained/${dataset}/wikipedia_passages_*\"]"
experiment_id=dpr_retriever_inference_ocoqa_${dataset}_test
results_file=$SCRATCH"/DPR-data/new-results/ocoqa/trained/${dataset}/retriever/results_test.json"

HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
python dense_retriever.py \
model_file=${model_file} \
qa_dataset=${qa_dataset} \
ctx_datatsets=${ctx_dataset} \
encoded_ctx_files=${encoded_ctx_files} \
out_file=${results_file}
