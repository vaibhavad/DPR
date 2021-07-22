time_dev=02:00:00
time_train=02:00:00
memory=250G

export SCRATCH=/miniscratch/vaibhav.adlakha


for dataset in original all_history rewrites_t5_qrecc
do
    qa_dataset="ocoqa_test_${dataset}"
    model_file=$SCRATCH"/DPR-data/new-checkpoints/ocoqa/${dataset}/retriever/final_checkpoint"
    ctx_dataset="[dpr_wiki_ocoqa]"
    encoded_ctx_files="[\"$SCRATCH/DPR-data/new-results/retriever_results/ocoqa/trained/${dataset}/wikipedia_passages_*\"]"

    experiment_id=dpr_retriever_inference_ocoqa_${dataset}_test
    results_file=$SCRATCH"/DPR-data/new-results/ocoqa/trained/${dataset}/retriever/results_test.json"

    if [ ! -f ${results_file} ]; then
        echo ${experiment_id}
        sbatch --time=${time_dev} --mem=${memory} -J ${experiment_id} --gres=gpu:2 \
        --nodes=1 --cpus-per-task=40 \
        -o $SCRATCH"/DPR-data/new-results/logs/%x.%j.out" -e $SCRATCH"/DPR-data/new-results/logs/%x.%j.err" \
        _retriever_inference_ocoqa.sh \
        ${model_file} ${qa_dataset} ${ctx_dataset} ${encoded_ctx_files} ${results_file}
    fi

    qa_dataset="ocoqa_${dataset}"
    results_file=$SCRATCH"/DPR-data/new-results/ocoqa/trained/${dataset}/retriever/results_train.json"
    experiment_id=dpr_retriever_inference_ocoqa_${dataset}_train

    if [ ! -f ${results_file} ]; then
        echo ${experiment_id}
        sbatch --time=${time_train} --mem=${memory} -J ${experiment_id} --gres=gpu:4 \
        --nodes=1 --cpus-per-task=40 \
        -o $SCRATCH"/DPR-data/new-results/logs/%x.%j.out" -e $SCRATCH"/DPR-data/new-results/logs/%x.%j.err" \
        _retriever_inference_ocoqa.sh \
        ${model_file} ${qa_dataset} ${ctx_dataset} ${encoded_ctx_files} ${results_file}
    fi
done