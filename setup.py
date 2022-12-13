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
    name='pyFlowSOM',
    use_scm_version=True,
    setup_requires=['setuptools_scm'],
    packages=['pyFlowSOM'],
    python_requires=">=3.8",
    ext_modules = cythonize('pyFlowSOM/cyFlowSOM.pyx', language_level="3"),
    license='Modified Apache License 2.0',
    description='A Python implementation of the SOM training functionality of FlowSOM',
    author='Angelo Lab',
    url='https://github.com/angelolab/pyFlowSOM',
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
