#!/bin/bash
set -ex

# Install Kernel dependencies
KERNEL=$(uname -r)
yum install -y kernel-devel-${KERNEL} kernel-headers-${KERNEL} kernel-modules-extra-${KERNEL}

# Install pre-reqs and development tools
yum group install -y "Development Tools"
yum install -y numactl \
    numactl-devel \
    libxml2-devel \
    byacc \
    environment-modules \
    python3-devel \
    python3-setuptools \
    gtk2 \
    atk \
    cairo \
    tcl \
    tk \
    m4 \
    glibc-devel \
    libudev-devel \
    binutils \
    binutils-devel \
    selinux-policy-devel \
    nfs-utils \
    fuse-libs \
    libpciaccess \
    cmake \
    libnl3-devel \
    libsecret \
    rpm-build \
    make \
    check \
    check-devel \
    lsof \
    kernel-rpm-macros \
    tcsh \
    gcc-gfortran \
    perl


# Enable EPEL repo for 3rd party packages and install pssh, dkms, subunit and jq
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
yum install -y pssh dkms subunit subunit-devel jq

## Disable kernel updates
echo "exclude=kernel* kmod*" | tee -a /etc/dnf/dnf.conf

# Disable dependencies on kernel core
sed -i "$ s/$/ shim*/" /etc/dnf/dnf.conf
sed -i "$ s/$/ grub2*/" /etc/dnf/dnf.conf

# Install azcopy tool 
# To copy blobs or files to or from a storage account.
VERSION="10.28.1"
RELEASE_TAG="10.28.1-20250326"
SHA256="0f637fd5cf8f5a041592bd2104234682cc0bc7a893298a5641b87d4bef96bc6d"
TARBALL="azcopy_linux_amd64_${VERSION}.tar.gz"
AZCOPY_DOWNLOAD_URL="https://azcopyvnext-awgzd8g7aagqhzhe.b02.azurefd.net/releases/release-${RELEASE_TAG}/${TARBALL}"
AZCOPY_FOLDER=$(basename ${AZCOPY_DOWNLOAD_URL} .tgz)

${COMMON_DIR}/download_and_verify.sh ${AZCOPY_DOWNLOAD_URL} ${SHA256}
tar -xvf ${TARBALL}

# copy the azcopy to the bin path
pushd azcopy_linux_amd64_${VERSION}
cp azcopy /usr/bin/
popd

# Allow execute permissions
chmod +x /usr/bin/azcopy

# remove tarball from azcopy
rm -rf *.tar.gz

# copy kvp client file
$COMMON_DIR/copy_kvp_client.sh
