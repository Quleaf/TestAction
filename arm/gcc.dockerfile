FROM ubuntu:22.04

LABEL org.opencontainers.image.arch=arm
LABEL org.opencontainers.image.compilation=auto
LABEL org.opencontainers.image.devmode=true
LABEL org.opencontainers.image.ref.name="ubuntu"
LABEL org.opencontainers.image.version="22.04"
LABEL org.opencontainers.image.author="Shusen Liu"
LABEL org.opencontainers.image.version="04-11-2024"
LABEL org.opencontainers.image.minversion="0.1.5"
LABEL org.opencontainers.image.noscan=true

ARG PY_VERSION="3.12"
ARG CUDA_VERSION="12.6.0"

ENV DEBIAN_FRONTEND="noninteractive"
ENV NVARCH="sbsa"
ENV NVIDIA_REQUIRE_CUDA="cuda>=12.5"
ENV NV_CUDA_LIB_VERSION="12.6.0-1"
ENV NV_NVML_DEV_VERSION="12.6.37-1"
ENV NV_NVTX_VERSION="12.2.140-1"
ENV NV_LIBNPP_VERSION="12.2.1.4-1"
ENV NV_LIBNPP_PACKAGE="libnpp-12-2=12.2.1.4-1"
ENV NV_LIBCUSPARSE_VERSION="12.1.2.141-1"
ENV NV_LIBCUBLAS_PACKAGE_NAME="libcublas-12-2"
ENV NV_LIBCUBLAS_VERSION="12.2.5.6-1"
ENV NV_LIBCUBLAS_PACKAGE="libcublas-12-2=12.2.5.6-1"
ENV NV_LIBNCCL_PACKAGE_NAME="libnccl2"
ENV NV_LIBNCCL_PACKAGE_VERSION="2.19.3-1"
ENV NV_LIBNCCL_PACKAGE="libnccl2=2.19.3-1+cuda12.2"
ENV NCCL_VERSION="2.19.3-1"
ENV TERM="xterm-256color"
ENV PATH="/usr/local/cuda/bin:/usr/local/mpi/bin:/usr/local/ucx/bin:/usr/local/munge/bin:/usr/local/pmix/bin:/usr/local/slurm/bin:/usr/local/nvidia/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV CPATH="/usr/include:/usr/local/mpi/include:/usr/local/ucx/include:/usr/local/gdrcopy/include:/usr/local/munge/include:/usr/local/pmix/include:/usr/local/slurm/include"
ENV LD_LIBRARY_PATH="/usr/local/mpi/lib:/usr/local/ucx/lib:/usr/local/gdrcopy/lib:/usr/local/munge/lib:/usr/local/pmix/lib:/usr/local/slurm/lib:/usr/local/nvidia/lib:/opt/cuquantum/lib:/usr/local/nvidia/lib64"
ENV LIBRARY_PATH="/usr/lib:/usr/local/cuda/lib64/stubs"
ENV CUQUANTUM_ROOT="/opt/cuquantum"
ENV CUTENSORNET_COMM_LIB="/opt/cuquantum/distributed_interfaces/libcutensornet_distributed_mpi.so"


RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends software-properties-common gpg-agent && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update -qq && \
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
        libblas-dev \
        libopenblas-dev \
        libtbb-dev \
        python${PY_VERSION}-dev \
        python${PY_VERSION}-distutils \
        python${PY_VERSION}-full \
        gcc \
        g++ \
        gfortran && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python${PY_VERSION} 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PY_VERSION} 1 && \
    curl https://bootstrap.pypa.io/get-pip.py | python -
    