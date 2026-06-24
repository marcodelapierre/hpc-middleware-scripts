#!/bin/bash

# Installing OpenMPI with additional libraries for improved performance and capabilities
# - UCX
# - UCC
# - PMIx
# - PRRTE

# Infiniband support
# RHEL/RockyLinux instead of Ubuntu

#prerequisites
#ucx
dnf install -y numactl numactl-devel
#pmix
dnf install -y libevent-devel hwloc hwloc-devel zlib-ng-devel

startdir="$(pwd)"
mkdir setup software
cd setup

#download tarballs
wget https://github.com/openucx/ucx/releases/download/v1.20.1/ucx-1.20.1.tar.gz
wget -O ucc-1.8.0.tar.gz https://github.com/openucx/ucc/archive/refs/tags/v1.8.0.tar.gz
wget https://github.com/openpmix/openpmix/releases/download/v6.1.0/pmix-6.1.0.tar.gz
wget https://github.com/openpmix/prrte/releases/download/v4.1.0/prrte-4.1.0.tar.gz
wget https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.10.tar.bz2

#untar
tar xzf ucx-1.20.1.tar.gz
tar xzf ucc-1.8.0.tar.gz
tar xzf pmix-6.1.0.tar.gz
tar xzf prrte-4.1.0.tar.gz
tar xjf openmpi-5.0.10.tar.bz2

#UCX
cd $startdir/setup/ucx-1.20.1
mkdir build && cd build
../contrib/configure-release --prefix=$startdir/software/ucx --enable-compiler-opt=3 --enable-optimizations --enable-openmp --enable-mt --enable-cma --without-java --without-go --disable-doxygen-doc --disable-logging --disable-debug --disable-assertions --disable-params-check --with-rc --with-ud --with-dc --with-ib-hw-tm --with-mlx5 --with-mad --with-rdmacm
make -j16
make install

#UCC (deps on UCX)
cd $startdir/setup/ucc-1.8.0
./autogen.sh
mkdir build && cd build
../configure --prefix=$startdir/software/ucc --with-ucx=$startdir/software/ucx --enable-optimizations --disable-doxygen-doc --with-ibverbs --with-rdmacm
make -j16
make install

#PMIx
cd $startdir/setup/pmix-6.1.0
mkdir build && cd build
../configure --prefix=$startdir/software/pmix --enable-pmix-binaries --with-hwloc --with-munge --with-zlibng
make -j16
make install

#PRRTE (deps on PMIx)
cd $startdir/setup/prrte-4.1.0
mkdir build && cd build
../configure --prefix=$startdir/software/prrte --with-pmix=$startdir/software/pmix --with-slurm --with-hwloc
make -j16
make install

#OpenMPI (deps on UCX,UCC,PMIx,PRRTE)
#NOTE: may require further configs when actual interconnect is present
cd $startdir/setup/openmpi-5.0.10
mkdir build && cd build
../configure --prefix=$startdir/software/openmpi --with-ucx=$startdir/software/ucx --with-ucc=$startdir/software/ucc --with-pmix=$startdir/software/pmix --with-prrte=$startdir/software/prrte --enable-oshmem --with-slurm --with-hwloc --with-munge --with-zlibng --with-cma
make -j16
make install

