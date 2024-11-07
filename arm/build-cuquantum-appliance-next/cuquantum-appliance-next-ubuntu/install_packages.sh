#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# Update and install base packages
apt-get update -qq
apt-get install -y --no-install-recommends software-properties-common gpg-agent
add-apt-repository ppa:deadsnakes/ppa
apt-get update -qq

# Install development tools and libraries
# One part is basic tools and libraries, 
# the other part is for building and running the HPC-X
apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    libc-dev-bin \
    libc6 \
    libc-bin \
    libc-dev \
    libnuma-dev \
    lsof \
    coreutils \
    autoconf \
    automake \
    numactl \
    gnupg \
    bzip2 \
    file \
    perl \
    flex \
    tar \
    wget \
    git \
    sudo \
    curl \
    libtool \
    make \
    cmake \
    chrpath \
    openssh-server \
    openssh-client \
    vim \
    ninja-build \
    libblas-dev libopenblas-dev \
    libtbb-dev\
    python${PY_VERSION}-dev python${PY_VERSION}-distutils python${PY_VERSION}-full\
    gcc g++ gfortran \
    libhwloc-dev \
    lsb-release \
    pciutils \
    ibverbs-providers \
    libibverbs1 libibverbs-dev ibverbs-utils infiniband-diags perftest \
    rdma-core \
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


# add-apt-repository ppa:ubuntu-toolchain-r/test
# apt-get update -qq
# apt-get install -y --no-install-recommends gcc-13 g++-13 gfortran-13

# update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 
# update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 
# update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-13 100

# sudo add-apt-repository --remove ppa:ubuntu-toolchain-r/test

# Set Python and Pip
update-alternatives --install /usr/bin/python python /usr/bin/python${PY_VERSION} 1
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PY_VERSION} 1
curl https://bootstrap.pypa.io/get-pip.py | python -

# install CUDA 12.6 and cutensor
wget -q https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/sbsa/cuda-keyring_1.1-1_all.deb
dpkg -i cuda-keyring_1.1-1_all.deb
apt-get update
apt-get install -y cuda-toolkit-12-6=12.6.1-1 libcutensor2 libcutensor-dev libcutensor-doc
rm cuda-keyring_1.1-1_all.deb

python -m pip install nvidia-cuda-runtime-cu12 nvidia-nvjitlink-cu12 nvidia-cublas-cu12 nvidia-cusolver-cu12 nvidia-cusparse-cu12 pip-tools

# set CUDA 
export CUDA_HOME=/usr/local/cuda-12.6
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH
export PATH=${CUDA_HOME}/bin:$PATH

# set HPC-X download URL
export HPCX_VERSION=v2.20
export HPCX_PACKAGE=hpcx-v2.20-gcc-mlnx_ofed-ubuntu22.04-cuda12-aarch64.tbz
export HPCX_DOWNLOAD_URL=https://content.mellanox.com/hpc/hpc-x/${HPCX_VERSION}/${HPCX_PACKAGE}

# download and set HPC-X
mkdir -p /opt
cd /opt
wget -q ${HPCX_DOWNLOAD_URL}
tar -xf $(basename ${HPCX_DOWNLOAD_URL})
rm $(basename ${HPCX_DOWNLOAD_URL})
mv hpcx-v2.20-gcc-mlnx_ofed-ubuntu22.04-cuda12-aarch64 hpcx
chmod o+w hpcx

# Clean up
rm -rf /root/.cache/pip
apt-get clean
rm -rf /var/lib/apt/lists/*




