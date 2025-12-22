#!/bin/bash

# Script to remove all checkpoint files except the last one,
# but ignoring all files in certain directories.
# The script asks for confirmation before deleting files.
#
# Usage: 
# 1) you need the file checkpoint_dirs.txt or generate it below
# 2) update the list of experiments to keep below

######################
# List of experiments to keep (e.g. not delete anything from)
EXPERIMENT_KEEP=(
  "num_channels"
  "learning_rate"
  # Add more directories to ignore as needed
)

######################
# Get the checkpoint dirs (checkpoint_dirs.txt):
#./list_checkpoints.sh # uncomment if have the list already
# read dirs from file:
CHECKPOINT_DIRS=()
while IFS= read -r line; do
  CHECKPOINT_DIRS+=("$line")
done < /scratch/project_465001902/experiments/checkpoint_dirs.txt
#echo "${CHECKPOINT_DIRS[@]}"
echo "Number of checkpoint dirs: ${#CHECKPOINT_DIRS[@]}"

######################
# Function to check if a directory is in the ignore list for experiments
is_ignored() {
  local dir="$1"
  for ignore in "${EXPERIMENT_KEEP[@]}"; do
    if [[ "$dir" == *"$ignore"* ]]; then
      return 0
    fi
  done
  return 1
}

# Iterate over checkpoint directories
counter=1
for dir in "${CHECKPOINT_DIRS[@]}"; do
  echo "[$counter/${#CHECKPOINT_DIRS[@]}]"
  if is_ignored "$dir"; then
    echo " !! Skipping ignored directory: $dir"
    ((counter++))
    continue
  fi
  # Ask the user for confirmation before deleting files
  echo " Processing directory: $dir"
  read -p " Remove all checkpoints except *last.ckpt? (y/n): " answer
  if [[ "$answer" == "y" ]]; then
    find "$dir" -type f ! -name '*last.ckpt' -exec rm -v {} \;
    #find "$dir" -type f ! -name '*last.ckpt' -exec ls {} \;
  else
    echo " !! Skipped $dir"
  fi
  ((counter++))
done
######################

