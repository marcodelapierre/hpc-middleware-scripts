#!/bin/bash

# Installing OpenMPI with additional libraries for improved performance and capabilities
# - UCX
# - UCC
# - PMIx
# - PRRTE

#prerequisites
#ucx
sudo apt install -y libnuma-dev numactl
#pmix
sudo apt install -y libevent-dev libhwloc-dev hwloc

startdir="$(pwd)"
mkdir -p $startdir/software

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
#NOTE: may require further configs when actual interconnect is present
cd $startdir/ucx-1.20.1
mkdir build && cd build
../configure --prefix=$startdir/software/ucx --enable-compiler-opt=3 --enable-optimizations --enable-openmp --enable-mt --enable-cma --without-java --without-go --disable-doxygen-doc --disable-logging --disable-debug --disable-assertions --disable-params-check
make -j2
make install

#UCC (deps on UCX)
#NOTE: may require further configs when actual interconnect is present
cd $startdir/ucc-1.8.0
./autogen.sh
mkdir build && cd build
../configure --prefix=$startdir/software/ucc --with-ucx=$startdir/software/ucx 
make -j2
make install

#PMIx
cd $startdir/pmix-6.1.0
mkdir build && cd build
../configure --prefix=$startdir/software/pmix --enable-pmix-binaries
make -j2
make install

#PRRTE (deps on PMIx)
cd $startdir/prrte-4.1.0
mkdir build && cd build
../configure --prefix=$startdir/software/prrte --with-pmix=$startdir/software/pmix --with-slurm
make -j2
make install

#OpenMPI (deps on UCX,UCC,PMIx,PRRTE)
#NOTE: may require further configs when actual interconnect is present
cd $startdir/openmpi-5.0.10
mkdir build && cd build
../configure --prefix=$startdir/software/openmpi --with-ucx=$startdir/software/ucx --with-ucc=$startdir/software/ucc --with-pmix=$startdir/software/pmix --with-prrte=$startdir/software/prrte --with-slurm
make -j2
make install

