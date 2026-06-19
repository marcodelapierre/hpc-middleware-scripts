#!/bin/bash

EB_VER="4.9.3"
EB_ROOT="/opt/easybuild"

USERID="$USER"

# install Easybuild dependencies
sudo apt update
sudo apt install -y \
  build-essential \
  python3 \
  python3-pip \
  unzip \
  zip


# create install dir
sudo mkdir -p $EB_ROOT
sudo chown ${USERID}:${USERID} $EB_ROOT

# install Easybuild
pip install --prefix=$EB_ROOT easybuild==$EB_VER

#configure shell environment for Easybuild
cat << EOF >> $(eval echo ~${USERID})/.bashrc
# Easybuild setup

export PATH="$EB_ROOT/bin:\$PATH"
export PYTHONPATH="$(ls -rtd $EB_ROOT/lib*/python*/site-packages |tail -1):\$PYTHONPATH"

export EASYBUILD_PREFIX=$EB_ROOT

export EB_PYTHON=python3
export EASYBUILD_RPATH=1

#export EASYBUILD_DEBUG=1
#export EASYBUILD_TRACE=1
#export EASYBUILD_SYSROOT="/"

#module use "$EB_ROOT/modules/all"

# bash completion
. $EB_ROOT/bin/minimal_bash_completion.bash
. $EB_ROOT/bin/optcomplete.bash
complete -F _optcomplete eb

# END of Easybuild setup
EOF
