#!/bin/bash

main() {
    # Download input files
    dx download "$interval_count_file" -o interval_count_file
    
    # Build command with required parameters
    cmd="docker run -v /home/dnanexus:/data jbkirkland/theta:latest bin/RunTHetA /data/interval_count_file"
    
    # Add optional parameters if provided
    if [ ! -z "$normal_interval_count_file" ]; then
        dx download "$normal_interval_count_file" -o normal_interval_count_file
        cmd="$cmd --NORMAL_FILE /data/normal_interval_count_file"
    fi
    
    if [ ! -z "$tumor_interval_count_file" ]; then
        dx download "$tumor_interval_count_file" -o tumor_interval_count_file
        cmd="$cmd --TUMOR_FILE /data/tumor_interval_count_file"
    fi
    
    if [ ! -z "$tumor_allele_count_file" ]; then
        dx download "$tumor_allele_count_file" -o tumor_allele_count_file
        cmd="$cmd --TUMOR_ALLELE_COUNT_FILE /data/tumor_allele_count_file"
    fi
    
    if [ ! -z "$normal_allele_count_file" ]; then
        dx download "$normal_allele_count_file" -o normal_allele_count_file
        cmd="$cmd --NORMAL_ALLELE_COUNT_FILE /data/normal_allele_count_file"
    fi
    
    # Add optional parameters with defaults
    cmd="$cmd --NUM_CHAINS ${num_chains:-3}"
    cmd="$cmd --NUM_CHAINS_TO_USE ${num_chains_to_use:-3}"
    cmd="$cmd --NUM_ITERATIONS ${num_iterations:-1000}"
    cmd="$cmd --BURN_IN ${burn_in:-100}"
    cmd="$cmd --MAX_SOLUTIONS ${max_solutions:-100}"
    
    # Execute the command
    eval $cmd
    
    # Upload results
    results_file=$(ls *.results)
    if [ -z "$results_file" ]; then
        echo "No results file found"
        exit 1
    fi
    
    results_id=$(dx upload "$results_file" --brief)
    dx-jobutil-add-output results "$results_id" --class=file
} 