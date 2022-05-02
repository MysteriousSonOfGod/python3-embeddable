#!/bin/bash

set -e
set -x

# Install requirements
brew install xz #openssl

#if [ $ARCH = "x86_64" ] || [ $ARCH = "universal2" ]; then
#    echo "Building Python for $ARCH"
#    mkdir $ARCH    
#    cd $ARCH
#else
#    echo "Unsupported platform"
#    exit 1
#fi

COMMON_ARGS="--arch ${ARCH:-universal2}"

# Initialize variables
THIS_DIR="$PWD"
SRCDIR=src/Python-$PYVER

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

# Copy build tools to the Python's source dir
cp -R MacOS $SRCDIR

pushd $SRCDIR

# Install dependencies
which python
python -m pip install dataclasses

# Build the Python dependencies
./MacOS/build_deps.py $COMMON_ARGS

#Configure the Python compilation
./MacOS/configure.py $COMMON_ARGS --prefix=/usr "$@"

# Make Python from source
make
make install DESTDIR="$THIS_DIR/build"

popd

# Create the embeddable dir and moves Python distribution into it
mkdir -p embedabble
mv build/usr/* embedabble