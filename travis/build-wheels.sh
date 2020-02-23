#!/bin/bash
set -e -x

# Install a system package required by our library
#yum install -y atlas-devel

cd /io/
git clone https://github.com/c-f-h/ilupp.git

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    #"${PYBIN}/pip" install -r /io/dev-requirements.txt
    "${PYBIN}/pip" install nose pybind11 numpy scipy
    "${PYBIN}/pip" wheel /io/ilupp/ -w wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair "$whl" --plat $PLAT -w /io/wheelhouse/
done

# Install packages and test
for PYBIN in /opt/python/*/bin/; do
    "${PYBIN}/pip" install ilupp --no-index -f /io/wheelhouse
    "${PYBIN}/nosetests" /io/ilupp/test/
done
