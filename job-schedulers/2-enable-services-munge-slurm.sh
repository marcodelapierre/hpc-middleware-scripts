#!/bin/bash

sudo systemctl start munge

sudo systemctl start mariadb

sudo systemctl start slurmdbd
sudo systemctl start slurmctld
sudo systemctl start slurmd
