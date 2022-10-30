from distutils.core import setup, Extension

pyflowsom_module = Extension('pyflowsom',
                    sources = ['pyflowsom.c'])

setup (name = 'pyflowsom',
       version = '1.0',
       description = 'Python wrapper for the FlowSOM algorithm.',
       ext_modules = [pyflowsom_module])