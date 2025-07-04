#!/bin/bash
set -ex

case ${DISTRIBUTION} in
    "almalinux8.6") NCCL_VERSION="2.14.3-1";
        CUDA_VERSION="11.6";
        NCCL_RDMA_SHARP_COMMIT="575c1e0";;
    "almalinux8.7") NCCL_VERSION="2.19.3-1";
        CUDA_VERSION="12.2";
        NCCL_RDMA_SHARP_COMMIT="575c1e0";;
    *) ;;
esac

NCCL_VERSION="2.19.3-1"
CUDA_VERSION="12.2"
NCCL_RDMA_SHARP_COMMIT="575c1e0"

# Install NCCL
yum install -y rpm-build rpmdevtools
TARBALL="v${NCCL_VERSION}.tar.gz"
NCCL_DOWNLOAD_URL=https://github.com/NVIDIA/nccl/archive/refs/tags/${TARBALL}
pushd /tmp
wget ${NCCL_DOWNLOAD_URL}
tar -xvf ${TARBALL}

pushd nccl-${NCCL_VERSION}
make -j$(nproc) src.build
make pkg.redhat.build
rpm -i ./build/pkg/rpm/x86_64/libnccl-${NCCL_VERSION}+cuda${CUDA_VERSION}.x86_64.rpm
rpm -i ./build/pkg/rpm/x86_64/libnccl-devel-${NCCL_VERSION}+cuda${CUDA_VERSION}.x86_64.rpm
rpm -i ./build/pkg/rpm/x86_64/libnccl-static-${NCCL_VERSION}+cuda${CUDA_VERSION}.x86_64.rpm
sed -i "$ s/$/ libnccl*/" /etc/dnf/dnf.conf
popd

# Install the nccl rdma sharp plugin
mkdir -p /usr/local/nccl-rdma-sharp-plugins
git clone https://github.com/Mellanox/nccl-rdma-sharp-plugins.git
pushd nccl-rdma-sharp-plugins
git checkout ${NCCL_RDMA_SHARP_COMMIT}
./autogen.sh
./configure --prefix=/usr/local/nccl-rdma-sharp-plugins --with-cuda=/usr/local/cuda
make
make install
popd
popd

# Build the nccl tests
source /etc/profile.d/modules.sh
module load mpi/hpcx
git clone https://github.com/NVIDIA/nccl-tests.git
pushd nccl-tests
make MPI=1 MPI_HOME=${HPCX_MPI_DIR} CUDA_HOME=/usr/local/cuda
popd
mv nccl-tests /opt/.
module unload mpi/hpcx
$COMMON_DIR/write_component_version.sh "NCCL" ${NCCL_VERSION}

# Remove installation files
rm -rf /tmp/${TARBALL}
rm -rf /tmp/nccl-${NCCL_VERSION}
