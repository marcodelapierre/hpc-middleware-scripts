## Quick setup for Multiple Slurmd feature

Tested with Slurm 25.05.

At Slurm configure time:
```
./configure [..] --enable-multiple-slurmd
```

Edits to `slurm.conf`:
```
9c8
< SlurmdPidFile=/var/run/slurmd.pid
---
> SlurmdPidFile=/var/run/slurmd_%n.pid
11c10
< SlurmdSpoolDir=/var/spool/slurmd
---
> SlurmdSpoolDir=/var/spool/slurmd_%n
32c31
< SlurmdLogFile=/var/log/slurmd.log
---
> SlurmdLogFile=/var/log/slurmd_%n.log

```

Edits to `nodes.conf` (have to specify `Ports`):
```
< NodeName=node[001-10]      RealMemory=248000    Sockets=2  CoresPerSocket=32  ThreadsPerCore=1 State=UNKNOWN NodeAddr=slurm-simulator NodeHostName=slurm-simulator
---
> NodeName=node[001-10]      RealMemory=248000    Sockets=2  CoresPerSocket=32  ThreadsPerCore=1 State=UNKNOWN Port=[6001-6010] NodeAddr=slurm-simulator NodeHostName=slurm-simulator
```

Required additional system service `/usr/lib/systemd/system/slurmd@.service`. 
Note edited line `ExecStart` and additional line `PIDFile`.
```
[Unit]
Description=Slurm node daemon
After=munge.service network-online.target remote-fs.target sssd.service
Wants=network-online.target
#ConditionPathExists=/etc/slurm/slurm.conf

[Service]
Type=notify
EnvironmentFile=-/etc/sysconfig/slurmd
EnvironmentFile=-/etc/default/slurmd
RuntimeDirectory=slurm
RuntimeDirectoryMode=0755
ExecStart=/usr/sbin/slurmd -N%i --systemd $SLURMD_OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/var/run/slurmd_%i.pid
KillMode=process
LimitNOFILE=131072
LimitMEMLOCK=infinity
LimitSTACK=infinity
Delegate=yes
TasksMax=infinity

# Uncomment the following lines to disable logging through journald.
# NOTE: It may be preferable to set these through an override file instead.
#StandardOutput=null
#StandardError=null

[Install]
WantedBy=multi-user.target
```

To start the Slurmd daemons:
```
for i in 1 2 3 ; do
  systemctl enable slurmd@node0$i
done
```

