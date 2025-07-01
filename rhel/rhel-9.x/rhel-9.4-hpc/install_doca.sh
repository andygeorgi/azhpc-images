#!/bin/bash
set -ex

VERSION="3.0.0"
RPM_NAME="doca-host-3.0.0-058000_25.04_rhel94.x86_64.rpm"
DOCA_DOWNLOAD_URL="https://www.mellanox.com/downloads/DOCA/DOCA_v$VERSION/host/$RPM_NAME"
DOCA_FOLDER=$(basename ${DOCA_DOWNLOAD_URL} .rpm)
SHA256="0c2502e014b840410889441b24e163d631130a883cda93faef8bb4e83300c476"

echo "Download URL: $DOCA_DOWNLOAD_URL"
echo "Target folder: $DOCA_FOLDER"

$COMMON_DIR/download_and_verify.sh $MLNX_OFED_DOWNLOAD_URL $SHA256

rpm -i $RPM_NAME
dnf clean all

# Install DOCA extra packages
dnf install -y doca-extra

# Build DOCA kernel support
/opt/mellanox/doca/tools/doca-kernel-support

# Install DOCA kernel support
rpm -Uvh $(find /tmp/DOCA.*/ -name 'doca-kernel-repo-*.rpm' -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)

# Create metadata cahce
dnf makecache

# Install DOCA OFED
dnf -y install doca-ofed-userspace
dnf -y install doca-ofed

# Restart and check status of HCA driver
/etc/init.d/openibd restart
/etc/init.d/openibd status
error_code=$?
if [ ${error_code} -ne 0 ]
then
    echo "OpenIBD not loaded correctly!"
    exit ${error_code}
fi