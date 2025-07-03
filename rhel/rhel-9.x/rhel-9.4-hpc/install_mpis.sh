#!/bin/bash
set -ex

# Load gcc
GCC_VERSION=gcc-9.2.0
export PATH=/opt/${GCC_VERSION}/bin:$PATH
export LD_LIBRARY_PATH=/opt/${GCC_VERSION}/lib64:$LD_LIBRARY_PATH
set CC=/opt/${GCC_VERSION}/bin/gcc
set GCC=/opt/${GCC_VERSION}/bin/gcc

INSTALL_PREFIX=/opt

PMIX_VERSION=4.2.9-1
PMIX_PATH=${INSTALL_PREFIX}/pmix/${PMIX_VERSION:0:-2}

# HPC-X v2.15
HPCX_VERSION="v2.18.1"
TARBALL="hpcx-${HPCX_VERSION}-gcc-mlnx_ofed-redhat9-cuda12-x86_64.tbz"
HPCX_DOWNLOAD_URL=https://content.mellanox.com/hpc/hpc-x/${HPCX_VERSION}/${TARBALL}
HPCX_FOLDER=$(basename ${HPCX_DOWNLOAD_URL} .tbz)

$COMMON_DIR/download_and_verify.sh $HPCX_DOWNLOAD_URL "cbdf61cb4e43d443ffbf6a091800889b7af92ee0358c00ea536a193708002a54"
tar -xvf ${TARBALL}

sed -i "s/\/build-result\//\/opt\//" ${HPCX_FOLDER}/hcoll/lib/pkgconfig/hcoll.pc
mv ${HPCX_FOLDER} ${INSTALL_PREFIX}
HPCX_PATH=${INSTALL_PREFIX}/${HPCX_FOLDER}
HCOLL_PATH=${HPCX_PATH}/hcoll
UCX_PATH=${HPCX_PATH}/ucx
$COMMON_DIR/write_component_version.sh "HPCX" $HPCX_VERSION

# rebuild HPCX with PMIx
${HPCX_PATH}/utils/hpcx_rebuild.sh --with-hcoll --ompi-extra-config "--with-pmix=${PMIX_PATH} --enable-orterun-prefix-by-default"
cp -r ${HPCX_PATH}/ompi/tests ${HPCX_PATH}/hpcx-rebuild

# exclude ucx from updates
sed -i "$ s/$/ ucx*/" /etc/dnf/dnf.conf

# Install platform independent MPIs
$RHEL_COMMON_DIR/install_mpis.sh ${GCC_VERSION} ${HPCX_PATH}

# cleanup downloaded tarball for HPC-x
rm -rf *.tbz