from os import path, pardir
from setuptools import Extension, setup, find_packages

VERSION = '0.1.0'

PKG_FOLDER = path.abspath(path.join(__file__, pardir))

def read_reqs(filename):
    with open(path.join(PKG_FOLDER, filename)) as f:
        return f.read().splitlines()

# set a long description which is basically the README
with open(path.join(PKG_FOLDER, 'README.md')) as f:
    long_description = f.read()

pyflowsom_module = Extension('pyflowsom',
    sources = [
        'pyFlowSOM/pyflowsom.c',
        ]
    )

setup(
    name='pyFlowSOM',
    version=VERSION,
    packages=find_packages(),
    ext_modules = [pyflowsom_module],
    license='Modified Apache License 2.0',
    description='A Python implementation of the SOM training functionality of FlowSOM',
    author='Angelo Lab',
    url='https://github.com/angelolab/pyFlowSOM',
    download_url='https://github.com/angelolab/pyFlowSOM/archive/v{}.tar.gz'.format(VERSION),
    install_requires=read_reqs('requirements.txt'),
    extras_require={
        'tests': read_reqs('requirements-test.txt')
    },
    long_description=long_description,
    long_description_content_type='text/markdown',
    classifiers=['License :: OSI Approved :: Apache Software License',
                 'Development Status :: 4 - Beta',
                 'Programming Language :: Python :: 3',
                 'Programming Language :: Python :: 3.8']
)
