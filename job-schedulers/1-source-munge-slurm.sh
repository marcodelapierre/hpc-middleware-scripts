#!/bin/bash

install_root="$HOME/slurm-install"
munge_root="${install_root}/apps/munge"
slurm_root="${install_root}/apps/slurm"

export PATH=$munge_root/sbin:$munge_root/bin:$PATH
export CPATH=$munge_root/include:$CPATH
export LIBRARY_PATH=$munge_root/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=$munge_root/lib:$LD_LIBRARY_PATH
export MANPATH=$munge_root/share/man:$MANPATH

export PATH=$slurm_root/sbin:$slurm_root/bin:$PATH
export CPATH=$slurm_root/include:$CPATH
export LIBRARY_PATH=$slurm_root/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=$slurm_root/lib:$LD_LIBRARY_PATH
export MANPATH=$slurm_root/share/man:$MANPATH
