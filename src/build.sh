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

url=$1
filename=$(echo $url | rev | cut -d/ -f1 | rev)
sha256=$2

echo "[Build] Downloading archive, verifying sha256, and extracting..."

wget $url

if [[ $(sha256sum $filename | cut "-d " -f1) != $sha256 ]]; then
    echo "[Build] FATAL: SHA256 doesn't match. Abort."
    exit 1
else
    echo "[Build] SHA256 matches. (= $sha256)"
fi

# Double reverse to prevent head from killing tar after it's got its one line
dirname=$(tar xzvf $filename | rev | rev | head -1 | cut -d/ -f1)
cp $dirname/* .
rm -r $dirname
rm $filename

echo "[Build] Creating virtualenv..."

virtualenv . -p $(which python3)

echo "[Build] Installing netfilterqueue in virtualenv..."

source bin/activate
python setup.py install

echo "[Build] Copying binaries to package directory..."

src_dir=$(pwd)
cd lib/python3*/site-packages
cp NetfilterQueue*.egg-info $src_dir/../package/usr/lib/python3/dist-packages
cp netfilterqueue*.so $src_dir/../package/usr/lib/python3/dist-packages
cd $src_dir
deactivate
