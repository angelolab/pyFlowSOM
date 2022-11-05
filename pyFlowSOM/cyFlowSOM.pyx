cdef extern from "flowsom.c":
    void C_square_each(double *, unsigned int)
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
        int *pncodes,
        int *pnd,
        int *pp,
        int *nnCodes,
        double *nnDists,
        int *dist
        )

import numpy as np

def square_each(np_mat):
    if not np_mat.flags['C_CONTIGUOUS']:
        raise ValueError("Array must be C contiguous")

    cdef double[:,::1] mat = np_mat

    if not mat.shape[0] == mat.shape[1]:
        raise ValueError("Matrix must be square")

    C_square_each(&mat[0, 0], mat.shape[0])

    return mat

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
    pass
#     nnCodes C_mapDataToCodes(
#         as.double(newdata[, colnames(codes)]),
#         as.double(codes),
#         as.integer(nrow(codes)),
#         as.integer(nrow(newdata)),
#         as.integer(ncol(codes)),
#         nnCodes = integer(nrow(newdata)),
#         nnDists = double(nrow(newdata)),
#         distf = distf
#         )
#   return(cbind(nnCodes$nnCodes, nnCodes$nnDists))