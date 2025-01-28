PROJECT_DIR=/pfs/lustrep2/scratch/$SLURM_JOB_ACCOUNT
CONTAINER_SCRIPT=/pfs/lustrep2/projappl/$SLURM_JOB_ACCOUNT/ina/ocean-ai/run-pytorch.sh

#CHANGE THESE:
CONTAINER=$PROJECT_DIR/container/ocean-ai.sif

module load LUMI/24.03 partition/G

export SINGULARITYENV_LD_LIBRARY_PATH=/opt/ompi/lib:${EBROOTAWSMINOFIMINRCCL}/lib:/opt/cray/xpmem/2.4.4-2.3_9.1__gff0e1d9.shasta/lib64:${SINGULARITYENV_LD_LIBRARY_PATH}

# MPI + OpenMP bindings: https://docs.lumi-supercomputer.eu/runjobs/scheduled-jobs/distribution-binding
CPU_BIND="mask_cpu:fe000000000000,fe00000000000000,fe0000,fe000000,fe,fe00,fe00000000,fe0000000000"

# run run-pytorch.sh in singularity container like recommended
# in LUMI doc: https://lumi-supercomputer.github.io/LUMI-EasyBuild-docs/p/PyTorch
#srun --cpu-bind=$CPU_BIND \ # TODO: Use cpu bind later!
srun \
    singularity exec -B /pfs:/pfs \
                     -B /var/spool/slurmd \
                     -B /opt/cray \
                     -B /usr/lib64 \
                     -B /scratch/project_465001629 \
                     -B /projappl/project_465001629 \
         $CONTAINER $CONTAINER_SCRIPT {} {}
