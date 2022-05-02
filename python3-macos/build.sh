#!/bin/bash

set -e
set -x

if [ $ARCH = "x86_64" ] || [ $ARCH = "universal2" ]; then
    echo "Building Python for $ARCH"
    mkdir $ARCH    
    cd $ARCH
else
    echo "Unsupported platform"
    exit 1
fi

# Initialize variables
THIS_DIR="$PWD"
PY_SRC_DIR=src/Python-$PYVER

# Clear the last build
if [ -d src ]; then rm -Rf src; fi
if [ -d build ]; then rm -Rf build; fi
if [ -d embedabble ]; then rm -Rf embedabble; fi

# Create the Python source dir
mkdir -p src
pushd src

# Download Python
curl -vLO https://www.python.org/ftp/python/$PYVER/Python-$PYVER.tar.xz
tar --no-same-owner -xf Python-$PYVER.tar.xz

popd

# ---------------- #

# Copy our custom build-script to the BuildScript folder
yes | cp ../MacOS/build-installer.py $PY_SRC_DIR/Mac/BuildScript/

pushd $PY_SRC_DIR

# Runs the build-script
if [ $ARCH = "universal2" ]; then
  python3 Mac/BuildScript/build-installer.py --build-dir="$THIS_DIR/build" --third-party="$THIS_DIR/build/third-party" --dep-target=10.6 --universal-archs=universal2
else
  python3 Mac/BuildScript/build-installer.py --build-dir="$THIS_DIR/build" --third-party="$THIS_DIR/build/third-party" --dep-target=10.6
fi

popd

# Create the embeddable dir and moves Python distribution into it
PYSIMPLEVER=$(cut -d '.' -f 1,2 <<< "$PYVER")
mkdir -p embedabble
mv "build/_root/Library/Frameworks/Python.framework/Versions/$PYSIMPLEVER/*" embedabble