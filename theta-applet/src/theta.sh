#!/bin/bash
set -e -x -o pipefail

main() {
    echo "Starting Docker service..."
    sudo systemctl start docker || {
        echo "Failed to start Docker service"
        sudo systemctl status docker
        exit 1
    }
    
    if ! docker info >/dev/null 2>&1; then
        echo "Docker daemon is not running"
        exit 1
    fi
    
    NUM_CORES=$(nproc)
    AVAILABLE_MEM=$(free -g | awk '/^Mem:/{print $2}')
    echo "Available resources: $NUM_CORES cores, ${AVAILABLE_MEM}GB memory"
    
    echo "Downloading input files..."
    dx-download-all-inputs
    
    mkdir -p "${output_dir:-theta_results}"
    
    # Fix double slash in paths and make them relative to /data mount point
    interval_file=$(echo "/data/in/interval_file/${interval_file_name}" | tr -s /)
    tumor_file=$(echo "/data/in/tumor_file/${tumor_file_name}" | tr -s /)
    
    # Create a log file to capture the output
    log_file="${output_dir:-theta_results}/theta.log"
    touch "$log_file"
    
    cmd="docker run --cpus=${NUM_CORES} --memory=${AVAILABLE_MEM}G -v /home/dnanexus:/data jbkirkland/theta:latest ${interval_file} --TUMOR_FILE ${tumor_file} --NUM_PROCESSES ${NUM_CORES} --DIR /data/${output_dir:-theta_results} --N 2 --FORCE"
    
    echo "Running command: $cmd"
    
    # Run the command and capture output to log file
    eval $cmd 2>&1 | tee "$log_file"
    
    # Results file
    results_file=$(ls ${output_dir:-theta_results}/*.results 2>/dev/null || true)
    if [ -z "$results_file" ]; then
        echo "No results file found"
        exit 1
    fi
    results_id=$(dx upload "$results_file" --brief)
    dx-jobutil-add-output results "$results_id" --class=file
    
    # Log file
    log_id=$(dx upload "$log_file" --brief)
    dx-jobutil-add-output log "$log_id" --class=file
    
    # Plots
    plot_files=$(ls ${output_dir:-theta_results}/*.png ${output_dir:-theta_results}/*.pdf 2>/dev/null || true)
    if [ -n "$plot_files" ]; then
        for plot in $plot_files; do
            plot_id=$(dx upload "$plot" --brief)
            dx-jobutil-add-output plots "$plot_id" --class=file
        done
    fi
} 