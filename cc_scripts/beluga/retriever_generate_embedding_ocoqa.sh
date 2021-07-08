for dataset in original all_history rewrites_t5_qrecc
do
    for shard in {0..49}
    do
        experiment_id=dpr-wiki-ocoqa-${dataset}-${shard}

        if [ ! -f $SCRATCH"/DPR-data/new-results/retriever_results/ocoqa/trained/${dataset}/wikipedia_passages_${shard}.pkl" ]; then

            checkpoint=$SCRATCH"/DPR-data/new-checkpoints/ocoqa/${dataset}/retriever/final_checkpoint"
            out_file=$SCRATCH"/DPR-data/new-results/retriever_results/ocoqa/trained/${dataset}/wikipedia_passages"
            echo ${experiment_id}
            sbatch -J ${experiment_id} -o $SCRATCH"/DPR-data/new-results/logs/%x.%j.out" \
            -e $SCRATCH"/DPR-data/new-results/logs/%x.%j.err" _generate_embeddings_ocoqa.sh ${shard} ${checkpoint} ${out_file}
        fi
    done
done