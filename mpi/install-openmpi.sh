#!/bin/bash

OPENMPI_VERSION="2.1.2"
OPENMPI_ROOT="/opt/openmpi"

USERID="$USER"

OPENMPI_DIR="$OPENMPI_ROOT/openmpi-$OPENMPI_VERSION/apps"
OPENMPI_CONFIGURE_OPTIONS="--enable-fast=all,O3 --prefix=$OPENMPI_DIR"
OPENMPI_MAKE_OPTIONS="-j4"
unset F90

sudo apt-get update
sudo apt-get install -y \
    build-essential \
    gfortran

sudo mkdir -p $OPENMPI_ROOT
sudo chown ${USERID}:${USERID} $OPENMPI_ROOT

cd $OPENMPI_ROOT

wget http://www.openmpi.org/software/ompi/v${OPENMPI_VERSION%.*}/downloads/openmpi-${OPENMPI_VERSION}.tar.bz2
tar xjf openmpi-${OPENMPI_VERSION}.tar.bz2

cd openmpi-${OPENMPI_VERSION}

./configure ${OPENMPI_CONFIGURE_OPTIONS}
make ${OPENMPI_MAKE_OPTIONS}
make install

echo "export PATH=\"$OPENMPI_DIR/bin:\$PATH\"" >> $(eval echo ~${USERID})/.bashrc
echo "export CPATH=\"$OPENMPI_DIR/include:\$CPATH\"" >> $(eval echo ~${USERID})/.bashrc
echo "export LD_LIBRARY_PATH=\"$OPENMPI_DIR/lib:\$LD_LIBRARY_PATH\"" >> $(eval echo ~${USERID})/.bashrc
echo "export LIBRARY_PATH=\"$OPENMPI_DIR/lib:\$LIBRARY_PATH\"" >> $(eval echo ~${USERID})/.bashrc
echo "export MANPATH=\"$OPENMPI_DIR/share/man:\$MANPATH\"" >> $(eval echo ~${USERID})/.bashrc

