time=30:00:00
memory=64G
cpus_per_task=16

for dataset in original all_history rewrites_t5_qrecc
do
    train_files=$SCRATCH"/DPR-data/new-results/ocoqa/trained/${dataset}/retriever/results_train.json"
    dev_files=$SCRATCH"/DPR-data/new-results/ocoqa/trained/${dataset}/retriever/results_test.json"
    output_dir=$SCRATCH"/DPR-data/new-checkpoints/ocoqa/${dataset}/reader"
    experiment_id=dpr_reader_training_ocoqa_${dataset}_small_memory
    echo ${experiment_id}
    sbatch --time=${time} --mem=${memory} -J ${experiment_id} --gres=gpu:4 \
    --cpus-per-task=${cpus_per_task} \
    -o $SCRATCH"/DPR-data/new-results/logs/%x.%j.out" -e $SCRATCH"/DPR-data/new-results/logs/%x.%j.err" \
    _reader_training_ocoqa.sh \
    ${train_files} ${dev_files} ${gold_passages_src} ${gold_passages_src_dev} ${output_dir}
done
