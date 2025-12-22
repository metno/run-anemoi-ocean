#!/bin/bash

# List all checkpoint directories so you dont have to look for 
# e.g. /somepath/checkpoint/3d817bfbea9948cca870d206eb37f64a

OUTFILE=/scratch/project_465001902/experiments/checkpoint_dirs.txt
echo "Writing checkpoint directories to $OUTFILE"

find /scratch/project_465001902/experiments/*/checkpoint/* -type d > $OUTFILE
find /scratch/project_465001902/experiments/*/*/checkpoint/* -type d >> $OUTFILE

