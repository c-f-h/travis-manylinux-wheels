#!/bin/bash

GHUSER=$1
GHREPO=$2
BRANCH=$3

PYDIRS="
/opt/python/cp35-cp35m/bin
/opt/python/cp36-cp36m/bin
/opt/python/cp37-cp37m/bin
/opt/python/cp38-cp38/bin
"

set -e -x

# Install a system package required by our library
#yum install -y atlas-devel

cd /io/
git clone -b $BRANCH https://github.com/$GHUSER/$GHREPO.git

# Compile wheels
for PYBIN in $PYDIRS; do
    #"${PYBIN}/pip" install -r /io/dev-requirements.txt
    "${PYBIN}/pip" install nose pybind11 numpy scipy
    "${PYBIN}/pip" wheel /io/$GHREPO/ -w wheelhouse/
done

rm wheelhouse/numpy*
rm wheelhouse/scipy*

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair "$whl" --plat $PLAT -w /io/wheelhouse/
done

# Install packages and test
for PYBIN in $PYDIRS; do
    "${PYBIN}/pip" install $GHREPO --no-index -f /io/wheelhouse
    "${PYBIN}/nosetests" /io/$GHREPO/test/
done
