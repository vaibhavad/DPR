time=18:00:00
memory=64G

export SCRATCH=/miniscratch/vaibhav.adlakha

for dataset in original all_history rewrites_t5_qrecc
do
    train_datasets=[ocoqa_train_${dataset}]
    dev_datasets=[ocoqa_test_${dataset}]
    output_dir=$SCRATCH/DPR-data/new-checkpoints/ocoqa/${dataset}/retriever

    experiment_id=dpr_retriever_training_ocoqa_${dataset}

    results_file=$SCRATCH/DPR-data/new-checkpoints/ocoqa/${dataset}/retriever/final_checkpoint
    if [ ! -f $results_file ]; then
        echo ${experiment_id}
        sbatch --time=${time} --mem=${memory} -J ${experiment_id} --gres=gpu:turing:48gb:2 \
        --cpus-per-task=20 \
        -o $SCRATCH"/DPR-data/new-results/logs/%x.%j.out" -e $SCRATCH"/DPR-data/new-results/logs/%x.%j.err" \
        _retriever_training_ocoqa.sh \
        ${train_datasets} ${dev_datasets} ${output_dir}
    fi
done
