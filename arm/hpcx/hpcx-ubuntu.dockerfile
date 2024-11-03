FROM ubuntu:22.04
# This is a Dockerfile for building a container image for HPC-X on ARM architecture
# As MPI is used, we need to bind some folders from the host to the container.
# You do not need to source ./hpcx-mt-ompi and hpcx_load. All the valuable has been set in the env file.
# mpirun -np 4 singularity exec --nv \
#     -B /run/slurm:/run/slurm \
#     -B /etc/slurm:/etc/slurm \
#      -B /run/munge:/run/munge\
#        -B /software:/software\
#    --env-file hpcx-mt-ompi.env\
#     hpcx-ubuntu-arm.sif bash -c  "xxx"

LABEL org.opencontainers.image.arch=arm
LABEL org.opencontainers.image.compilation=auto
LABEL org.opencontainers.image.devmode=false
LABEL org.opencontainers.image.author="Shusen Liu"
LABEL org.opencontainers.image.version="04-11-2024"
LABEL org.opencontainers.image.minversion="0.0.1"

# Set noninteractive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
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
    openssh-client\
    chrpath libgfortran5 debhelper graphviz lsof tk gfortran libusb-1.0-0 kmod swig pkg-config flex tcl bison libfuse2 \
    && rm -rf /var/lib/apt/lists/*


# Add NVIDIA's package repository and install CUDA Toolkit 12.6
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/sbsa/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \   
    apt-get update && \
    apt-get install -y cuda-toolkit-12-6 && \
    rm -rf /var/lib/apt/lists/*

# Set CUDA environment variables
ENV CUDA_HOME=/usr/local/cuda-12.6
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH
ENV PATH=${CUDA_HOME}/bin:$PATH

# Set the HPC-X version and download URL
ENV HPCX_VERSION=v2.20
ENV HPCX_PACKAGE=hpcx-v2.20-gcc-mlnx_ofed-ubuntu22.04-cuda12-aarch64.tbz
ENV HPCX_DOWNLOAD_URL=https://content.mellanox.com/hpc/hpc-x/${HPCX_VERSION}/${HPCX_PACKAGE}

# Download and extract HPC-X
RUN mkdir -p /opt && \
    cd /opt && \
    wget ${HPCX_DOWNLOAD_URL} && \
    tar -xvf $(basename ${HPCX_DOWNLOAD_URL}) && \
    rm $(basename ${HPCX_DOWNLOAD_URL}) && \
    mv hpcx-v2.20-gcc-mlnx_ofed-ubuntu22.04-cuda12-aarch64 hpcx &&\
    chmod o+w hpcx

#Set HPCX_HOME
ENV HPCX_HOME=/opt/hpcx

#Set environment variables (adjusted to match your host configuration)
ENV HPCX_DIR=${HPCX_HOME} \
    HPCX_HOME=${HPCX_HOME} \
    HPCX_UCX_DIR=${HPCX_HOME}/ucx \
    HPCX_UCC_DIR=${HPCX_HOME}/ucc \
    HPCX_SHARP_DIR=${HPCX_HOME}/sharp \
    HPCX_HCOLL_DIR=${HPCX_HOME}/hcoll \
    HPCX_NCCL_RDMA_SHARP_PLUGIN_DIR=${HPCX_HOME}/nccl_rdma_sharp_plugin \
    HPCX_MPI_DIR=${HPCX_HOME}/ompi \
    HPCX_OSHMEM_DIR=${HPCX_HOME}/ompi \
    HPCX_MPI_TESTS_DIR=${HPCX_HOME}/ompi/tests \
    HPCX_OSU_DIR=${HPCX_HOME}/ompi/tests/osu-micro-benchmarks \
    HPCX_OSU_CUDA_DIR=${HPCX_HOME}/ompi/tests/osu-micro-benchmarks-cuda \
    OPAL_PREFIX=${HPCX_HOME}/ompi \
    # Del it later
    PMIX_INSTALL_PREFIX=${HPCX_HOME}/ompi \  
    OMPI_HOME=${HPCX_HOME}/ompi \
    MPI_HOME=${HPCX_HOME}/ompi \
    OSHMEM_HOME=${HPCX_HOME}/ompi \
    SHMEM_HOME=${HPCX_HOME}/ompi

#Update path. All of these paths would be rewritten in the singularity env file
ENV PATH=${HPCX_UCX_DIR}/bin:${HPCX_UCC_DIR}/bin:${HPCX_HCOLL_DIR}/bin:${HPCX_SHARP_DIR}/bin:${HPCX_MPI_TESTS_DIR}/imb:${HPCX_HOME}/clusterkit/bin:${HPCX_MPI_DIR}/bin:$PATH
ENV LD_LIBRARY_PATH=${HPCX_UCX_DIR}/lib:${HPCX_UCX_DIR}/lib/ucx:${HPCX_UCC_DIR}/lib:${HPCX_UCC_DIR}/lib/ucc:${HPCX_HCOLL_DIR}/lib:${HPCX_SHARP_DIR}/lib:${HPCX_NCCL_RDMA_SHARP_PLUGIN_DIR}/lib:${HPCX_MPI_DIR}/lib:$LD_LIBRARY_PATH
ENV LIBRARY_PATH=${HPCX_UCX_DIR}/lib:${HPCX_UCC_DIR}/lib:${HPCX_HCOLL_DIR}/lib:${HPCX_SHARP_DIR}/lib:${HPCX_NCCL_RDMA_SHARP_PLUGIN_DIR}/lib:$LIBRARY_PATH
ENV CPATH=${HPCX_HCOLL_DIR}/include:${HPCX_SHARP_DIR}/include:${HPCX_UCX_DIR}/include:${HPCX_UCC_DIR}/include:${HPCX_MPI_DIR}/include:$CPATH
ENV PKG_CONFIG_PATH=${HPCX_HCOLL_DIR}/lib/pkgconfig:${HPCX_SHARP_DIR}/lib/pkgconfig:${HPCX_UCX_DIR}/lib/pkgconfig:${HPCX_MPI_DIR}/lib/pkgconfig:$PKG_CONFIG_PATH
ENV MANPATH=${HPCX_MPI_DIR}/share/man:$MANPATH

# Set working directory
WORKDIR ${HPCX_HOME}

# Copy the Dockerfile and environment files for Ella to the container
# For reference, we copy all the dockerfiles in this topic to the container
RUN mkdir -p /opt/docker-recipes/
COPY *.dockerfile /opt/docker-recipes/
COPY *.env /opt/docker-recipes/

# Optional: Set entrypoint to bash
CMD ["/bin/bash"]