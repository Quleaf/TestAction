#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y \
    build-essential \
    wget \
    tar \
    ca-certificates \
    numactl \
    libnuma-dev \
    libhwloc-dev \
    gcc \
    g++ \
    make \
    lsb-release \
    pciutils \
    ibverbs-providers \
    libibverbs-dev \
    rdma-core \
    software-properties-common \
    openssh-client \
    chrpath \
    libgfortran5 \
    debhelper \
    graphviz \
    lsof \
    tk \
    gfortran \
    libusb-1.0-0 \
    kmod \
    swig \
    pkg-config \
    flex \
    tcl \
    bison \
    libfuse2

# install CUDA 12.6
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/sbsa/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get install -y cuda-toolkit-12-6
rm cuda-keyring_1.1-1_all.deb

# set CUDA 
export CUDA_HOME=/usr/local/cuda-12.6
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH
export PATH=${CUDA_HOME}/bin:$PATH

# set HPC-X download URL
export HPCX_VERSION=v2.20
export HPCX_PACKAGE=hpcx-v2.20-gcc-mlnx_ofed-ubuntu22.04-cuda12-aarch64.tbz
export HPCX_DOWNLOAD_URL=https://content.mellanox.com/hpc/hpc-x/${HPCX_VERSION}/${HPCX_PACKAGE}

# download and set HPC-X
sudo mkdir -p /opt
cd /opt
sudo wget ${HPCX_DOWNLOAD_URL}
sudo tar -xvf $(basename ${HPCX_DOWNLOAD_URL})
sudo rm $(basename ${HPCX_DOWNLOAD_URL})
sudo mv hpcx-v2.20-gcc-mlnx_ofed-ubuntu22.04-cuda12-aarch64 hpcx
sudo chmod o+w hpcx

# set HPCX_HOME
export HPCX_HOME=/opt/hpcx

# set other related environment variables
export HPCX_DIR=${HPCX_HOME}
export HPCX_UCX_DIR=${HPCX_HOME}/ucx
export HPCX_UCC_DIR=${HPCX_HOME}/ucc
export HPCX_SHARP_DIR=${HPCX_HOME}/sharp
export HPCX_HCOLL_DIR=${HPCX_HOME}/hcoll
export HPCX_NCCL_RDMA_SHARP_PLUGIN_DIR=${HPCX_HOME}/nccl_rdma_sharp_plugin
export HPCX_MPI_DIR=${HPCX_HOME}/ompi
export HPCX_OSHMEM_DIR=${HPCX_HOME}/ompi
export HPCX_MPI_TESTS_DIR=${HPCX_HOME}/ompi/tests
export HPCX_OSU_DIR=${HPCX_HOME}/ompi/tests/osu-micro-benchmarks
export HPCX_OSU_CUDA_DIR=${HPCX_HOME}/ompi/tests/osu-micro-benchmarks-cuda
export OPAL_PREFIX=${HPCX_HOME}/ompi
export PMIX_INSTALL_PREFIX=${HPCX_HOME}/ompi  # 以后可删除
export OMPI_HOME=${HPCX_HOME}/ompi
export MPI_HOME=${HPCX_HOME}/ompi
export OSHMEM_HOME=${HPCX_HOME}/ompi
export SHMEM_HOME=${HPCX_HOME}/ompi

# update PATH
export PATH=${HPCX_UCX_DIR}/bin:${HPCX_UCC_DIR}/bin:${HPCX_HCOLL_DIR}/bin:${HPCX_SHARP_DIR}/bin:${HPCX_MPI_TESTS_DIR}/imb:${HPCX_HOME}/clusterkit/bin:${HPCX_MPI_DIR}/bin:$PATH

# update LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${HPCX_UCX_DIR}/lib:${HPCX_UCX_DIR}/lib/ucx:${HPCX_UCC_DIR}/lib:${HPCX_UCC_DIR}/lib/ucc:${HPCX_HCOLL_DIR}/lib:${HPCX_SHARP_DIR}/lib:${HPCX_NCCL_RDMA_SHARP_PLUGIN_DIR}/lib:${HPCX_MPI_DIR}/lib:$LD_LIBRARY_PATH

# update LIBRARY_PATH
export LIBRARY_PATH=${HPCX_UCX_DIR}/lib:${HPCX_UCC_DIR}/lib:${HPCX_HCOLL_DIR}/lib:${HPCX_SHARP_DIR}/lib:${HPCX_NCCL_RDMA_SHARP_PLUGIN_DIR}/lib:$LIBRARY_PATH

# update CPATH
export CPATH=${HPCX_HCOLL_DIR}/include:${HPCX_SHARP_DIR}/include:${HPCX_UCX_DIR}/include:${HPCX_UCC_DIR}/include:${HPCX_MPI_DIR}/include:$CPATH

# update PKG_CONFIG_PATH
export PKG_CONFIG_PATH=${HPCX_HCOLL_DIR}/lib/pkgconfig:${HPCX_SHARP_DIR}/lib/pkgconfig:${HPCX_UCX_DIR}/lib/pkgconfig:${HPCX_MPI_DIR}/lib/pkgconfig:$PKG_CONFIG_PATH

# update MANPATH
export MANPATH=${HPCX_MPI_DIR}/share/man:$MANPATH

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*
