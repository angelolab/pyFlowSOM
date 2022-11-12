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
    alpha_range = (0.05, 0.01),
    radius_range = None,
    distf = 2,
    silent = False,
    codes = None,
    importance = None,
    ):
    """
    Build a self-organizing map

    Parameters
    ----------
    data : np.Typing.NDArray[np.float64]
        2D array containing the training observations
        shape: (observation_count, parameter_count)
    xdim : int
        Width of the grid
    ydim : int
        Height of the grid
    rlen : int
        Number of times to loop over the training data for each MST
    mst : int
        Number of times to build an MST
    alpha_range : Tuple[float, float]
        Start and end learning rate
    radius_range : Tuple[float, float]
        Start and end radius. If None, radius is set to a reasonable value
        value based on the grid size i.e. xdim and ydim
    distf: int
        Distance function to use.
        1 = manhattan
        2 = euclidean
        3 = chebyshev
        4 = cosine
    silent : bool
        Suppress debug print statements
    codes : np.Typing.NDArray[np.float64]
        Cluster centers to start with.
        shape = (xdim * ydim, parameter_count)
        If None, codes are initialized by randomly selecting observations
    importance : np.Typing.NDArray[np.float64]
        Scale parameters columns of input data an importance weight
        shape = (parameter_count,)

    Returns
    -------
    np.Typing.NDArray[]
    """

    nhbrdist = [0,1,2,3,4,5,6,7,8,9] # fixme, replace with real, non-testdummy

    if radius_range is None:
        radius_range = (np.percentile(nhbrdist, 0.67), 0)

def map_data_to_codes(codes, newdata, distf=2):
    """Assign nearest node to each obersevation in newdata

    Both codes and newdata must represent the same parameters, in the same order.

    Parameters
    ----------
    codes : np.typing.NDArray[np.float64]
        Nodes of the SOM.
        shape = (node_count, parameter_count)
        Fortan contiguous preffered
    newdata: np.typing.NDArray[np.float64]
        New observations to assign nodes.
        shape = (observation_count, parameter_count)
        Fortan contiguous preffered
    distf: int
        Distance function to use.
        1 = manhattan
        2 = euclidean
        3 = chebyshev
        4 = cosine

    Returns
    -------
    (np.typing.NDArray[np.int32], np.typing.NDArray[np.float64])
        The first array contains the node index assigned to each observation.
            shape = (observation_count,)
        The second array contains the distance to the node for each observation.
            shape = (observation_count,)

    """

    if not codes.flags['F_CONTIGUOUS']:
        codes = np.asfortranarray(codes)
    cdef double[::1,:] codes_mv = codes
    cdef Py_ssize_t codes_rows = codes.shape[0]
    cdef Py_ssize_t codes_cols = codes.shape[1]

    if not newdata.flags['F_CONTIGUOUS']:
        newdata = np.asfortranarray(newdata)
    cdef double[::1,:] newdata_mv = newdata
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