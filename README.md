# THetA DNAnexus Applet

This DNAnexus applet provides a containerized version of THetA (Tumor Heterogeneity Analysis) for estimating tumor purity and subclonal population frequencies from next-generation sequencing data.

## Overview

THetA is a tool for analyzing tumor heterogeneity using next-generation sequencing data. This applet provides a Docker-based implementation that can be run on the DNAnexus platform.

## Requirements

- DNAnexus account with appropriate permissions
- Docker image: jbkirkland/theta:latest

## Input Parameters

### Required
- `interval_count_file`: File containing interval counts

### Optional
- `normal_interval_count_file`: File containing normal interval counts
- `tumor_interval_count_file`: File containing tumor interval counts
- `tumor_allele_count_file`: File containing tumor allele counts
- `normal_allele_count_file`: File containing normal allele counts
- `num_chains`: Number of MCMC chains to run (default: 3)
- `num_chains_to_use`: Number of chains to use in the analysis (default: 3)
- `num_iterations`: Number of iterations per chain (default: 1000)
- `burn_in`: Number of burn-in iterations (default: 100)
- `max_solutions`: Maximum number of solutions to return (default: 100)

## Output

- `results`: Results file from THetA analysis (*.results)

## System Requirements

- Instance Type: azure:mem2_ssd1_x8
- Timeout: 48 hours

## Usage

The applet can be run using the DNAnexus command line tools:

```bash
dx run theta -iinterval_count_file=<file_id> [optional parameters]
```

## Docker Image

The applet uses the Docker image: jbkirkland/theta:latest

## License

[Add appropriate license information]
