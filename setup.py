from os import path

from Cython.Build import cythonize
from setuptools import Extension, setup

CYTHON_DEBUG = False

if CYTHON_DEBUG:
    from Cython.Compiler.Options import get_directive_defaults

    directive_defaults = get_directive_defaults()
    directive_defaults["linetrace"] = True
    directive_defaults["binding"] = True

CYTHON_MACROS = [("CYTHON_TRACE", "1")] if CYTHON_DEBUG else None


extensions = [
    Extension(
        name="pyFlowSOM.cyFlowSOM",
        sources=[path.join("src", "pyFlowSOM", "cyFlowSOM.pyx")],
        define_macros=CYTHON_MACROS,
    )
]

setup(
    ext_modules = cythonize(extensions, compiler_directives={"language_level": "3"}),
)
