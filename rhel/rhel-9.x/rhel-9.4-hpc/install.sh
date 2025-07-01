#!/bin/bash
set -ex

# set properties
source ./set_properties.sh

# install utils
./install_utils.sh

# Install Lustre client
# No kernel support yet
#./install_lustre_client.sh "9"

# update cmake
$RHEL_COMMON_DIR/install_cmake.sh

# install compilers
./install_gcc.sh

# install nvidia DOCA
./install_doca.sh

# install mpi libraries
#./install_mpis.sh

# install nvidia gpu driver
#./install_nvidiagpudriver.sh

# install AMD tuned libraries
#./install_amd_libs.sh

# install Intel libraries
#./install_intel_libs.sh

# cleanup downloaded tarballs - clear some space
rm -rf *.tgz *.bz2 *.tbz *.tar.gz *.run *.deb *_offline.sh *.repo
rm -rf /tmp/MLNX_OFED_LINUX* /tmp/*conf*
rm -rf /var/intel/ /var/cache/*
rm -Rf -- */

# Install NCCL
#./install_nccl.sh

# Install NVIDIA docker container
#$COMMON_DIR/../rhel/rhel-9.x/common/install_docker.sh

# Install DCGM
#./install_dcgm.sh

# optimizations
#./hpc-tuning.sh

# install persistent rdma naming
#$COMMON_DIR/install_azure_persistent_rdma_naming.sh

# add udev rule
#$COMMON_DIR/../rhel/common/add-udev-rules.sh

# add interface rules
#$COMMON_DIR/../rhel/common/network-config.sh

# install diagnostic script
#$COMMON_DIR/install_hpcdiag.sh

#install monitoring tools
#$COMMON_DIR/../rhel/common/install_monitoring_tools.sh

# install Azure/NHC Health Checks
#$COMMON_DIR/install_health_checks.sh

# copy test file
#$COMMON_DIR/copy_test_file.sh

# disable cloud-init
#$RHEL_COMMON_DIR/disable_cloudinit.sh

# SKU Customization
#$COMMON_DIR/setup_sku_customizations.sh

# Hotfix for RHEL 9 until official CC support is released
#mv /bin/hostnamectl /bin/hostnamectl_org
#cat << "EOF" >>/bin/hostnamectl
##!/bin/bash
#/bin/hostnamectl_org "$@" | grep -v -i "chassis"
#EOF
 
#chmod +x /bin/hostnamectl

# clear history
# Uncomment the line below if you are running this on a VM
# $COMMON_DIR/clear_history.sh

# add a security patch of CVE issue for AlmaLinux 8.7 only
#./disable_user_namespaces.sh