#!/bin/bash
set -e

GCC_VERSION=$1
HPCX_PATH=$2

HCOLL_PATH=${HPCX_PATH}/hcoll
UCX_PATH=${HPCX_PATH}/ucx
INSTALL_PREFIX=/opt

# Load gcc
export PATH=/opt/${GCC_VERSION}/bin:$PATH
export LD_LIBRARY_PATH=/opt/${GCC_VERSION}/lib64:$LD_LIBRARY_PATH
set CC=/opt/${GCC_VERSION}/bin/gcc
set GCC=/opt/${GCC_VERSION}/bin/gcc

# MVAPICH2 2.3.7-2
MV2_VERSION="2.3.7-2"
MV2_DOWNLOAD_URL=http://mvapich.cse.ohio-state.edu/download/mvapich/mv2/mvapich2-${MV2_VERSION}.tar.gz
$COMMON_DIR/download_and_verify.sh $MV2_DOWNLOAD_URL "03fc160c81a1d522b1e7c6723841e27fcab04d527484e4242d3e66d7c5024205"
tar -xvf mvapich2-${MV2_VERSION}.tar.gz
cd mvapich2-${MV2_VERSION}
./configure --prefix=${INSTALL_PREFIX}/mvapich2-${MV2_VERSION} --enable-g=none --enable-fast=yes && make -j$(nproc) && make install
cd ..
$COMMON_DIR/write_component_version.sh "MVAPICH2" ${MV2_VERSION}


# OpenMPI 5.0.7
OMPI_VERSION="5.0.7"
OMPI_DOWNLOAD_URL=https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-${OMPI_VERSION}.tar.gz
$COMMON_DIR/download_and_verify.sh $OMPI_DOWNLOAD_URL "67435fdb2560f897882e69fead171d38e7f44a6dfe1d3c90506f549a943050b8"
tar -xvf openmpi-${OMPI_VERSION}.tar.gz
cd openmpi-${OMPI_VERSION}
./configure --prefix=${INSTALL_PREFIX}/openmpi-${OMPI_VERSION} --with-ucx=${UCX_PATH} --with-hcoll=${HCOLL_PATH} --enable-mpirun-prefix-by-default --with-platform=contrib/platform/mellanox/optimized && make -j$(nproc) && make install
cd ..
$COMMON_DIR/write_component_version.sh "OMPI" ${OMPI_VERSION}

# exclude openmpi, perftest from updates
sed -i "$ s/$/ openmpi perftest/" /etc/dnf/dnf.conf

# Install Intel MPI
IMPI_VERSION=2021.15.0
IMPI_SHA256=d4ad297174ce3837444468645e13cfe78f11d9bf2ad9ade2057b2668cccd9385
IMPI_DOWNLOAD_URL=https://registrationcenter-download.intel.com/akdlm/IRC_NAS/6b6e395e-8f38-4da3-913d-90a2bcf41028/intel-mpi-2021.15.0.495_offline.sh
IMPI_OFFLINE_INSTALLER=$(basename $IMPI_DOWNLOAD_URL)

$COMMON_DIR/download_and_verify.sh $IMPI_DOWNLOAD_URL $IMPI_SHA256
bash $IMPI_OFFLINE_INSTALLER -s -a -s --eula accept

impi_2021_version=${IMPI_VERSION:0:-2}
mv ${INSTALL_PREFIX}/intel/oneapi/mpi/${impi_2021_version}/etc/modulefiles/mpi ${INSTALL_PREFIX}/intel/oneapi/mpi/${impi_2021_version}/etc/modulefiles/impi
$COMMON_DIR/write_component_version.sh "IMPI" ${IMPI_VERSION}

# Setup module files for MPIs
MPI_MODULE_FILES_DIRECTORY=${MODULE_FILES_DIRECTORY}/mpi
mkdir -p ${MPI_MODULE_FILES_DIRECTORY}

# HPC-X
cat << EOF >> ${MPI_MODULE_FILES_DIRECTORY}/hpcx-${HPCX_VERSION}
#%Module 1.0
#
#  HPCx ${HPCX_VERSION}
#
conflict        mpi
module load ${HPCX_PATH}/modulefiles/hpcx
EOF

# HPC-X with PMIX
cat << EOF >> ${MPI_MODULE_FILES_DIRECTORY}/hpcx-pmix-${HPCX_VERSION}
#%Module 1.0
#
#  HPCx ${HPCX_VERSION}
#
conflict        mpi
module load ${HPCX_PATH}/modulefiles/hpcx-rebuild
EOF

