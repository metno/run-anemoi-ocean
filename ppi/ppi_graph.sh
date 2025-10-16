#!/bin/bash
#$ -l h_rt=4:00:00
#$ -q research-r8.q
#$ -l h_rss=20G
#$ -pe shmem-1 4
#$ -l mem_free=20G 
#$ -l h_data=20G
#$ -o /lustre/storeB/project/fou/hi/foccus/ppi-experiments/planar-graph/run-anemoi-ocean/ppi/output/graph_o.$JOB_ID
#$ -e /lustre/storeB/project/fou/hi/foccus/ppi-experiments/planar-graph/run-anemoi-ocean/ppi/output/graph_e.$JOB_ID
#$ -wd /lustre/storeB/project/fou/hi/foccus/ppi-experiments/planar-graph/run-anemoi-ocean/ppi/

GRAPH_NAME=trim_edge_10_res_10_cutoff_06_max_num_neighbours_80_MaskedPlanarAreaWeights.pt

conda deactivate
VENV=/lustre/storeB/project/fou/hi/foccus/python-envs/anemoi-env-2-10-25/
source $VENV/bin/activate

CONFIG_DIR=$(pwd -P)/
CONFIG_NAME=$(pwd -P)/graph.yaml

export AIFS_BASE_SEED=1337420

anemoi-graphs create $CONFIG_NAME $GRAPH_NAME
