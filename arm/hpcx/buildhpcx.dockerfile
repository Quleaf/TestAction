FROM rockylinux/rockylinux:9.4

LABEL org.opencontainers.image.arch=arm
LABEL org.opencontainers.image.compilation=auto
LABEL org.opencontainers.image.author="Shusen Liu"
LABEL org.opencontainers.image.email="shusen.liu@pawsey.org.au|shusen.liu@csiro.au"
LABEL org.opencontainers.image.version="25-10-2024"
LABEL org.opencontainers.image.minversion="0.0.3"


# Set noninteractive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN dnf -y update && dnf install -y \
    gcc \
    gcc-c++ \
    make \
    wget \
    tar \
    ca-certificates \
    numactl \
    numactl-devel \
    hwloc \
    hwloc-devel \
    pciutils \
    rdma-core \
    rdma-core-devel \
    libibverbs-devel \  
    openssh-clients \
    chrpath \
    graphviz \
    lsof \
    tk \
    gcc-gfortran \
    libusb1 \
    kmod \
    pkgconfig \
    flex \
    tcl \
    bison \
    fuse-libs \
    perl \
    libmnl \
    ethtool\
    dnf-plugins-core \
    bzip2 \
    && dnf clean all

# Install MLNX OFED (user-space only)
# Set MLNX OFED version and download URL
ENV MLNX_OFED_VERSION=23.10-3.2.2.0
ENV MLNX_OFED_PACKAGE=MLNX_OFED_LINUX-${MLNX_OFED_VERSION}-rhel9.4-aarch64.tgz
ENV MLNX_OFED_DOWNLOAD_URL=https://content.mellanox.com/ofed/MLNX_OFED-${MLNX_OFED_VERSION}/${MLNX_OFED_PACKAGE}

# Download and extract MLNX OFED
RUN mkdir -p /tmp/MLNX_OFED && \
    cd /tmp && \
    wget ${MLNX_OFED_DOWNLOAD_URL} && \
    tar -xzf ${MLNX_OFED_PACKAGE} -C /tmp/MLNX_OFED --strip-components=1 && \
    rm ${MLNX_OFED_PACKAGE}

# Install MLNX OFED user-space components
RUN cd /tmp/MLNX_OFED/MLNX_OFED_LINUX-${MLNX_OFED_VERSION}-rhel9.4-aarch64 && \
    ./mlnxofedinstall --user-space-only --without-fw-update --all --force

# # Clean up MLNX OFED installation files
RUN rm -rf /tmp/MLNX_OFED

# # Install CUDA 12.6
# # Add NVIDIA's package repository and install CUDA Toolkit 12.6
RUN dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel9/sbsa/cuda-rhel9.repo && \
    dnf clean all && \   
    dnf -y install cuda-toolkit-12-6 && \
    dnf clean all

# # Set CUDA environment variables
ENV CUDA_HOME=/usr/local/cuda-12.6
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH
ENV PATH=${CUDA_HOME}/bin:$PATH

# # Set the HPC-X version and download URL
ENV HPCX_VERSION=v2.20
ENV HPCX_PACKAGE=hpcx-v2.20-gcc-mlnx_ofed-redhat9-cuda12-aarch64.tbz
ENV HPCX_DOWNLOAD_URL=https://content.mellanox.com/hpc/hpc-x/${HPCX_VERSION}/${HPCX_PACKAGE}

# # Download and extract HPC-X
RUN mkdir -p /opt && \
    cd /opt && \
    wget ${HPCX_DOWNLOAD_URL} && \
    tar -xvf $(basename ${HPCX_DOWNLOAD_URL}) && \
    rm $(basename ${HPCX_DOWNLOAD_URL}) && \
    mv hpcx-v2.20-gcc-mlnx_ofed-redhat9-cuda12-aarch64 hpcx &&\
    chmod o+w hpcx

# Set HPCX_HOME
# ENV HPCX_HOME=/opt/hpcx

