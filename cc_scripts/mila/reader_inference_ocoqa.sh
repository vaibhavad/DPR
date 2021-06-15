#!/bin/bash
#SBATCH --nodes=1
#SBATCH --gres=gpu:4
#SBATCH --mem=0
#SBATCH --cpus-per-task=40
#SBATCH --time=6:00:00
#SBATCH --job-name=dpr_reader_inference_ocoqa
#SBATCH --output=/miniscratch/vaibhav.adlakha/DPR-data/new-results/logs/%x-%j.out
#SBATCH --error=/miniscratch/vaibhav.adlakha/DPR-data/new-results/logs/%x-%j.err

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/mila/v/vaibhav.adlakha/miniconda3/envs/DPR/lib
export SCRATCH=/miniscratch/vaibhav.adlakha

cd $HOME/DPR

export TRANSFORMERS_CACHE=/miniscratch/vaibhav.adlakha/hf-models

HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 python train_extractive_reader.py prediction_results_file=$SCRATCH/DPR-data/new-results/nq/single/reader_ocoqa_t5_canard_wiki2.json eval_top_docs=[10,20,40,50,80,100] dev_files=$SCRATCH/DPR-data/new-results/nq/single/ocoqa_t5_canard_wiki2.json model_file=$SCRATCH/DPR-data/checkpoint/reader/nq-single/hf-bert-base.cp train.dev_batch_size=20 passages_per_question_predict=100 encoder.sequence_length=350
HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 python train_extractive_reader.py prediction_results_file=$SCRATCH/DPR-data/new-results/nq/single/reader_ocoqa_t5_qrecc_wiki2.json eval_top_docs=[10,20,40,50,80,100] dev_files=$SCRATCH/DPR-data/new-results/nq/single/ocoqa_t5_qrecc_wiki2.json model_file=$SCRATCH/DPR-data/checkpoint/reader/nq-single/hf-bert-base.cp train.dev_batch_size=20 passages_per_question_predict=100 encoder.sequence_length=350
