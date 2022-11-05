cdef extern from "flowsom.c":
    void C_SOM(
        double *data,
        double *codes,
        double *nhbrdist,
        double *alphas,
        double *radii,
        double *xdists,
        int *pn,
        int *ppx,
        int *pncodes,
        int *prlen,
        int *dist
        )
    void C_mapDataToCodes(
        double *data,
        double *codes,
        int pncodes,
        int pnd,
        int pp,
        int *nnCodes,
        double *nnDists,
        int dist
        )

import numpy as np

def som(
    data,
    xdim = 10,
    ydim = 10,
    rlen = 10,
    mst = 1,
    alpha = [0.05, 0.01],
    radius = lambda dist: [np.percentile(dist, 0.67), 0],
    distf = 2,
    silent = False,
    map = False,
    codes = None,
    importance = None,
    ):
    pass

def map_data_to_codes(codes, newdata, distf=2):
    """Assign nearest node to each datapoint

    Parameters:
        codes: matrix with nodes of the SOM
        newdata: matrix with datapoints to assign
        distf: Distance function (1 = manhattan, 2 = euclidean, 3 = chebyshev, 4 = cosine)

    Returns:
        Array with nearest node id for each datapoint

    """

    if not codes.flags['F_CONTIGUOUS']:
        codes = np.ascontiguousarray(codes)
    cdef double[::1,:] codes_mv = codes

    if not newdata.flags['F_CONTIGUOUS']:
        newdata = np.ascontiguousarray(newdata)
    cdef double[::1,:] newdata_mv = newdata

    cdef Py_ssize_t codes_rows = codes.shape[0]
    cdef Py_ssize_t codes_cols = codes.shape[1]
    cdef Py_ssize_t newdata_rows = newdata.shape[0]
    cdef Py_ssize_t newdata_cols = newdata.shape[1]

    nnCodes = np.arange(newdata_rows, dtype=np.dtype("i"))
    nnDists = np.arange(newdata_rows, dtype=np.float64)
    cdef int [:] nnCodes_mv = nnCodes
    cdef double [:] nnDists_mv = nnDists

    C_mapDataToCodes(
        &newdata_mv[0, 0],
        &codes_mv[0, 0],
        codes_rows,
        newdata_rows,
        codes_cols,
        &nnCodes_mv[0],
        &nnDists_mv[0],
        distf
        )

    return (nnCodes, nnDists)