# Set environment variables (adjusted to match your host configuration)
# ENV HPCX_DIR=${HPCX_HOME} \
#     HPCX_HOME=${HPCX_HOME} \
#     HPCX_UCX_DIR=${HPCX_HOME}/ucx \
#     HPCX_UCC_DIR=${HPCX_HOME}/ucc \
#     HPCX_SHARP_DIR=${HPCX_HOME}/sharp \
#     HPCX_HCOLL_DIR=${HPCX_HOME}/hcoll \
#     HPCX_NCCL_RDMA_SHARP_PLUGIN_DIR=${HPCX_HOME}/nccl_rdma_sharp_plugin \
#     HPCX_MPI_DIR=${HPCX_HOME}/ompi \
#     HPCX_OSHMEM_DIR=${HPCX_HOME}/ompi \
#     HPCX_MPI_TESTS_DIR=${HPCX_HOME}/ompi/tests \
#     HPCX_OSU_DIR=${HPCX_HOME}/ompi/tests/osu-micro-benchmarks \
#     HPCX_OSU_CUDA_DIR=${HPCX_HOME}/ompi/tests/osu-micro-benchmarks-cuda \
#     OPAL_PREFIX=${HPCX_HOME}/ompi \
#     # Del it later
#     PMIX_INSTALL_PREFIX=${HPCX_HOME}/ompi \  
#     OMPI_HOME=${HPCX_HOME}/ompi \
#     MPI_HOME=${HPCX_HOME}/ompi \
#     OSHMEM_HOME=${HPCX_HOME}/ompi \
#     SHMEM_HOME=${HPCX_HOME}/ompi

# Update PATH
# ENV PATH=${HPCX_UCX_DIR}/bin:${HPCX_UCC_DIR}/bin:${HPCX_HCOLL_DIR}/bin:${HPCX_SHARP_DIR}/bin:${HPCX_MPI_TESTS_DIR}/imb:${HPCX_HOME}/clusterkit/bin:${HPCX_MPI_DIR}/bin:$PATH

# # Update LD_LIBRARY_PATH
# ENV LD_LIBRARY_PATH=${HPCX_UCX_DIR}/lib:${HPCX_UCX_DIR}/lib/ucx:${HPCX_UCC_DIR}/lib:${HPCX_UCC_DIR}/lib/ucc:${HPCX_HCOLL_DIR}/lib:${HPCX_SHARP_DIR}/lib:${HPCX_NCCL_RDMA_SHARP_PLUGIN_DIR}/lib:${HPCX_MPI_DIR}/lib:$LD_LIBRARY_PATH

# # Update LIBRARY_PATH
# ENV LIBRARY_PATH=${HPCX_UCX_DIR}/lib:${HPCX_UCC_DIR}/lib:${HPCX_HCOLL_DIR}/lib:${HPCX_SHARP_DIR}/lib:${HPCX_NCCL_RDMA_SHARP_PLUGIN_DIR}/lib:$LIBRARY_PATH

# # Update CPATH
# ENV CPATH=${HPCX_HCOLL_DIR}/include:${HPCX_SHARP_DIR}/include:${HPCX_UCX_DIR}/include:${HPCX_UCC_DIR}/include:${HPCX_MPI_DIR}/include:$CPATH

# # Update PKG_CONFIG_PATH
# ENV PKG_CONFIG_PATH=${HPCX_HCOLL_DIR}/lib/pkgconfig:${HPCX_SHARP_DIR}/lib/pkgconfig:${HPCX_UCX_DIR}/lib/pkgconfig:${HPCX_MPI_DIR}/lib/pkgconfig:$PKG_CONFIG_PATH

# # Update MANPATH
# ENV MANPATH=${HPCX_MPI_DIR}/share/man:$MANPATH

# # Set working directory
# WORKDIR ${HPCX_HOME}

# # Compile the hello world example to verify installation
# RUN mpicc ${HPCX_MPI_TESTS_DIR}/examples/hello_c.c -o ${HPCX_MPI_TESTS_DIR}/examples/hello_c

# Optional: Set entrypoint to bash
CMD ["/bin/bash"]