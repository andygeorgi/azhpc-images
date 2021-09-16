#!/bin/bash
set -ex

MLNX_OFED_DOWNLOAD_URL=https://content.mellanox.com/ofed/MLNX_OFED-5.4-1.0.3.0/MLNX_OFED_LINUX-5.4-1.0.3.0-rhel8.4-x86_64.tgz
TARBALL=$(basename ${MLNX_OFED_DOWNLOAD_URL})
MOFED_FOLDER=$(basename ${MLNX_OFED_DOWNLOAD_URL} .tgz)

$COMMON_DIR/download_and_verify.sh $MLNX_OFED_DOWNLOAD_URL "2c4d446e5355bb6e7b73fd5dee5afdee9d980dcf4ee1385672c0484f5b020ab9"
tar zxvf ${TARBALL}

KERNEL=( $(rpm -q kernel | sed 's/kernel\-//g') )
KERNEL=${KERNEL[-1]}
yum install -y kernel-devel-${KERNEL}
./${MOFED_FOLDER}/mlnxofedinstall --kernel $KERNEL --kernel-sources /usr/src/kernels/${KERNEL} --add-kernel-support --skip-repo --distro rhel8.4
