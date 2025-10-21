#!/bin/bash

submit_job() {
  sub="$(sbatch "$@")"

  if [[ "$sub" =~ Submitted\ batch\ job\ ([0-9]+) ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    exit 1
  fi
}

id1=$(submit_job infer_jobscript.sh)

id2=$(submit_job --dependency=afterany:$id1 postpro-inference_jobscript.sh)

