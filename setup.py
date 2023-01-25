from os import pardir, path

from Cython.Build import cythonize
from setuptools import Extension, setup

PKG_FOLDER = path.abspath(path.join(__file__, pardir))

def read_reqs(filename):
    with open(path.join(PKG_FOLDER, filename)) as f:
        return f.read().splitlines()

# set a long description which is basically the README
with open(path.join(PKG_FOLDER, 'README.md')) as f:
    long_description = f.read()

setup(
    ext_modules = cythonize('src/pyFlowSOM/cyFlowSOM.pyx', language_level="3"),
    extras_require={
        'tests': read_reqs('requirements-test.txt')
    },
)
