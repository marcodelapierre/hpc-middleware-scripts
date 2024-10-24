#!/bin/bash

SPACK_VER="0.16"
SPACK_ROOT="/opt/spack"

USERID="$USER"

# install Spack dependencies
sudo apt update
sudo apt install -y \
  build-essential \
  ca-certificates \
  coreutils \
  curl \
  gfortran \
  git \
  gpg \
  lsb-release \
  python3 \
  python3-distutils \
  python3-venv \
  unzip \
  zip

# create install dir
sudo mkdir -p $SPACK_ROOT
sudo chown ${USERID}:${USERID} $SPACK_ROOT

# clone Spack
cd $SPACK_ROOT
git clone https://github.com/spack/spack.git .

# checkout appropriate version
git checkout releases/v"$SPACK_VER"

# configure shell environment for Spack
cat << EOF >> $(eval echo ~${USERID})/.bashrc
. ${SPACK_ROOT}/share/spack/setup-env.sh
EOF

