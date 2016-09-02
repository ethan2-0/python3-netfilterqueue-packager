#!/bin/bash

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

cp lib/python3*/site-packages/NetfilterQueue-0.7.egg-info ../package/usr/lib/python3/dist-packages
# Note: This assumes that there is only one .so in lib/python3*/site-packages.
# This is true right now; but it may require updating in later versions of the script
cp lib/python3*/site-packages/*.so ../package/usr/lib/python3/dist-packages
deactivate
