
time=02:00:00
memory=250G

export SCRATCH=/miniscratch/vaibhav.adlakha

model_file=$SCRATCH"/DPR-data/checkpoint/reader/nq-single/hf-bert-base.cp"

for qa_dataset in ocoqa_test_t5_qrecc ocoqa_test_original ocoqa_test_all_history
do
    for corpus in dpr_corpus ocoqa_corpus
    do
        experiment_id=dpr_reader_inference_${qa_dataset}_${corpus}
        retriever_results_files=$SCRATCH"/DPR-data/new-results/ocoqa/inference_only/${qa_dataset}/${corpus}/retriever/results.json"
        results_file=$SCRATCH"/DPR-data/new-results/ocoqa/inference_only/${qa_dataset}/${corpus}/reader/results.json"

        if [ ! -f ${results_file} ]; then
            echo ${experiment_id}
            sbatch --time=${time} --mem=${memory} -J ${experiment_id} --gres=gpu:4 \
            --nodes=1 --cpus-per-task=40 \
            -o $SCRATCH"/DPR-data/new-results/logs/%x.%j.out" -e $SCRATCH"/DPR-data/new-results/logs/%x.%j.err" \
            _reader_inference_ocoqa.sh \
            ${results_file} ${retriever_results_files} ${model_file}
        fi
    done
done

model_file=$SCRATCH"/DPR-data/new-checkpoints/ocoqa/reader/dpr_extractive_reader.10.590"
qa_dataset=ocoqa_test_t5_qrecc
experiment_id=dpr_reader_inference_${qa_dataset}_trained
retriever_results_files=$SCRATCH"/DPR-data/new-results/ocoqa/t5_rewrites_qrecc_trained/retriever/${qa_dataset}_results.json"
results_file=$SCRATCH"/DPR-data/new-results/ocoqa/t5_rewrites_qrecc_trained/reader/${qa_dataset}_results.json"

if [ ! -f ${results_file} ]; then
    echo ${experiment_id}
    sbatch --time=${time} --mem=${memory} -J ${experiment_id} --gres=gpu:4 \
    --nodes=1 --cpus-per-task=40 \
    -o $SCRATCH"/DPR-data/new-results/logs/%x.%j.out" -e $SCRATCH"/DPR-data/new-results/logs/%x.%j.err" \
    _reader_inference_ocoqa.sh \
    ${results_file} ${retriever_results_files} ${model_file}
fi
