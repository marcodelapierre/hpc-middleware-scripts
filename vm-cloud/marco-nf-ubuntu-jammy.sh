#!/bin/bash

# reboot vm after running this script
# also, remotely connect with VS Code, to get vscode-server downloaded

# versioned packages
singularity_ver="4.0.2"
apptainer_ver="1.2.5"
lmod_ver="8.7.32"
java_ver_list="17.0.9-graalce 20.0.2-graalce 21-graalce"
java_ver_default="20.0.2-graalce"
gradle_ver="8.4"


export DEBIAN_FRONTEND="noninteractive"
cd ~
sudo apt update && sudo apt upgrade -y

# generic extras
sudo apt install -y \
    ca-certificates \
    build-essential gfortran \
    make automake autoconf cmake \
    python3-dev python3-pip python3-setuptools python3-venv \
    git wget curl tar gzip zip unzip bzip2 \
    coreutils patchelf patch file lsb-release gnupg2 gnupg gpg \
    nano vim

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

# apptainer (download only)
apptainer_deb_file="apptainer_${apptainer_ver}_amd64.deb"
wget https://github.com/apptainer/apptainer/releases/download/v${apptainer_ver}/${apptainer_deb_file}

# shpc
pip install singularity-hpc
PATH="$HOME/.local/bin:$PATH"


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


# sdkman + java + gradle
curl -s "https://get.sdkman.io" | bash
. /home/ubuntu/.sdkman/bin/sdkman-init.sh
for ver in ${java_ver_list} ; do
  echo n | sdk install java ${ver}
done
sdk default java ${java_ver_default}
sdk install gradle ${gradle_ver}


# create useful directories and get useful repos
mkdir develop test
cd develop
git clone git@github.com:nextflow-io/nextflow
git clone git@github.com:seqeralabs/wave
git clone git@github.com:seqeralabs/wave-cli
cd -

# final apt cleanup
sudo apt clean all -y && \
    sudo rm -rf /var/lib/apt/lists/* && \
    sudo apt autoremove
