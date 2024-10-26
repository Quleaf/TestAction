FROM ubuntu:22.04

LABEL org.opencontainers.image.arch=arm
LABEL org.opencontainers.image.compilation=auto
LABEL org.opencontainers.image.ref.name="ubuntu"
LABEL org.opencontainers.image.version="22.04"
LABEL org.opencontainers.image.author="Shusen Liu"
LABEL org.opencontainers.image.version="26-10-2024"
LABEL org.opencontainers.image.minversion="0.0.1"

ENV NVARCH="sbsa"
ENV NVIDIA_REQUIRE_CUDA="cuda>=12.5"
ARG PY_VERSION="3.12"
ARG CUDA_VERSION="12.6.0"
ENV DEBIAN_FRONTEND="noninteractive"
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
RUN chmod +x /opt/aptscript/install_packages.sh

# Run the install script with the necessary variables
RUN /bin/bash -c "/opt/aptscript/install_packages.sh"

COPY install_dependencies.sh /opt/aptscript/install_dependencies.sh
RUN chmod +x  /opt/aptscript/install_dependencies.sh &&  /opt/aptscript/install_dependencies.sh


# RUN apt-get install -y --no-install-recommends openmpi-bin openmpi-common libopenmpi-dev

# Create links for UCX and OpenMPI
RUN for package in 'ucx' 'ucx-cuda'; do \
        echo "Processing package: ${package}"; \
        name="${package%-*}"; \
        for target in '/bin/' '/lib/' '/include/'; do \
            echo "Processing target: ${target}"; \
            dpkg -L "${package}" | grep -E "${target}" | while read -r file; do \
                if [ -f "${file}" ]; then \
                    echo "Linking file: ${file}" && \
                    mkdir -p "$(dirname "/usr/${name}${target}${file#*${target}}")" && \
                    ln -s "${file}" "/usr/${name}${target}${file#*${target}}"; \
                fi; \
            done; \
        done; \
    done

RUN /bin/bash -c ' \
    base_path="/usr/mpi/gcc/openmpi-4.1.5rc2" && \
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
    update-alternatives --install /usr/local/mpi mpi /usr/openmpi 100 &&\
    update-alternatives --install /usr/local/ucx ucx /usr/ucx 100' 

RUN apt-get update &&\
    apt-get install -y --no-install-recommends libtbb-dev

RUN python -m venv /opt/cuquantum-env && \
    chmod -R a+rwX /opt/cuquantum-env &&\
    . /opt/cuquantum-env/activate_cuquantum.sh && \
    pip install --upgrade pip && \
    pip install 'cryptography~=43.0' 'setuptools' 'urllib3==1.26.5' 'packaging'\
     'httpx' 'wheel' 'mpmath==1.3.0' 'pyjwt==2.4.0'  \
     'mpi4py' &&\
    rm -rf /root/.cache/pip

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
RUN mkdir -p /var/tmp && cd /var/tmp && \
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

# remove to the install_packages.sh
RUN apt-get update && \
    apt-get -y install libcutensor2 libcutensor-dev libcutensor-doc &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN wget https://developer.download.nvidia.com/compute/cuquantum/redist/cuquantum/linux-sbsa/cuquantum-linux-sbsa-24.08.0.5_cuda12-archive.tar.xz \
    && mkdir -p /opt/cuquantum \
    && chmod -R 755 /opt/cuquantum \
    && tar -xvf cuquantum-linux-sbsa-24.08.0.5_cuda12-archive.tar.xz -C /opt/cuquantum --strip-components=1 \
    && rm cuquantum-linux-sbsa-24.08.0.5_cuda12-archive.tar.xz 

RUN ln -s /opt/cuquantum/lib/libcustatevec.so.1 /opt/cuquantum-env/lib/libcustatevec.so.1 &&\
    ln -s /opt/cuquantum/lib/libcustatevec.so.1 /opt/cuquantum-env/lib/libcustatevec.so &&\
    ln -s /opt/cuquantum/lib/libcutensornet.so.2 /opt/cuquantum-env/lib/libcutensornet.so.2 &&\
    ln -s /opt/cuquantum/lib/libcutensornet.so.2 /opt/cuquantum-env/lib/libcutensornet.so 
    

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
    echo 'export MPI_PATH=/usr/local/mpi' >> /opt/cuquantum-env/activate_cuquantum.sh && \
 #for cutensornet samples require MPI_ROOT   
    echo 'export MPI_ROOT=/usr/local/mpi' >> /opt/cuquantum-env/activate_cuquantum.sh && \
    echo 'export PATH=/usr/local/cuda/bin:/usr/local/mpi/bin:/usr/local/ucx/bin:/usr/local/munge/bin:/usr/local/pmix/bin:/usr/local/slurm/bin:/usr/local/nvidia/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cuquantum/bin' >> /opt/cuquantum-env/activate_cuquantum.sh && \
    chmod +x /opt/cuquantum-env/activate_cuquantum.sh

COPY qiskit_aer-0.15.0-cp312-cp312-linux_aarch64.whl /opt/

RUN . /opt/cuquantum-env/activate_cuquantum.sh \
    && pip install 'Cython>=0.29.22,<3' numpy cupy-cuda12x nbformat pytest\
    && pip install /opt/qiskit_aer-0.15.0-cp312-cp312-linux_aarch64.whl\
    && wget https://github.com/NVIDIA/cuQuantum/archive/refs/tags/v24.08.0.tar.gz \
    && mkdir -p /opt/cuquantum-source \
    && tar -xvf v24.08.0.tar.gz -C /opt/cuquantum-source --strip-components=1 \
    && rm v24.08.0.tar.gz \
    && cd /opt/cuquantum-source/python \
    && pip install -v --no-deps --no-build-isolation . \
    && rm -rf /root/.cache/pip

RUN cd /opt/cuquantum/distributed_interfaces &&\
    sh activate_mpi.sh &&\
    echo 'export CUTENSORNET_COMM_LIB=/opt/cuquantum/distributed_interfaces/libcutensornet_distributed_mpi.so' >> /opt/cuquantum-env/activate_cuquantum.sh 



# Configure deactivate script
RUN echo '#!/bin/bash' > /opt/cuquantum-env/deactivate_cuquantum.sh && \
    echo 'export LD_LIBRARY_PATH=${BASE_LD_LIBRARY_PATH}' >> /opt/cuquantum-env/deactivate_cuquantum.sh && \
    echo 'export LD_PRELOAD=${BASE_LD_PRELOAD}' >> /opt/cuquantum-env/deactivate_cuquantum.sh && \
    echo 'unset BASE_LD_LIBRARY_PATH' >> /opt/cuquantum-env/deactivate_cuquantum.sh && \
    echo 'unset BASE_LD_PRELOAD' >> /opt/cuquantum-env/deactivate_cuquantum.sh && \
    chmod +x /opt/cuquantum-env/deactivate_cuquantum.sh

# Set entrypoint to activate the environment on container start
# ENTRYPOINT ["/opt/cuquantum-env/activate_cuquantum.sh"]