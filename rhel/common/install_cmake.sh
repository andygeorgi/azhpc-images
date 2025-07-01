#!/bin/bash
set -ex

#update CMAKE
cmake_version=3.31.7
cmake_url=https://github.com/Kitware/CMake/releases/download/v3.31.7/cmake-3.31.7-linux-x86_64.tar.gz
cmake_sha256=14e15d0b445dbeac686acc13fe13b3135e8307f69ccf4c5c91403996ce5aa2d4
TARBALL="cmake-${cmake_version}-linux-x86_64.tar.gz"

$COMMON_DIR/download_and_verify.sh ${cmake_url} ${cmake_sha256}
tar -xzf ${TARBALL}
pushd cmake-${cmake_version}-linux-x86_64
cp -f bin/{ccmake,cmake,cpack,ctest} /usr/local/bin
cp -rf share/cmake-* /usr/local/share/
popd
hash -r

$COMMON_DIR/write_component_version.sh "CMAKE" ${cmake_version}

# Remove installation files
rm -rf cmake-${cmake_version}-linux-x86_64*