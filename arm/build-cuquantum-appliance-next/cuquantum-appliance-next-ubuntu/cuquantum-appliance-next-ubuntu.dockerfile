FROM ubuntu:22.04

LABEL org.opencontainers.image.arch=arm
LABEL org.opencontainers.image.compilation=auto
LABEL org.opencontainers.image.devmode=true
LABEL org.opencontainers.image.ref.name="ubuntu"
LABEL org.opencontainers.image.version="22.04"
LABEL org.opencontainers.image.author="Shusen Liu"
LABEL org.opencontainers.image.version="04-11-2024"
LABEL org.opencontainers.image.minversion="0.1.1"

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
ENV CPATH="/usr/local/mpi/include:/usr/local/ucx/include:/usr/local/gdrcopy/include:/usr/local/munge/include:/usr/local/pmix/include:/usr/local/slurm/include"
ENV LD_LIBRARY_PATH="/usr/local/mpi/lib:/usr/local/ucx/lib:/usr/local/gdrcopy/lib:/usr/local/munge/lib:/usr/local/pmix/lib:/usr/local/slurm/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64"
ENV LIBRARY_PATH="/usr/local/cuda/lib64/stubs"
ENV CUQUANTUM_ROOT="/opt/cuquantum"
ENV CUTENSORNET_COMM_LIB="/opt/cuquantum/distributed_interfaces/libcutensornet_distributed_mpi.so"


# Copy the install script
COPY install_packages.sh /opt/aptscript/install_packages.sh
RUN chmod +x /opt/aptscript/install_packages.sh && /bin/bash -c "/opt/aptscript/install_packages.sh"

