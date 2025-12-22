# Best command to rsync experiments from LUMI to PPI

1) Do a cleanup on LUMI (remove checkpoints except `*last.ckpt`, see `checkpoint-cleanup.sh`)
2) rsync to PPI (command below)
3) On PPI: Move important experiments to `archive` and make symlink in experiment dir

## About the rsync command
**NOTE: using the -a option gives an error since the group names and permissions on PPI are not identical to LUMI.**
However, we may still perserve file & dir times if we add these options
`--no-group --no-perms`
 
`rsync -av --progress --no-group --no-perms -e 'ssh -i /home/inkul7832/.ssh/id_rsa_lumi' --exclude={'anemoi-core','anemoi-datasets','anemoi-utils','anemoi-inference','anemoi-transform','.venv','.git'} kullmann@lumi.csc.fi:/scratch/project_465002266/experiments/* . `

### Other tricks/options:
* `--exclude={}` : to ignore file patterns
* `--dry-run` : to just see the list of files transferred, but dont transfer anything
* `--checksum` : by default rsync checks size of file and modification times,
             -->adding this option forces rsync to check that the checksums are identical
             for each file, slowing down transfer
* `--ignore-existing` : if a file name exists, rsync will skip it (without checking size & mod. time)
