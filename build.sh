#!/bin/bash

# Setup the config

source build.conf

# Build the .so containing the Python library and add it to the package folder
cd src
if ! ./build.sh "$archive_url" $archive_sha256; then
    echo "[Build] Fatal error."
    exit 1
fi
cd ..

# Calculate the installed size

egg_info_du=$(du --block-size 1K package/usr/lib/python3/dist-packages/NetfilterQueue-0.7.egg-info | cut -f1)
so_du=$(du --block-size 1K package/usr/lib/python3/dist-packages/netfilterqueue.cpython* | cut -f1)

du_total=$(( $egg_info_du + $so_du ))

echo "Package installed size: $du_total kilobytes"

# Get the current python3 version (we don't support python2)

py3_version=$(python3 -c "import sys; print(sys.version_info.minor)")
py3_nextversion=$(( $py3_version + 1 ))

echo "Current Python 3 version: $py3_version, next version: $py3_nextversion"

# Determine the architecture. Note that this has only ever been tested on amd64.
# The documentation does seem to suggest that it would work at least for i386.
architecture=$(uname -m)
if [[ $architecture == "x86_64" ]]; then
    architecture="amd64"
fi

cat > package/DEBIAN/control << EOF
Package: python3-netfilterqueue
Version: $package_version
Source: kti/python-netfilterqueue ($package_version)
Architecture: $architecture
Essential: no
Section: web
Priority: optional
Depends: python3 (>=3.$py3_version), python3(<<3.$py3_nextversion), libnetfilter-queue1
Build-Depends: python3-dev (>=3.$py3_version), python3-dev (<<3.$py3_nextversion), libnetfilter-queue-dev, python3-setuptools
Maintainer: Ethan L. White
Installed-Size: $du_total
Description: An object-oriented Python interface to libnetfilter_queue (Python 3 version)
 This package provides an alternative to python-nfqueue as a binding for libnetfilter_queue.
X-Python3-Version: >=3.$py3_version <<3.$py3_nextversion
EOF

dpkg -b package/ python3-netfilterqueue_$package_version_$architecture.deb