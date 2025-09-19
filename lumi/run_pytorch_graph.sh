#!/bin/bash

# This is identical to run_pytorch_rocm624.sh

# This script is meant to be executed within
# a singularity container where all the 
# needed packages are available through conda
#
# Example:
#
#   srun singularity exec -B ... run-pytorch.py

# Printing GPU information to terminal once
if [ $SLURM_LOCALID -eq 0 ] ; then
    rocm-smi --showtoponuma
    rocm-smi
fi
sleep 2

# MIOPEN needs some initialisation for the cache as the default location
# does not work on LUMI as Lustre does not provide the necessary features.
export MIOPEN_USER_DB_PATH="/tmp/$(whoami)-miopen-cache-$SLURM_NODEID"
export MIOPEN_CUSTOM_CACHE_DIR=$MIOPEN_USER_DB_PATH

# The OMP_NUM_THREADS environment variable sets the number of 
# threads to use for parallel regions by setting the 
# initial value of the nthreads-var ICV.
export OMP_NUM_THREADS=6

# Enables MPI to communicate with GPU
export MPICH_GPU_SUPPORT_ENABLED=1

if [ $SLURM_LOCALID -eq 0 ] ; then
    rm -rf $MIOPEN_USER_DB_PATH
    mkdir -p $MIOPEN_USER_DB_PATH
fi
sleep 2

# Intel libfabric essential for aws-ofi-rccl
# change cache monitoring method:
export FI_MR_CACHE_MONITOR=userfaultfd #memhooks #userfaultfd #memhooks
export FI_CXI_DISABLE_HOST_REGISTER=1


export NCCL_DEBUG=DEBUG #TRACE more detailed LOGS
export NCCL_DEBUG_SUBSYS=INIT,COLL

# Peer-to-peer communication i.e GPU-to-GPU communication
export NCCL_P2P_DISABLE=0

# Make NCCL use non-default connection.
# This utilizes the interconnect between the
# nodes and gpus. hsn0, hsn1, hsn2, hsn3 enables
# HPE Cray Slingshot-11 with 200Gbp network interconnect
export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3

# This ariable allows the user to finely control 
# when to use GPU Direct RDMA between a NIC and a GPU. 
# The level defines the maximum distance between the NIC and the GPU. 
# A string representing the path type should be 
# used to specify the topographical cutoff for GpuDirect.
export NCCL_NET_GDR_LEVEL=PHB 

#export NCCL_CROSS_NIC=1
#export NCCL_ALGO=RING
# The NCCL_BUFFSIZE variable controls the size of the 
# buffer used by NCCL when communicating data between pairs of GPUs.
export NCCL_BUFFSIZE=67108864 # 64mb buffsize
export NCCL_NTHREADS=1024

# Increasing the number of CUDA CTAs 
# per peer from 1 to 4 in NCCL send/recv operations 
# may/can improve performance in sparse communication patterns 
# set NCCL_NCHANNELS_PER_NET_PEER=4. Makes communication between
# more stable.
export NCCL_NCHANNELS_PER_NET_PEER=4

# Use CUDA cuMem* functions to allocate memory in NCCL.
export NCCL_CUMEM_ENABLE=1


# Report affinity to check
echo "Rank $SLURM_PROCID --> $(taskset -p $$); GPU $ROCR_VISIBLE_DEVICES"


get_master_node() {
    # Get the first item in the node list
    first_nodelist=$(echo $SLURM_NODELIST | cut -d',' -f1)

    if [[ "$first_nodelist" == *'['* ]]; then
        # Split the node list and extract the master node
        base_name=$(echo "$first_nodelist" | cut -d'[' -f1)
        range_part=$(echo "$first_nodelist" | cut -d'[' -f2 | cut -d'-' -f1)
        master_node="${base_name}${range_part}"
    else
        # If no range, the first node is the master node
        master_node="$first_nodelist"
    fi

    echo "$master_node"
}

# Pytorch (and lightning) setup 
# for distributed training
export MASTER_ADDR=$(get_master_node)
export MASTER_PORT=29500
export WORLD_SIZE=$SLURM_NPROCS
export RANK=$SLURM_PROCID

export HSA_FORCE_FINE_GRAIN_PCIE=1
export HYDRA_FULL_ERROR=1
export AIFS_BASE_SEED=1337420

export PYTHONUSERBASE=$VIRTUAL_ENV
export PATH=$PATH:$VIRTUAL_ENV/bin
anemoi-graphs create $1 $2 
