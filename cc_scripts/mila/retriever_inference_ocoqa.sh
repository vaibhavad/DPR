time=01:00:00
memory=250G

export SCRATCH=/miniscratch/vaibhav.adlakha

model_file=$SCRATCH"/DPR-data/checkpoint/retriever/single/nq/bert-base-encoder.cp"

for qa_dataset in ocoqa_test_t5_qrecc ocoqa_test_original ocoqa_test_all_history
do

    ctx_dataset="[dpr_wiki]"
    encoded_ctx_files="[\"$SCRATCH/DPR-data/data/retriever_results/nq/single/wikipedia_passages_*\"]"

    experiment_id=dpr_retriever_inference_${qa_dataset}_dpr_corpus
    results_file=$SCRATCH"/DPR-data/new-results/ocoqa/inference_only/${qa_dataset}/dpr_corpus/retriever/results.json"

    if [ ! -f ${results_file} ]; then
        echo ${experiment_id}
        sbatch --time=${time} --mem=${memory} -J ${experiment_id} --gres=gpu:4 \
        --nodes=1 --cpus-per-task=40 \
        -o $SCRATCH"/DPR-data/new-results/logs/%x.%j.out" -e $SCRATCH"/DPR-data/new-results/logs/%x.%j.err" \
        _retriever_inference_ocoqa.sh \
        ${model_file} ${qa_dataset} ${ctx_dataset} ${encoded_ctx_files} ${results_file}
    fi

    ctx_dataset="[dpr_wiki_ocoqa]"
    encoded_ctx_files="[\"$SCRATCH/DPR-data/new-results/retriever_results/ocoqa/trained_on_nq/wikipedia_passages_*\"]"

    experiment_id=dpr_retriever_inference_${qa_dataset}_ocoqa_corpus
    results_file=$SCRATCH"/DPR-data/new-results/ocoqa/inference_only/${qa_dataset}/ocoqa_corpus/retriever/results.json"

    if [ ! -f ${results_file} ]; then
        echo ${experiment_id}
        sbatch --time=${time} --mem=${memory} -J ${experiment_id} --gres=gpu:4 \
        --nodes=1 --cpus-per-task=40 \
        -o $SCRATCH"/DPR-data/new-results/logs/%x.%j.out" -e $SCRATCH"/DPR-data/new-results/logs/%x.%j.err" \
        _retriever_inference_ocoqa.sh \
        ${model_file} ${qa_dataset} ${ctx_dataset} ${encoded_ctx_files} ${results_file}
    fi
done