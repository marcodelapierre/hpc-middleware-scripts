#!/bin/bash

# reboot vm after running this script

singularity_ver="4.0.1"
lmod_ver="8.7.32"

export DEBIAN_FRONTEND="noninteractive"

sudo apt update && sudo apt upgrade -y

sudo apt install -y \
    ca-certificates \
    build-essential gfortran \
    make automake autoconf cmake \
    python3-dev python3-pip python3-setuptools python3-venv \
    git wget curl tar gzip zip unzip bzip2 \
    coreutils patchelf patch file lsb-release gnupg2 gnupg gpg \
    vim

sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# singularity extras
sudo apt install -y \
   cryptsetup \
   libfuse-dev \
   libglib2.0-dev \
   libseccomp-dev \
   libtool \
   pkg-config \
   runc \
   squashfs-tools \
   squashfs-tools-ng \
   uidmap \
   zlib1g-dev

# docker extras
# Add Docker's official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update


# docker
sudo apt install -y \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER


# singularity
singularity_deb_file="singularity-ce_${singularity_ver}-jammy_amd64.deb"
wget https://github.com/sylabs/singularity/releases/download/v${singularity_ver}/${singularity_deb_file}
sudo apt install ./${singularity_deb_file}
rm ${singularity_deb_file}


# lmod
# install pre-requisites
sudo apt install -y \
  lua5.3 \
  lua-bit32:amd64 \
  lua-posix:amd64 \
  lua-posix-dev \
  liblua5.3-0:amd64 \
  liblua5.3-dev:amd64 \
  tcl \
  tcl-dev \
  tcl8.6 \
  tcl8.6-dev:amd64 \
  libtcl8.6:amd64
# patch for default Lua tools
sudo update-alternatives --install /usr/bin/lua \
  lua-interpreter /usr/bin/lua5.3 130 \
  --slave /usr/share/man/man1/lua.1.gz lua-manual \
  /usr/share/man/man1/lua5.3.1.gz
sudo update-alternatives --install /usr/bin/luac \
  lua-compiler /usr/bin/luac5.3 130 \
  --slave /usr/share/man/man1/luac.1.gz lua-compiler-manual \
  /usr/share/man/man1/luac5.3.1.gz
sudo ln -s /usr/lib/x86_64-linux-gnu/liblua5.3-posix.so \
  /usr/lib/x86_64-linux-gnu/lua/5.3/posix.so
# install Lmod
wget https://github.com/TACC/Lmod/archive/refs/tags/${lmod_ver}.tar.gz
tar xf ${lmod_ver}.tar.gz
cd Lmod-${lmod_ver}/
./configure --prefix=/opt/apps
sudo make install
cd ..
rm -rf ${lmod_ver}.tar.gz Lmod-${lmod_ver}
# configure Lmod
sudo ln -s /opt/apps/lmod/lmod/init/profile /etc/profile.d/z00_lmod.sh
. /etc/profile.d/z00_lmod.sh


# shpc
pip install singularity-hpc
PATH="$HOME/.local/bin:$PATH"

# sdkman + java
curl -s "https://get.sdkman.io" | bash
. /home/ubuntu/.sdkman/bin/sdkman-init.sh
sdk install java 21-graalce


# final apt cleanup
sudo apt clean all -y && \
    sudo rm -rf /var/lib/apt/lists/* && \
    sudo apt autoremove
