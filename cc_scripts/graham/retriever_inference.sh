#!/bin/bash
#SBATCH --account=rrg-bengioy-ad
#SBATCH --nodes=1
#SBATCH --gres=gpu:v100:8
#SBATCH --mem=127G
#SBATCH --time=20:00:00
#SBATCH --cpus-per-task=40
#SBATCH --job-name=dpr_train_dense_encoder_biencoder_nq_small
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/vaibhav/miniconda3/envs/DPR/lib

cd $HOME/DPR

python dense_retriever.py model_file=$SCRATCH/DPR-data/checkpoint/retriever/single/nq/bert-base-encoder.cp qa_dataset=nq_dev ctx_datatsets=[dpr_wiki] encoded_ctx_files=["~/scratch/DPR-data/data/retriever_results/nq/single/wikipedia_passages_*"] out_file=$SCRATCH/DPR-data/new-results/nq/single/dev.json
