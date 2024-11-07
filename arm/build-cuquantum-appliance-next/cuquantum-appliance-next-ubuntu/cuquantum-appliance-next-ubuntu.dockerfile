FROM ubuntu:22.04

LABEL org.opencontainers.image.arch=arm
LABEL org.opencontainers.image.compilation=auto
LABEL org.opencontainers.image.devmode=false
LABEL org.opencontainers.image.ref.name="ubuntu"
LABEL org.opencontainers.image.version="22.04"
LABEL org.opencontainers.image.author="Shusen Liu"
LABEL org.opencontainers.image.version="08-11-2024"
LABEL org.opencontainers.image.minversion="0.1.6"
LABEL org.opencontainers.image.noscan=true

ARG PY_VERSION="3.12"
ARG CUDA_VERSION="12.6.0"

# Set default environment variables
ENV DEBIAN_FRONTEND="noninteractive"
ENV PATH="/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV CPATH="/usr/include"
ENV LD_LIBRARY_PATH="/usr/lib64:/usr/lib"
ENV LIBRARY_PATH="/usr/lib:/usr/local/cuda/lib64/stubs"

# Copy the install script
COPY install_packages.sh /opt/aptscript/install_packages.sh
RUN chmod +x /opt/aptscript/install_packages.sh && /bin/bash -c "/opt/aptscript/install_packages.sh"

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
    SHMEM_HOME=${HPCX_HOME}/ompi \
    MPI_PATH=${HPCX_HOME}/ompi

# Update PATH
ENV CUDA_HOME=/usr/local/cuda
ENV CUDA_PATH=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${HPCX_UCX_DIR}/bin:${HPCX_UCC_DIR}/bin:${HPCX_HCOLL_DIR}/bin:${HPCX_SHARP_DIR}/bin:${HPCX_MPI_TESTS_DIR}/imb:${HPCX_HOME}/clusterkit/bin:${HPCX_MPI_DIR}/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu:${CUDA_HOME}/lib64:/usr/lib64:${HPCX_UCX_DIR}/lib:${HPCX_UCX_DIR}/lib/ucx:${HPCX_UCC_DIR}/lib:${HPCX_UCC_DIR}/lib/ucc:${HPCX_HCOLL_DIR}/lib:${HPCX_SHARP_DIR}/lib:${HPCX_NCCL_RDMA_SHARP_PLUGIN_DIR}/lib:${HPCX_MPI_DIR}/lib:$LD_LIBRARY_PATH
ENV LIBRARY_PATH=$/usr/lib/aarch64-linux-gnu:${CUDA_HOME}/lib64:/usr/lib64:{HPCX_UCX_DIR}/lib:${HPCX_UCC_DIR}/lib:${HPCX_HCOLL_DIR}/lib:${HPCX_SHARP_DIR}/lib:${HPCX_NCCL_RDMA_SHARP_PLUGIN_DIR}/lib:$LIBRARY_PATH
ENV CPATH=/usr/local/cuda/include:${HPCX_HCOLL_DIR}/include:${HPCX_SHARP_DIR}/include:${HPCX_UCX_DIR}/include:${HPCX_UCC_DIR}/include:${HPCX_MPI_DIR}/include:$CPATH
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

# Install cuQuantum binary without examples
RUN wget -q https://developer.download.nvidia.com/compute/cuquantum/redist/cuquantum/linux-sbsa/cuquantum-linux-sbsa-24.08.0.5_cuda12-archive.tar.xz \
    && mkdir -p /opt/cuquantum \
    && chmod -R 755 /opt/cuquantum \
    && tar -xf cuquantum-linux-sbsa-24.08.0.5_cuda12-archive.tar.xz -C /opt/cuquantum --strip-components=1 \
    && rm cuquantum-linux-sbsa-24.08.0.5_cuda12-archive.tar.xz \
    && cd /opt/cuquantum/distributed_interfaces \
    && sh activate_mpi.sh

ENV LD_LIBRARY_PATH=/opt/cuquantum/lib:${LD_LIBRARY_PATH}
ENV CUQUANTUM_ROOT="/opt/cuquantum"
ENV CUTENSORNET_COMM_LIB="/opt/cuquantum/distributed_interfaces/libcutensornet_distributed_mpi.so"

# download cuQuantum source code
RUN wget -q https://github.com/NVIDIA/cuQuantum/archive/refs/tags/v24.08.0.tar.gz &&\
    mkdir -p /opt/cuquantum-source &&\
    tar -xf v24.08.0.tar.gz -C /opt/cuquantum-source --strip-components=1 &&\
    rm v24.08.0.tar.gz 

