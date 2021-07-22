time=30:00:00
memory=0

export SCRATCH=/miniscratch/vaibhav.adlakha

for dataset in original all_history rewrites_t5_qrecc
do
    train_files=$SCRATCH"/DPR-data/new-results/ocoqa/trained/${dataset}/retriever/results_train.json"
    dev_files=$SCRATCH"/DPR-data/new-results/ocoqa/trained/${dataset}/retriever/results_test.json"
    gold_passages_src=$SCRATCH"/DPR-data/data/gold_passages_info/ocoqa-${dataset//[_]/-}.json"
    gold_passages_src_dev=$SCRATCH"/DPR-data/data/gold_passages_info/ocoqa-${dataset//[_]/-}-test.json"
    output_dir=$SCRATCH"/DPR-data/new-checkpoints/ocoqa/${dataset}/reader"
    experiment_id=dpr_reader_training_ocoqa_${dataset}
    echo ${experiment_id}
    sbatch --time=${time} --mem=${memory} -J ${experiment_id} --gres=gpu:32gb:8 \
    --nodes=1 --cpus-per-task=40 \
    -o $SCRATCH"/DPR-data/new-results/logs/%x.%j.out" -e $SCRATCH"/DPR-data/new-results/logs/%x.%j.err" \
    _reader_training_ocoqa.sh \
    ${train_files} ${dev_files} ${gold_passages_src} ${gold_passages_src_dev} ${output_dir}
done



# source activate DPR

# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/mila/v/vaibhav.adlakha/miniconda3/envs/DPR/lib
# export SCRATCH=/miniscratch/vaibhav.adlakha

# cd $HOME/DPR

# export TRANSFORMERS_CACHE=/miniscratch/vaibhav.adlakha/hf-models

# HF_DATASETS_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
# python train_extractive_reader.py \
# encoder.sequence_length=350 \
# train_files=$SCRATCH/DPR-data/new-results/ocoqa/t5_rewrites_qrecc_trained/retriever/results.json \
# dev_files=$SCRATCH/DPR-data/new-results/ocoqa/t5_rewrites_qrecc_trained/retriever/nq_dev_results.json \
# gold_passages_src=$SCRATCH/DPR-data/data/gold_passages_info/ocoqa-rewrites-t5-qrecc.json \
# gold_passages_src_dev=$SCRATCH/DPR-data/data/gold_passages_info/nq_dev.json \
# output_dir=$SCRATCH/DPR-data/new-checkpoints/ocoqa/reader
