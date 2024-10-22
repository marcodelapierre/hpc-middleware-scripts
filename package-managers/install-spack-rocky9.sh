#!/bin/bash

# adapted for Rocky Linux 9.x

SPACK_VER="0.22.2"
SPACK_ROOT="/opt/spack"

USERID="$USER"

# install Spack dependencies
sudo dnf install -y epel-release
sudo dnf group install -y "Development Tools"
sudo dnf install --allowerasing -y \
  curl \
  findutils \
  gcc-gfortran \
  gnupg2 \
  hostname \
  iproute \
  python3 \
  python3-pip \
  python3-setuptools \
  python3-boto3 \
  unzip

# extra steps for "redhat-lsb-core"
sudo dnf install -y yum-utils
sudo dnf config-manager --set-enabled devel
sudo dnf update -y
sudo dnf install -y redhat-lsb-core
sudo dnf config-manager --set-disabled devel
sudo dnf update -y

# create install dir
sudo mkdir -p $SPACK_ROOT
sudo chown ${USERID}:${USERID} $SPACK_ROOT

# clone Spack
cd $SPACK_ROOT
git clone https://github.com/spack/spack.git .

# checkout appropriate version
git checkout releases/v"$SPACK_VER"

# configure shell environment for Spack
echo ". ${SPACK_ROOT}/share/spack/setup-env.sh" >> $(eval echo ~${USERID})/.bashrc
. ${SPACK_ROOT}/share/spack/setup-env.sh
