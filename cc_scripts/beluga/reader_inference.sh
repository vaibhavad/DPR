#!/bin/bash
#SBATCH --account=rrg-bengioy-ad
#SBATCH --nodes=1
#SBATCH --gres=gpu:4
#SBATCH --mem=0
#SBATCH --time=6:00:00
#SBATCH --job-name=dpr_retriever_inference_ocoqa
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

source activate DPR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/vaibhav/miniconda3/envs/DPR/lib

cd $HOME/DPR

export TRANSFORMERS_CACHE=/scratch/vaibhav/hf-models

# HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 python train_extractive_reader.py prediction_results_file=$SCRATCH/DPR-data/new-results/nq/single/reader_nq_dev.json eval_top_docs=[10,20,40,50,80,100] dev_files=$SCRATCH/DPR-data/new-results/nq/single/dev.json model_file=$SCRATCH/DPR-data/checkpoint/reader/nq-single/hf-bert-base.cp train.dev_batch_size=20 passages_per_question_predict=100 encoder.sequence_length=350

# HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 python train_extractive_reader.py prediction_results_file=$SCRATCH/DPR-data/new-results/nq/single/reader_nq_test.json eval_top_docs=[10,20,40,50,80,100] dev_files=$SCRATCH/DPR-data/new-results/nq/single/test.json model_file=$SCRATCH/DPR-data/checkpoint/reader/nq-single/hf-bert-base.cp train.dev_batch_size=20 passages_per_question_predict=100 encoder.sequence_length=350

# HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 python train_extractive_reader.py prediction_results_file=$SCRATCH/DPR-data/new-results/nq/single/reader_ocoqa.json eval_top_docs=[10,20,40,50,80,100] dev_files=$SCRATCH/DPR-data/new-results/nq/single/ocoqa.json model_file=$SCRATCH/DPR-data/checkpoint/reader/nq-single/hf-bert-base.cp train.dev_batch_size=20 passages_per_question_predict=100 encoder.sequence_length=350

# HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 python train_extractive_reader.py prediction_results_file=$SCRATCH/DPR-data/new-results/nq/single/reader_ocoqa_canard.json eval_top_docs=[10,20,40,50,80,100] dev_files=$SCRATCH/DPR-data/new-results/nq/single/ocoqa_canard.json model_file=$SCRATCH/DPR-data/checkpoint/reader/nq-single/hf-bert-base.cp train.dev_batch_size=20 passages_per_question_predict=100 encoder.sequence_length=350

# HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 python train_extractive_reader.py prediction_results_file=$SCRATCH/DPR-data/new-results/nq/single/reader_ocoqa_qrecc.json eval_top_docs=[10,20,40,50,80,100] dev_files=$SCRATCH/DPR-data/new-results/nq/single/ocoqa_qrecc.json model_file=$SCRATCH/DPR-data/checkpoint/reader/nq-single/hf-bert-base.cp train.dev_batch_size=20 passages_per_question_predict=100 encoder.sequence_length=350

HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 python train_extractive_reader.py prediction_results_file=$SCRATCH/DPR-data/new-results/nq/single/reader_ocoqa_t5_canard.json eval_top_docs=[10,20,40,50,80,100] dev_files=$SCRATCH/DPR-data/new-results/nq/single/ocoqa_t5_canard.json model_file=$SCRATCH/DPR-data/checkpoint/reader/nq-single/hf-bert-base.cp train.dev_batch_size=20 passages_per_question_predict=100 encoder.sequence_length=350

HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 python train_extractive_reader.py prediction_results_file=$SCRATCH/DPR-data/new-results/nq/single/reader_ocoqa_t5_qrecc.json eval_top_docs=[10,20,40,50,80,100] dev_files=$SCRATCH/DPR-data/new-results/nq/single/ocoqa_t5_qrecc.json model_file=$SCRATCH/DPR-data/checkpoint/reader/nq-single/hf-bert-base.cp train.dev_batch_size=20 passages_per_question_predict=100 encoder.sequence_length=350
