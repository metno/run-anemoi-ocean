#!/bin/bash

# Submit as 'bash lumi_infer.sh'

submit_job() {
  sub="$(sbatch "$@")"

  if [[ "$sub" =~ Submitted\ batch\ job\ ([0-9]+) ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    exit 1
  fi
}

id1=$(submit_job infer_jobscript.sh)
echo "inference job ID: ${id1}"

id2=$(submit_job --dependency=afterany:$id1 postpro-inference_jobscript.sh)
echo "postpro job ID: ${id2}"
