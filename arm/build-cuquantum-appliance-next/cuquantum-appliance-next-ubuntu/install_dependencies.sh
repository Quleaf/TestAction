#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive



sudo apt-get update
sudo apt-get install -y \    
    libhwloc-dev \
    lsb-release \
    pciutils \
    ibverbs-providers \
    libibverbs-dev \
    rdma-core \
    software-properties-common \    
    libgfortran5 \
    debhelper \
    graphviz \    
    tk \
    libusb-1.0-0 \
    kmod \
    swig \
    pkg-config \
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
sudo wget -q ${HPCX_DOWNLOAD_URL}
sudo tar -xvf $(basename ${HPCX_DOWNLOAD_URL})
sudo rm $(basename ${HPCX_DOWNLOAD_URL})
sudo mv hpcx-v2.20-gcc-mlnx_ofed-ubuntu22.04-cuda12-aarch64 hpcx
sudo chmod o+w hpcx

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*
