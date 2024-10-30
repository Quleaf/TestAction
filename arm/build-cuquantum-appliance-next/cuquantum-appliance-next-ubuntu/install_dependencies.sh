#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# # add Mellanox OFED 
# wget -O- https://www.mellanox.com/downloads/ofed/RPM-GPG-KEY-Mellanox | gpg --dearmor | tee /usr/share/keyrings/mlnx_ofed-archive-keyring.gpg > /dev/null

# echo 'deb [signed-by=/usr/share/keyrings/mlnx_ofed-archive-keyring.gpg] http://linux.mellanox.com/public/repo/mlnx_ofed/23.07-0.5.1.2/ubuntu22.04/aarch64/ ./' > /etc/apt/sources.list.d/mellanox_mlnx_ofed.list

# # unset DEBIAN_FRONTEND
# unset DEBIAN_FRONTEND

# # remove old version of Mellanox OFED
# apt-get update --yes && \
# apt-get remove --yes \
#     libipathverbs1 \
#     librdmacm1 \
#     libibverbs1 \
#     libmthca1 \
#     libopenmpi-dev \
#     openmpi-bin \
#     openmpi-common \
#     openmpi-doc \
#     libmlx4-1 \
#     rdmacm-utils \
#     ibverbs-utils \
#     infiniband-diags \
#     ibutils \
#     perftest

# # install necessary packages
# apt-get update && \
# apt-get install -y ibverbs-providers openssl libssl-dev openssh-client openssh-server
#wget https://launchpad.net/ubuntu/+archive/primary/+files/libucx0_1.16.0+ds-5ubuntu1_arm64.deb && \
#dpkg -i libucx0_1.16.0+ds-5ubuntu1_arm64.deb || apt-get install -f -y && \
#rm -f libucx0_1.16.0+ds-5ubuntu1_arm64.deb

# install Mellanox OFED and nvdia driver
# apt-get update && apt-get install -y --no-install-recommends libnvidia-compute-560=560.35.03-0ubuntu1

#Here OpenMPI has been installed as a dependency of Mellanox OFED
#apt-get install -y --no-install-recommends mlnx-ofed-all  
#apt-get install -y --no-install-recommends ucx-cuda


apt-get update 
apt-get install -y --no-install-recommends \
udev \
pciutils \
tk \
libnl-route-3-200 \
libfuse2 \
debhelper \
libnl-3-200 \
ethtool \
gfortran \
lsof \
libltdl-dev \
libpci3 \
libnl-route-3-dev \
libusb-1.0-0 \
pkg-config \
graphviz \
tcl \
swig \
chrpath \
libnl-3-dev \
libmnl0 \
bison \
kmod \
libnvidia-compute-535 
rm -rf /var/lib/apt/lists/*

# Install MLNX OFED (user-space only)
# Set MLNX OFED version and download URL
MLNX_OFED_VERSION=23.10-3.2.2.0
MLNX_OFED_PACKAGE=MLNX_OFED_LINUX-${MLNX_OFED_VERSION}-ubuntu22.04-aarch64.tgz
MLNX_OFED_DOWNLOAD_URL=https://content.mellanox.com/ofed/MLNX_OFED-${MLNX_OFED_VERSION}/${MLNX_OFED_PACKAGE}

# Download and extract MLNX OFED
mkdir -p /tmp/MLNX_OFED 
cd /tmp && \
wget ${MLNX_OFED_DOWNLOAD_URL} 
tar -xzf ${MLNX_OFED_PACKAGE} -C /tmp/MLNX_OFED --strip-components=1 
rm ${MLNX_OFED_PACKAGE}

# Install MLNX OFED user-space components
cd /tmp/MLNX_OFED/MLNX_OFED_LINUX-23.10-3.2.2.0-ubuntu22.04-aarch64 
# ./mlnxofedinstall --user-space-only --without-fw-update --all --force

# # Clean up MLNX OFED installation files
# rm -rf /tmp/MLNX_OFED


# # Clean up
# apt-get clean
# rm -rf /var/lib/apt/lists/*
