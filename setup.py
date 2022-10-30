from setuptools import Extension, setup


pyflowsom_module = Extension('pyflowsom',
                    sources = ['pyflowsom.c'])

setup (name = 'pyflowsom',
       ext_modules = [pyflowsom_module])