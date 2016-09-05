#!/bin/bash
# The author (Ethan White) of this code dedicates any and all copyright interest
# in this code to the public domain. The author makes this dedication for the
# benefit of the public at large and to the detriment of his heirs and
# successors. The author intends this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this code
# under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

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

echo "Python 3 version: 3.$py3_version, next version: 3.$py3_nextversion"

architecture=$(dpkg --print-architecture)

cat > package/DEBIAN/control << EOF
Package: python3-netfilterqueue
Version: $package_version
Source: https://github.com/kti/python-netfilterqueue
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

dpkg -b package/ python3-netfilterqueue_${package_version}_${architecture}.deb
