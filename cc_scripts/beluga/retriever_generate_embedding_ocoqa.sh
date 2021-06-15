for shard in {0..49}
do
    experiment_id=dpr-wiki-ocoqa-${shard}

    if [ ! -f $SCRATCH"/DPR-data/new-results/retriever_results/ocoqa/t5_rewrites_qrecc_trained/wikipedia_passages_${shard}.pkl" ]; then

        echo ${experiment_id}
        sbatch -J ${experiment_id} -o $SCRATCH"/DPR-data/new-results/logs/%x.%j.out" \
        -e $SCRATCH"/DPR-data/new-results/logs/%x.%j.err" _generate_embeddings_ocoqa.sh ${shard}
    fi
done