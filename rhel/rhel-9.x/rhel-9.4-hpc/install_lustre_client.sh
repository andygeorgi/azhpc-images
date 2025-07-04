#!/bin/bash
set -ex

# Build Lustre client for RHEL/AlmaLinux 8.x and 9.x
LUSTRE_VERSION=2_16_1


git clone --depth 1 --branch v${LUSTRE_VERSION} https://github.com/lustre/lustre-release.git

cd lustre-release
sh autogen.sh

./configure --disable-server --with-linux=/usr/src/kernels/$(uname -r)/ --with-o2ib=no

make -j 96
make rpms

# Install the Lustre client RPMs
KMOD_RPM=$(ls ./kmod-lustre-client-[0-9]*.rpm)
CLIENT_RPM=$(ls ./lustre-client-[0-9]*.rpm)

dnf install -y ${KMOD_RPM} ${CLIENT_RPM}

# Expected params:
# $1 = the major version of the distro. "8" for RHEL/Alma8, "9" for RHEL/Alma9.

#DISTRIB_CODENAME="el$1"
#LUSTRE_VERSION=2.15.6_39_g3e00a10
#REPO_PATH=/etc/yum.repos.d/amlfs.repo

#rpm --import https://packages.microsoft.com/keys/microsoft.asc

#echo -e "[amlfs]" > ${REPO_PATH}
#echo -e "name=Azure Lustre Packages" >> ${REPO_PATH}
#echo -e "baseurl=https://packages.microsoft.com/yumrepos/amlfs-${DISTRIB_CODENAME}" >> ${REPO_PATH}
#echo -e "enabled=1" >> ${REPO_PATH}
#echo -e "gpgcheck=1" >> ${REPO_PATH}
#echo -e "gpgkey=https://packages.microsoft.com/keys/microsoft.asc" >> ${REPO_PATH}

#dnf install -y --disableexcludes=main --refresh amlfs-lustre-client-${LUSTRE_VERSION}
#sed -i "$ s/$/ amlfs*/" /etc/dnf/dnf.conf

$RHEL_COMMON_DIR/write_component_version.sh "LUSTRE" ${LUSTRE_VERSION}