# Install cuQuantum python package
RUN python -m venv --system-site-packages /opt/cuquantum-source/cuquantum-env && \
    chmod -R a+rwX /opt/cuquantum-source/cuquantum-env &&\
    . /opt/cuquantum-source/cuquantum-env/bin/activate &&\
    pip install --upgrade pip && \
    pip install 'cryptography~=43.0' 'setuptools' 'urllib3==1.26.5' 'packaging'\
     'httpx' 'wheel' 'mpmath==1.3.0' 'pyjwt==2.4.0' 'Cython>=0.29.22,<3' 'numpy'\
     'cupy-cuda12x' 'nbformat' 'pytest' &&\
    rm -rf /root/.cache/pip

# create mpi.cfg 
RUN mkdir -p /opt/mpicfg &&\
    echo "[openmpi]" > /opt/mpicfg/mpi.cfg && \
    echo "mpi_dir = /opt/hpcx/ompi" >> /opt/mpicfg/mpi.cfg && \
    echo "mpicc   = %(mpi_dir)s/bin/mpicc" >> /opt/mpicfg/mpi.cfg && \
    echo "mpicxx  = %(mpi_dir)s/bin/mpicxx" >> /opt/mpicfg/mpi.cfg

ENV MPI4PY_BUILD_MPICFG=/opt/mpicfg/mpi.cfg

RUN . /opt/cuquantum-source/cuquantum-env/bin/activate &&\
    pip install 'mpi4py' &&\
    pip install /opt/qiskit/qiskit_aer-0.15.0-cp312-cp312-linux_aarch64.whl &&\
    cd /opt/cuquantum-source/python &&\
    pip install -v --no-deps --no-build-isolation . &&\
    rm -rf /root/.cache/pip

# Create symbolic links for cutensor and cuquantum libraries, from /opt/cuquantum to /opt/cuquantum-source/cuquantum-env
RUN ln -s /opt/cuquantum/lib/libcustatevec.so.1 /opt/cuquantum-source/cuquantum-env/lib/libcustatevec.so.1 &&\
    ln -s /opt/cuquantum/lib/libcustatevec.so.1 /opt/cuquantum-source/cuquantum-env/lib/libcustatevec.so &&\
    ln -s /opt/cuquantum/lib/libcutensornet.so.2 /opt/cuquantum-source/cuquantum-env/lib/libcutensornet.so.2 &&\
    ln -s /opt/cuquantum/lib/libcutensornet.so.2 /opt/cuquantum-source/cuquantum-env/lib/libcutensornet.so 

ENV LD_LIBRARY_PATH=/opt/cuquantum-source/cuquantum-env/lib:${LD_LIBRARY_PATH}
    
# Prepare activation script
RUN echo '#!/bin/bash' > /opt/cuquantum-source/cuquantum-env/activate_cuquantum.sh && \
    echo '. /opt/cuquantum-source/cuquantum-env/bin/activate' >> /opt/cuquantum-source/cuquantum-env/activate_cuquantum.sh && \
    echo 'export CUDA_PATH=/usr/local/cuda' >> /opt/cuquantum-source/cuquantum-env/activate_cuquantum.sh && \
    echo 'export CUDA_HOME=/usr/local/cuda' >> /opt/cuquantum-source/cuquantum-env/activate_cuquantum.sh && \
    echo 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}' >> /opt/cuquantum-source/cuquantum-env/activate_cuquantum.sh && \
    echo 'export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgomp.so.1' >> /opt/cuquantum-source/cuquantum-env/activate_cuquantum.sh && \
    echo 'export CUQUANTUM_ROOT=/opt/cuquantum'>> /opt/cuquantum-source/cuquantum-env/activate_cuquantum.sh && \
    echo 'export CUTENSOR_ROOT=/opt/cuquantum'>> /opt/cuquantum-source/cuquantum-env/activate_cuquantum.sh && \
    echo 'export MPI_PATH=${MPI_PATH}' >> /opt/cuquantum-source/cuquantum-env/activate_cuquantum.sh && \
#   for cutensornet samples require MPI_ROOT   
    echo 'export MPI_ROOT=${MPI_PATH}' >> /opt/cuquantum-source/cuquantum-env/activate_cuquantum.sh && \
    echo 'export PATH=${PATH}' >> /opt/cuquantum-source/cuquantum-env/activate_cuquantum.sh && \
    chmod +x /opt/cuquantum-source/cuquantum-env/activate_cuquantum.sh


# Copy the Dockerfile and environment files for Ella to the container
# For reference, we copy all the dockerfiles in this topic to the container
RUN mkdir -p /opt/docker-recipes
COPY *.dockerfile /opt/docker-recipes
COPY *.env /opt/docker-recipes
COPY *.sh /opt/docker-recipes
COPY *.whl /opt/docker-recipes


# Set entrypoint to activate the environment on container start
ENTRYPOINT ["/opt/cuquantum-source/cuquantum-env/activate_cuquantum.sh"]