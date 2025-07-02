#!/bin/bash
set -ex

PMIX_VERSION=4.2.9-1

# Create the slurm.repo file with the specified content
cat <<EOF > /etc/yum.repos.d/slurm.repo
[slurm]
name=Slurm Workload Manager
baseurl=https://packages.microsoft.com/yumrepos/slurm-el9-insiders
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
priority=10
EOF


# Install Microsoft GPG keys if not already present
if [ ! -e /etc/yum.repos.d/microsoft-prod.repo ]; then
   curl -sSL -O https://packages.microsoft.com/config/rhel/9/packages-microsoft-prod.rpm
   rpm -i packages-microsoft-prod.rpm
   rm packages-microsoft-prod.rpm
fi

# Install required packages
yum -y install pmix-${PMIX_VERSION}.el9 hwloc-devel libevent-devel munge-devel

$COMMON_DIR/write_component_version.sh "PMIX" ${PMIX_VERSION}