#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# add Mellanox OFED 
wget -O- https://www.mellanox.com/downloads/ofed/RPM-GPG-KEY-Mellanox | gpg --dearmor | tee /usr/share/keyrings/mlnx_ofed-archive-keyring.gpg > /dev/null

echo 'deb [signed-by=/usr/share/keyrings/mlnx_ofed-archive-keyring.gpg] http://linux.mellanox.com/public/repo/mlnx_ofed/23.07-0.5.1.2/ubuntu22.04/aarch64/ ./' > /etc/apt/sources.list.d/mellanox_mlnx_ofed.list

# unset DEBIAN_FRONTEND
unset DEBIAN_FRONTEND

# remove old version of Mellanox OFED
apt-get update --yes && \
apt-get remove --yes \
    libipathverbs1 \
    librdmacm1 \
    libibverbs1 \
    libmthca1 \
    libopenmpi-dev \
    openmpi-bin \
    openmpi-common \
    openmpi-doc \
    libmlx4-1 \
    rdmacm-utils \
    ibverbs-utils \
    infiniband-diags \
    ibutils \
    perftest

# install necessary packages
apt-get update && \
apt-get install -y ibverbs-providers openssl libssl-dev openssh-client openssh-server&& \
wget https://launchpad.net/ubuntu/+archive/primary/+files/libucx0_1.16.0+ds-5ubuntu1_arm64.deb && \
dpkg -i libucx0_1.16.0+ds-5ubuntu1_arm64.deb || apt-get install -f -y && \
rm -f libucx0_1.16.0+ds-5ubuntu1_arm64.deb

# install Mellanox OFED and nvdia driver
apt-get update && apt-get install -y --no-install-recommends libnvidia-compute-560=560.35.03-0ubuntu1

#Here OpenMPI has been installed as a dependency of Mellanox OFED
apt-get install -y --no-install-recommends mlnx-ofed-all  
apt-get install -y --no-install-recommends ucx-cuda

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*
