#!/bin/bash

# setup
git clone git@github.com:spack/spack
cd spack
git checkout v0.23.1
cd ..
git clone git@github.com:marcodelapierre/hpc-middleware-scripts
cp -p hpc-middleware-scripts/package-managers/spack_configs/*.yaml spack/etc/spack/

### further customise etc yamls as needed

# add system compiler
. spack/share/spack/setup-env.sh
spack compiler add --scope site $(dirname $(which gcc))

# install AMD stack
spack install aocc +license-agreed
spack compiler add --scope site $(spack find -p aocc |grep aocc |awk '{print $2}')
spack install amduprof %aocc
spack install amd-aocl %aocc
# aocl with openmp - aocl-da fail due to py-scipy fail due to libflame issue
spack install amd-aocl +openmp %aocc
spack install openmpi %aocc
spack install hpl %aocc +openmp ^amdblis threads=openmp

