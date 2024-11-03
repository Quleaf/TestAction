#!/bin/bash
set -e

# Update and install base packages
apt-get update -qq
apt-get install -y --no-install-recommends software-properties-common gpg-agent
add-apt-repository ppa:deadsnakes/ppa
add-apt-repository ppa:ubuntu-toolchain-r/test
apt-get update -qq

# Install development tools and libraries
apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    libc-dev-bin \
    libc6 \
    libc-bin \
    libnuma-dev \
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
    g++-13 \
    gfortran-13 \
    gcc-13 \
    wget \
    git \
    sudo \
    curl \
    libtool \
    make \
    cmake \
    openssh-server \
    vim \
    ninja-build \
    libblas-dev libopenblas-dev \
    libtbb-dev\
    python${PY_VERSION}-dev \
    python${PY_VERSION}-distutils \
    python${PY_VERSION}-full

# NVIDIA CUDA and associated packages
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/sbsa/cuda-keyring_1.1-1_all.deb
dpkg -i cuda-keyring_1.1-1_all.deb
apt-get update
apt-get install -y --no-install-recommends \
    cuda-command-line-tools-12-6=${NV_CUDA_LIB_VERSION} \
    cuda-minimal-build-12-6=${NV_CUDA_LIB_VERSION} \
    cuda-libraries-dev-12-6=${NV_CUDA_LIB_VERSION} \
    cuda-nvml-dev-12-6=${NV_NVML_DEV_VERSION} \
    cuda-libraries-dev-12-6=${NV_CUDA_LIB_VERSION} \
    libnpp-dev-12-6=12.3.1.54-1\
    libcusparse-dev-12-6\
    libcublas-dev-12-6=12.6.0.22-1 \
    libnccl-dev=2.23.4-1+cuda12.6 \
    cuda-nsight-compute-12-6=${NV_CUDA_LIB_VERSION}

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*


# Set Python and Pip
update-alternatives --install /usr/bin/python python /usr/bin/python${PY_VERSION} 1
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PY_VERSION} 1

curl https://bootstrap.pypa.io/get-pip.py | python -

python -m pip install --upgrade pip setuptools
python -m pip install nvidia-cuda-runtime-cu12 nvidia-nvjitlink-cu12 nvidia-cublas-cu12 nvidia-cusolver-cu12 nvidia-cusparse-cu12 pip-tools
rm -rf /root/.cache/pip