#!/bin/bash

# required variables
munge_ver="0.5.16"
slurm_ver="25.05.4"
install_root="$HOME/slurm-install"
munge_root="${install_root}/apps/munge"
slurm_root="${install_root}/apps/slurm"

# activate munge and slurm installations - for later
. 1-source-munge-slurm.sh


# install munge and its dependencies
sudo apt update
sudo apt install -y \
  build-essential \
  openssl \
  bzip2 \
  libbz2-dev \
  zlib1g-dev \
  xz-utils \
  pkgconf \
  libpkgconf-dev \
  libgcrypt20-dev \
  libssl-dev

wget https://github.com/dun/munge/releases/download/munge-${munge_ver}/munge-${munge_ver}.tar.xz

tar xJf munge-${munge_ver}.tar.xz
cd munge-${munge_ver}
./configure \
  --prefix=$munge_root \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --runstatedir=/run
make
sudo make install
cd ..

# configure munge
sudo useradd -M -U -s /usr/sbin/nologin  munge
sudo mkdir -p /run/munge
sudo chown -R munge:munge /var/log/munge /var/lib/munge /etc/munge /run/munge
sudo chmod 700 /var/lib/munge/ /var/log/munge/ /etc/munge/
sudo chmod 755 /run/munge/
#sudo -u munge bash -c 'dd if=/dev/urandom bs=1 count=1024 >/etc/munge/munge.key'
#sudo chmod 600 /etc/munge/munge.key
sudo -u munge /usr/sbin/mungekey --verbose

sudo ln -s $munge_root/lib/systemd/system/munge.service /usr/lib/systemd/system/
#sudo systemctl enable munge
sudo systemctl start munge


# install other slurm dependencies
sudo apt update
sudo apt install -y \
  bpfcc-tools \
  libdbus-1-dev \
  liblua5.3-dev \
  libpam0g-dev \
  libhwloc-dev \
  libnuma-dev \
  mariadb-client \
  mariadb-server \
  libmariadb-dev

# configure mariadb
#sudo systemctl enable mariadb
sudo systemctl start mariadb

sudo mysqladmin -u root password 'HPCNOW'
sudo mysql --user="root" --password="HPCNOW" --execute="create user 'slurm'@'localhost' identified by 'HPCNOW';"
sudo mysql --user="root" --password="HPCNOW" --execute="grant all on slurm_acct_db.* TO 'slurm'@'localhost';"
sudo mysql --user="root" --password="HPCNOW" --execute="create database slurm_acct_db;"

sudo mkdir -p /etc/my.cnf.d
sudo cp -p slurm_config/innodb.cnf /etc/my.cnf.d/
sudo chown root:root /etc/my.cnf.d/innodb.cnf


# install slurm

wget https://download.schedmd.com/slurm/slurm-${slurm_ver}.tar.bz2

tar xjf slurm-${slurm_ver}.tar.bz2
cd slurm-${slurm_ver}
slurm_builddir=$(pwd)

# front-end feature deprecated
./configure \
  --prefix=${slurm_root} \
  --sysconfdir=${slurm_root}/etc \
  --with-lua \
  --enable-pam \
  --enable-cgroupv2 \
  --enable-debug
make
sudo make install
#ldconfig -n ${slurm_root}/lib

cd ..


# configure Slurm

sudo useradd -M -U -s /usr/sbin/nologin slurm

sudo mkdir -p /var/run/slurm /var/spool/slurmd /var/spool/slurmctld /var/log/slurm
sudo chown -R slurm:slurm /var/run/slurm /var/spool/slurmd /var/spool/slurmctld /var/log/slurm
sudo chmod 700 /var/spool/slurmctld /var/log/slurm
sudo chmod 755 /var/run/slurm /var/spool/slurmd

for service in sackd slurmctld slurmdbd slurmd slurmrestd ; do
#  ls $slurm_builddir/etc/$service.service
   sudo cp -p $slurm_builddir/etc/$service.service /usr/lib/systemd/system/
done

sudo mkdir -p ${slurm_root}/etc
sudo cp -p slurm_config/*.conf ${slurm_root}/etc/
sudo chown slurm:slurm ${slurm_root}/etc/*.conf
sudo chmod 600 ${slurm_root}/etc/slurmdbd.conf

#sudo systemctl enable slurmdbd
sudo systemctl start slurmdbd
#sudo systemctl enable slurmctld
sudo systemctl start slurmctld
#sudo systemctl enable slurmd
sudo systemctl start slurmd

# Because of non-standard paths for Slurm, extra steps are required for admin with root
# sudo su - root
# . /home/mdelapierre/slurm-install/1-source-munge-slurm.sh
# sacctmgr -i add account proj01 \
#   description=Project01 organization="Project 01" \
#   cluster=laptop1 fairshare=100
# sacctmgr -i add user mdelapierre account=proj01
# exit

# Had to take these extra steps, not sure if due to initial config errors
# sudo su - root
# . /home/mdelapierre/slurm-install/1-source-munge-slurm.sh
# scontrol update NodeName=node01 State=DOWN Reason="undraining"
# scontrol update NodeName=node01 State=RESUME 
# exit

