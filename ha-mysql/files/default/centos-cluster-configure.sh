#!/bin/bash

CCS=/usr/sbin/ccs
CONFIG=/etc/cluster/cluster.conf

$CCS -f $CONFIG --createcluster pacemaker
$CCS -f $CONFIG --addnode db1-node
$CCS -f $CONFIG --addnode db2-node
$CCS -f $CONFIG --addfencedev pcmk agent=fence_pcmk
$CCS -f $CONFIG --addmethod pcmk-redirect db1-node
$CCS -f $CONFIG --addmethod pcmk-redirect db2-node
$CCS -f $CONFIG --addfenceinst pcmk db1-node pcmk-redirect port=db1-node
$CCS -f $CONFIG --addfenceinst pcmk db2-node pcmk-redirect port=db2-node
$CCS -f $CONFIG --setcman keyfile="/etc/corosync/authkey" transport="udpu" port="5405"