# Install GDRCopy
RUN mkdir -p /var/tmp && cd /var/tmp && \
    wget --no-check-certificate https://github.com/NVIDIA/gdrcopy/archive/refs/tags/v2.4.1.tar.gz && \
    tar -xvf /var/tmp/v2.4.1.tar.gz && \
    rm -rf /var/tmp/v2.4.1.tar.gz && \
    cd /var/tmp/gdrcopy-2.4.1 && \
    make prefix=/usr/gdrcopy-2.4.1 lib lib_install && \
    ldconfig && \
    cd && rm -rf /var/tmp/* && \
    update-alternatives --install /usr/local/gdrcopy gdrcopy /usr/gdrcopy-2.4.1 100

# Install Munge
RUN export DEBIAN_FRONTEND="noninteractive" && \
    apt-get update && \
    apt-get install --yes --no-install-recommends libgcrypt20-dev && \
    rm -rf /var/lib/apt/lists/* && \
    unset DEBIAN_FRONTEND && \
    mkdir -p /var/tmp && cd /var/tmp && \
    wget --no-check-certificate https://github.com/dun/munge/releases/download/munge-0.5.15/munge-0.5.15.tar.xz && \
    tar -xvf /var/tmp/munge-0.5.15.tar.xz && \
    rm -rf /var/tmp/munge-0.5.15.tar.xz && \
    cd /var/tmp/munge-0.5.15 && \
    ./configure --prefix=/usr/munge-0.5.15 && \
    make -j && make -j install && \
    cd && rm -rf /var/tmp/* && \
    update-alternatives --install /usr/local/munge munge /usr/munge-0.5.15 100

# Install PMIx
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update --yes && \
    apt-get install --yes --no-install-recommends libhwloc-dev libevent-dev && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/tmp && cd /var/tmp && \
    wget --no-check-certificate https://github.com/openpmix/openpmix/releases/download/v3.2.3/pmix-3.2.3.tar.gz && \
    tar -xvf /var/tmp/pmix-3.2.3.tar.gz && \
    rm -rf /var/tmp/pmix-3.2.3.tar.gz && \
    cd /var/tmp/pmix-3.2.3 && \
    ./configure --with-munge=/usr/local/munge --prefix=/usr/pmix-3.2.3 && \
    make -j && make -j install && \
    cd && rm -rf /var/tmp/* && \
    unset DEBIAN_FRONTEND && \
    update-alternatives --install /usr/local/pmix pmix /usr/pmix-3.2.3 100

# Install Slurm
RUN export DEBIAN_FRONTEND=noninteractive && \
    mkdir -p /var/tmp && cd /var/tmp && \
    wget --no-check-certificate https://download.schedmd.com/slurm/slurm-23.11.1.tar.bz2 && \
    tar -xvf /var/tmp/slurm-23.11.1.tar.bz2 && \
    rm -rf /var/tmp/slurm-23.11.1.tar.bz2 && \
    cd /var/tmp/slurm-23.11.1 && \
    ./configure --with-pmix=/usr/local/pmix --with-munge=/usr/local/munge --prefix=/usr/slurm-23.11.1 && \
    make -j && make -j install && \
    cd /var/tmp/slurm-23.11.1/contribs/pmi2 && \
    make -j && make -j install && \
    cd && rm -rf /var/tmp/* && \
    update-alternatives --install /usr/local/slurm slurm /usr/slurm-23.11.1 100

COPY install_dependencies.sh /opt/aptscript/install_dependencies.sh
RUN chmod +x  /opt/aptscript/install_dependencies.sh &&  /bin/bash -c "/opt/aptscript/install_dependencies.sh"

# HPCX related paths are set only for further complation of MPI
# Execution of MPI applications relys on the env file of singularity
ENV HPCX_HOME=/opt/hpcx 
ENV HPCX_DIR=${HPCX_HOME} \
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
    PMIX_INSTALL_PREFIX=${HPCX_HOME}/ompi \
    OMPI_HOME=${HPCX_HOME}/ompi \
    MPI_HOME=${HPCX_HOME}/ompi \
    OSHMEM_HOME=${HPCX_HOME}/ompi \
    SHMEM_HOME=${HPCX_HOME}/ompi

# Update PATH
ENV PATH=${HPCX_UCX_DIR}/bin:${HPCX_UCC_DIR}/bin:${HPCX_HCOLL_DIR}/bin:${HPCX_SHARP_DIR}/bin:${HPCX_MPI_TESTS_DIR}/imb:${HPCX_HOME}/clusterkit/bin:${HPCX_MPI_DIR}/bin:$PATH
ENV LD_LIBRARY_PATH=${HPCX_UCX_DIR}/lib:${HPCX_UCX_DIR}/lib/ucx:${HPCX_UCC_DIR}/lib:${HPCX_UCC_DIR}/lib/ucc:${HPCX_HCOLL_DIR}/lib:${HPCX_SHARP_DIR}/lib:${HPCX_NCCL_RDMA_SHARP_PLUGIN_DIR}/lib:${HPCX_MPI_DIR}/lib:$LD_LIBRARY_PATH
ENV LIBRARY_PATH=${HPCX_UCX_DIR}/lib:${HPCX_UCC_DIR}/lib:${HPCX_HCOLL_DIR}/lib:${HPCX_SHARP_DIR}/lib:${HPCX_NCCL_RDMA_SHARP_PLUGIN_DIR}/lib:$LIBRARY_PATH
ENV CPATH=${HPCX_HCOLL_DIR}/include:${HPCX_SHARP_DIR}/include:${HPCX_UCX_DIR}/include:${HPCX_UCC_DIR}/include:${HPCX_MPI_DIR}/include:$CPATH
ENV PKG_CONFIG_PATH=${HPCX_HCOLL_DIR}/lib/pkgconfig:${HPCX_SHARP_DIR}/lib/pkgconfig:${HPCX_UCX_DIR}/lib/pkgconfig:${HPCX_MPI_DIR}/lib/pkgconfig:$PKG_CONFIG_PATH
ENV MANPATH=${HPCX_MPI_DIR}/share/man:$MANPATH  

# Create a symbolic link to the OpenMPI installation
RUN /bin/bash -c ' \
    base_path=$(ls -d /opt/hpcx/ompi 2>/dev/null | head -n 1) && \
    if [ -z "$base_path" ]; then \
        echo "Error: No OpenMPI installation found in /opt/hpcx/ompi/" && \
        exit 1; \
    fi && \
    echo "Using OpenMPI base path: $base_path" && \
    for package in openmpi; do \
        for target in bin lib include; do \
            src_path="${base_path}/${target}" && \
            dest_path="/usr/${package}/${target}" && \
            if [ -d "${src_path}" ]; then \
                mkdir -p "${dest_path}" && \
                for file in "${src_path}"/*; do \
                    if [ -f "${file}" ] || [ -L "${file}" ]; then \
                        ln -s "${file}" "${dest_path}/$(basename "${file}")"; \
                    fi; \
                done; \
            fi; \
        done; \
    done && \
    update-alternatives --install /usr/local/mpi mpi /usr/openmpi 100 '

RUN mkdir -p /opt/qiskit
COPY qiskit_aer-0.15.0-cp312-cp312-linux_aarch64.whl /opt/qiskit

# Install cutensor
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -y install libcutensor2 libcutensor-dev libcutensor-doc &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install cuQuantum binary without examples
RUN wget https://developer.download.nvidia.com/compute/cuquantum/redist/cuquantum/linux-sbsa/cuquantum-linux-sbsa-24.08.0.5_cuda12-archive.tar.xz \
    && mkdir -p /opt/cuquantum \
    && chmod -R 755 /opt/cuquantum \
    && tar -xvf cuquantum-linux-sbsa-24.08.0.5_cuda12-archive.tar.xz -C /opt/cuquantum --strip-components=1 \
    && rm cuquantum-linux-sbsa-24.08.0.5_cuda12-archive.tar.xz \
    && cd /opt/cuquantum/distributed_interfaces \
    && sh activate_mpi.sh
# Check the folder structure of cuquantum

# download cuQuantum source code
RUN wget https://github.com/NVIDIA/cuQuantum/archive/refs/tags/v24.08.0.tar.gz &&\
    mkdir -p /opt/cuquantum-source &&\
    tar -xvf v24.08.0.tar.gz -C /opt/cuquantum-source --strip-components=1 &&\
    rm v24.08.0.tar.gz 

# Install cuQuantum python package
RUN python -m venv --system-site-packages /opt/cuquantum-source/cuquantum-env && \
    chmod -R a+rwX /opt/cuquantum-source/cuquantum-env &&\
    . /opt/cuquantum-source/cuquantum-env/bin/activate &&\
    pip install --upgrade pip && \
    pip install 'cryptography~=43.0' 'setuptools' 'urllib3==1.26.5' 'packaging'\
     'httpx' 'wheel' 'mpmath==1.3.0' 'pyjwt==2.4.0' 'Cython>=0.29.22,<3' 'numpy'\
     'cupy-cuda12x' 'nbformat' 'pytest' \
     'mpi4py' &&\
    pip install /opt/qiskit/qiskit_aer-0.15.0-cp312-cp312-linux_aarch64.whl &&\
    cd /opt/cuquantum-source/python &&\
    pip install -v --no-deps --no-build-isolation . &&\
    rm -rf /root/.cache/pip

# Create symbolic links for cutensor and cuquantum libraries, from /opt/cuquantum to /opt/cuquantum-source/cuquantum-env
RUN ln -s /opt/cuquantum/lib/libcustatevec.so.1 /opt/cuquantum-source/cuquantum-env/lib/libcustatevec.so.1 &&\
    ln -s /opt/cuquantum/lib/libcustatevec.so.1 /opt/cuquantum-source/cuquantum-env/lib/libcustatevec.so &&\
    ln -s /opt/cuquantum/lib/libcutensornet.so.2 /opt/cuquantum-source/cuquantum-env/lib/libcutensornet.so.2 &&\
    ln -s /opt/cuquantum/lib/libcutensornet.so.2 /opt/cuquantum-source/cuquantum-env/lib/libcutensornet.so 
    

# Prepare activation script
RUN echo '#!/bin/bash' > /opt/cuquantum-env/activate_cuquantum.sh && \
    echo '. /opt/cuquantum-env/bin/activate' >> /opt/cuquantum-env/activate_cuquantum.sh && \
    echo 'export CUDA_PATH=/usr/local/cuda' >> /opt/cuquantum-env/activate_cuquantum.sh && \
    echo 'export BASE_LD_LIBRARY_PATH=${LD_LIBRARY_PATH}' >> /opt/cuquantum-env/activate_cuquantum.sh && \
    echo 'export BASE_LD_PRELOAD=${LD_PRELOAD}' >> /opt/cuquantum-env/activate_cuquantum.sh && \
    echo 'export LD_LIBRARY_PATH=/opt/cuquantum-env/lib:${LD_LIBRARY_PATH}' >> /opt/cuquantum-env/activate_cuquantum.sh && \
    echo 'export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgomp.so.1:${LD_PRELOAD}' >> /opt/cuquantum-env/activate_cuquantum.sh && \
    echo 'export CUQUANTUM_ROOT=/opt/cuquantum'>> /opt/cuquantum-env/activate_cuquantum.sh && \
    echo 'export CUTENSOR_ROOT=/opt/cuquantum'>> /opt/cuquantum-env/activate_cuquantum.sh && \
#    echo 'export MPI_PATH=/usr/local/mpi' >> /opt/cuquantum-env/activate_cuquantum.sh && \
#   for cutensornet samples require MPI_ROOT   
#    echo 'export MPI_ROOT=/usr/local/mpi' >> /opt/cuquantum-env/activate_cuquantum.sh && \
#    echo 'export PATH=/usr/local/cuda/bin:/usr/local/mpi/bin:/usr/local/ucx/bin:/usr/local/munge/bin:/usr/local/pmix/bin:/usr/local/slurm/bin:/usr/local/nvidia/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cuquantum/bin' >> /opt/cuquantum-env/activate_cuquantum.sh && \
    chmod +x /opt/cuquantum-env/activate_cuquantum.sh






# Configure deactivate script
RUN echo '#!/bin/bash' > /opt/cuquantum-env/deactivate_cuquantum.sh && \
    echo 'export LD_LIBRARY_PATH=${BASE_LD_LIBRARY_PATH}' >> /opt/cuquantum-env/deactivate_cuquantum.sh && \
    echo 'export LD_PRELOAD=${BASE_LD_PRELOAD}' >> /opt/cuquantum-env/deactivate_cuquantum.sh && \
    echo 'unset BASE_LD_LIBRARY_PATH' >> /opt/cuquantum-env/deactivate_cuquantum.sh && \
    echo 'unset BASE_LD_PRELOAD' >> /opt/cuquantum-env/deactivate_cuquantum.sh && \
    chmod +x /opt/cuquantum-env/deactivate_cuquantum.sh

# Set entrypoint to activate the environment on container start
# ENTRYPOINT ["/opt/cuquantum-env/activate_cuquantum.sh"]