cdef extern from "flowsom.c":
    void C_SOM(
        double *data,
        double *codes,
        double *nhbrdist,
        double alpha_start,
        double alpha_end,
        double radius_start,
        double radius_end,
        double *xdists,
        int n,
        int px,
        int ncodes,
        int rlen,
        int dist
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
import scipy

def neighborhood_distance(xdim, ydim):
    # grid is basically list of all coordinates in neighborhood
    #
    # [19]: np.meshgrid(np.arange(1,3+1), np.arange(1,3+1))
    # Out[19]:
    # [array([[1, 2, 3],
    #         [1, 2, 3],
    #         [1, 2, 3]]),
    #  array([[1, 1, 1],
    #         [2, 2, 2],
    #         [3, 3, 3]])]
    grid = np.meshgrid(np.arange(1, xdim + 1), np.arange(1, ydim + 1))
    grid = np.column_stack((grid[0].flat, grid[1].flat))
    # setting p=inf is the same as chebyshev distance, or Maximal distance
    return scipy.spatial.distance_matrix(grid, grid, p=float('inf'))

def som(
    data,
    xdim = 10,
    ydim = 10,
    rlen = 10,
    alpha_range = (0.05, 0.01),
    radius_range = None,
    distf = 2,
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
    nhbrdist = neighborhood_distance(xdim, ydim)

    if radius_range is None:
        # Let the radius have a sane default value based on the grid size
        radius_range = (np.percentile(nhbrdist.flatten(), 67), 0)

    nCodes = xdim * ydim
    if codes is None:
        # If we don't supply codes, we randomly sample them from the data
        codes = data[np.random.choice(data.shape[0], xdim * ydim, replace=False), :]

    if not data.flags['F_CONTIGUOUS']:
        data = np.asfortranarray(data)
    cdef double[::1,:] data_mv = data
    cdef Py_ssize_t data_rows = data.shape[0]
    cdef Py_ssize_t data_cols = data.shape[1]


    if not codes.flags['F_CONTIGUOUS']:
        codes = np.asfortranarray(codes)
    cdef double[::1,:] codes_mv = codes
    cdef Py_ssize_t codes_rows = codes.shape[0]
    cdef Py_ssize_t codes_cols = codes.shape[1]

    if not nhbrdist.flags['F_CONTIGUOUS']:
        nhbrdist = np.asfortranarray(nhbrdist)
    cdef double[::1,:] nhbrdist_mv = nhbrdist
    cdef Py_ssize_t nhbrdist_rows = nhbrdist.shape[0]
    cdef Py_ssize_t nhbrdist_cols = nhbrdist.shape[1]

    if codes_cols != data_cols:
        raise Exception(f"When passing codes, it must have the same number of columns as the data, codes has {codes_cols} columns, data has {data_cols} columns")
    if codes_rows != xdim * ydim:
        raise Exception(f"When passing codes, it must have the same number of rows as xdim * ydim. Codes has {codes_rows} rows, xdim * ydim = {xdim * ydim}")

    if importance is not None:
        # scale the data by the importance weights
        raise NotImplementedError("importance weights not implemented yet")

    xDists = np.arange(nCodes, dtype=np.float64)
    cdef double [:] xDists_mv = xDists

    print("calling C_SOM")
    print("\n**********")
    print(alpha_range[0])
    print(alpha_range[1])
    print(radius_range[0])
    print(radius_range[1])
    print(data_rows)
    print(data_cols)
    print(nCodes)
    print(rlen)
    print(distf)

    C_SOM(
        &data_mv[0, 0],
        &codes_mv[0, 0],
        &nhbrdist_mv[0, 0],
        alpha_range[0],
        alpha_range[1],
        radius_range[0],
        radius_range[1],
        &xDists_mv[0],
        data_rows,
        data_cols,
        nCodes,
        rlen,
        distf
        )

    return codes


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