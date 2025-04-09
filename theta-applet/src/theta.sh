#!/bin/bash

main() {
    # Get number of available cores
    NUM_CORES=$(nproc)
    
    # Download all input files at once
    dx-download-all-inputs
    
    # Build command with required parameters
    cmd="docker run --cpus=${NUM_CORES} --memory=$(free -g | awk '/^Mem:/{print $2}')G -v ${PWD}:/data jbkirkland/theta:latest bin/RunTHetA /data/interval_count_file"
    
    # Add optional parameters if provided
    if [ ! -z "$normal_interval_count_file" ]; then
        cmd="$cmd --NORMAL_FILE /data/normal_interval_count_file"
    fi
    
    if [ ! -z "$tumor_interval_count_file" ]; then
        cmd="$cmd --TUMOR_FILE /data/tumor_interval_count_file"
    fi
    
    if [ ! -z "$tumor_allele_count_file" ]; then
        cmd="$cmd --TUMOR_ALLELE_COUNT_FILE /data/tumor_allele_count_file"
    fi
    
    if [ ! -z "$normal_allele_count_file" ]; then
        cmd="$cmd --NORMAL_ALLELE_COUNT_FILE /data/normal_allele_count_file"
    fi
    
    # Add optional parameters with defaults
    cmd="$cmd --NUM_CHAINS ${num_chains:-${NUM_CORES}}"
    cmd="$cmd --NUM_CHAINS_TO_USE ${num_chains_to_use:-${NUM_CORES}}"
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