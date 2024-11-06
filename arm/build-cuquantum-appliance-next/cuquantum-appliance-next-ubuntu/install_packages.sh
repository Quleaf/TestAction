#!/bin/bash
set -e

# Update and install base packages
apt-get update -qq
apt-get install -y --no-install-recommends software-properties-common gpg-agent
add-apt-repository ppa:deadsnakes/ppa
apt-get update -qq

# Install development tools and libraries
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
    python${PY_VERSION}-dev \
    python${PY_VERSION}-distutils \
    python${PY_VERSION}-full\
    gcc g++ gfortran 

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

# install CUDA 12.6
wget -q https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/sbsa/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get install -y cuda-toolkit-12-6=12.6.1-1
rm cuda-keyring_1.1-1_all.deb

python -m pip install nvidia-cuda-runtime-cu12 nvidia-nvjitlink-cu12 nvidia-cublas-cu12 nvidia-cusolver-cu12 nvidia-cusparse-cu12 pip-tools

# Clean up
rm -rf /root/.cache/pip
apt-get clean
rm -rf /var/lib/apt/lists/*




