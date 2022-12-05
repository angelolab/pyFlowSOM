[![Build Status](https://travis-ci.com/angelolab/pyFlowSOM.svg?branch=master)](https://travis-ci.com/angelolab/pyFlowSOM)
[![Coverage Status](https://coveralls.io/repos/github/angelolab/pyFlowSOM/badge.svg?branch=main)](https://coveralls.io/github/angelolab/pyFlowSOM?branch=main)

# pyFlowSOM

Python runner for the [FlowSOM](https://github.com/SofieVG/FlowSOM) library.

# Develop

Continually build and test while developing. This will automatically create your virtual env

    ./build.sh && ./test.sh

The C code (`pyFlowSOM/flosom.c`) is wrapped using Cython (`pyFlowSOM/cyFlowSOM.c`).

Tests do an approximate exact comparison to cluster id groundtruth and an approximate comparison to node values only because of floating point differences. All randomness has stubbed out in in the y2kbugger/FlowSOM fork and works in tandem to the `deterministic` flag to the `som` function.