# MVAPICH2
cat << EOF >> ${MPI_MODULE_FILES_DIRECTORY}/mvapich2-${MVAPICH2_VERSION}
#%Module 1.0
#
#  MVAPICH2 ${MVAPICH2_VERSION}
#
conflict        mpi
module load ${GCC_VERSION}
prepend-path    PATH            /opt/mvapich2-${MVAPICH2_VERSION}/bin
prepend-path    LD_LIBRARY_PATH /opt/mvapich2-${MVAPICH2_VERSION}/lib
prepend-path    MANPATH         /opt/mvapich2-${MVAPICH2_VERSION}/share/man
setenv          MPI_BIN         /opt/mvapich2-${MVAPICH2_VERSION}/bin
setenv          MPI_INCLUDE     /opt/mvapich2-${MVAPICH2_VERSION}/include
setenv          MPI_LIB         /opt/mvapich2-${MVAPICH2_VERSION}/lib
setenv          MPI_MAN         /opt/mvapich2-${MVAPICH2_VERSION}/share/man
setenv          MPI_HOME        /opt/mvapich2-${MVAPICH2_VERSION}
EOF

# OpenMPI
cat << EOF >> ${MPI_MODULE_FILES_DIRECTORY}/openmpi-${OMPI_VERSION}
#%Module 1.0
#
#  OpenMPI ${OMPI_VERSION}
#
conflict        mpi
module load ${GCC_VERSION}
prepend-path    PATH            /opt/openmpi-${OMPI_VERSION}/bin
prepend-path    LD_LIBRARY_PATH /opt/openmpi-${OMPI_VERSION}/lib:${HCOLL_PATH}/lib
prepend-path    MANPATH         /opt/openmpi-${OMPI_VERSION}/share/man
setenv          MPI_BIN         /opt/openmpi-${OMPI_VERSION}/bin
setenv          MPI_INCLUDE     /opt/openmpi-${OMPI_VERSION}/include
setenv          MPI_LIB         /opt/openmpi-${OMPI_VERSION}/lib
setenv          MPI_MAN         /opt/openmpi-${OMPI_VERSION}/share/man
setenv          MPI_HOME        /opt/openmpi-${OMPI_VERSION}
EOF

#IntelMPI-v2021
cat << EOF >> ${MPI_MODULE_FILES_DIRECTORY}/impi_${impi_2021_version}
#%Module 1.0
#
#  Intel MPI ${impi_2021_version}
#
conflict        mpi
module load /opt/intel/oneapi/mpi/${impi_2021_version}/etc/modulefiles/impi/${impi_2021_version}
setenv          MPI_BIN         /opt/intel/oneapi/mpi/${impi_2021_version}/bin
setenv          MPI_INCLUDE     /opt/intel/oneapi/mpi/${impi_2021_version}/include
setenv          MPI_LIB         /opt/intel/oneapi/mpi/${impi_2021_version}/lib
setenv          MPI_MAN         /opt/intel/oneapi/mpi/${impi_2021_version}/share/man
setenv          MPI_HOME        /opt/intel/oneapi/mpi/${impi_2021_version}
# see https://community.intel.com/t5/Intel-MPI-Library/Suspected-unfixed-Intel-MPI-race-condition-in-collectives/td-p/1693452 for Intel MPI bug
setenv          I_MPI_STARTUP_MODE         pmi_shm
EOF

# Create symlinks for modulefiles
ln -s ${MPI_MODULE_FILES_DIRECTORY}/hpcx-${HPCX_VERSION} ${MPI_MODULE_FILES_DIRECTORY}/hpcx
ln -s ${MPI_MODULE_FILES_DIRECTORY}/hpcx-pmix-${HPCX_VERSION} ${MPI_MODULE_FILES_DIRECTORY}/hpcx-pmix
ln -s ${MPI_MODULE_FILES_DIRECTORY}/mvapich2-${MVAPICH2_VERSION} ${MPI_MODULE_FILES_DIRECTORY}/mvapich2
ln -s ${MPI_MODULE_FILES_DIRECTORY}/openmpi-${OMPI_VERSION} ${MPI_MODULE_FILES_DIRECTORY}/openmpi
ln -s ${MPI_MODULE_FILES_DIRECTORY}/impi_${impi_2021_version} ${MPI_MODULE_FILES_DIRECTORY}/impi-2021

# cleanup downloaded tarballs and other installation files/folders
rm -rf *.tbz *.tar.gz *offline.sh
rm -rf -- */