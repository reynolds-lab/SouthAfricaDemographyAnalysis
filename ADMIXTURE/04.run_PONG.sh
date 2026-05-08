for i in {1..10}; do 
    rm -rf /share/hennlab/projects/admixture/RG${i}_admixture/*results
    for x in {4..10}; do
        pong -m /share/hennlab/projects/admixture/RG${i}_admixture/filemap_k${x} \
            -i /share/hennlab/projects/admixture/ind2_pop.RG${i}.txt \
            -n /share/hennlab/projects/admixture/pop_order2 \
            -l /share/hennlab/projects/admixture/colors \
            --disable_server \
            -o /share/hennlab/projects/admixture/RG${i}_admixture/RG${i}_k${x}_results
    done
    echo "done with RG${i}"
done


# for i in {1..10}; do 
#     for x in {4..6}; do
#         cat RG${i}_admixture/RG${i}_k${x}_results/result_summary.txt >> k${x}_major_modes.txt
#         grep "CV error (K=" slurm-61988802_* >> CV_error.txt
#     done
# done
