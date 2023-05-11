cdef extern from "flowsom.c":
    void C_SEED_RAND(unsigned int seed)
    void C_SOM(
        double *data,
        double *nodes,
        double *nhbrdist,
        double alpha_start,
        double alpha_end,
        double radius_start,
        double radius_end,
        double *xdists,
        int n,
        int px,
        int n_nodes,
        int rlen,
        int dist
        )
    void C_mapDataToNodes(
        double *data,
        double *nodes,
        int n_nodes,
        int nd,
        int p,
        int *nn_nodes,
        double *nn_dists,
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
    nodes = None,
    importance = None,
    seed=42,
    ):
    """
    Build a self-organizing map

    Parameters
    ----------
    data : np.Typing.NDArray[np.dtype("d")]
        2D array containing the training observations
        shape: (observation_count, parameter_count)
    xdim : int
        Width of the grid
    ydim : int
        Height of the grid
    rlen : int
        Number of times to loop over the training data for each MST
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
    nodes : np.Typing.NDArray[np.dtype("d")]
        Cluster centers to start with.
        shape = (xdim * ydim, parameter_count)
        If None, nodes are initialized by randomly selecting observations
    importance : np.Typing.NDArray[np.dtype("d")]
        Scale parameters columns of input data an importance weight
        shape = (parameter_count,)
    seed : int
        The random seed to use for node initialization, ignored if nodes is None.
        If None, runs with fully stochastic node initialization.

    Returns
    -------
    np.Typing.NDArray[]
    """
    nhbrdist = neighborhood_distance(xdim, ydim)

    if radius_range is None:
        # Let the radius have a sane default value based on the grid size
        radius_range = (np.percentile(nhbrdist.flatten(), 67), 0)

    n_nodes = xdim * ydim
    if nodes is None:
        # If we don't supply nodes, then initialize a seed and randomly sample xdim * ydim rows
        np.random.seed(seed)
        nodes = data[np.random.choice(data.shape[0], xdim * ydim, replace=False), :]

    if not data.flags['F_CONTIGUOUS']:
        data = np.asfortranarray(data)

    assert data.dtype == np.dtype("d")
    cdef double[::1,:] data_mv = data
    data_rows = data.shape[0]
    data_cols = data.shape[1]

    if not nodes.flags['F_CONTIGUOUS']:
        nodes = np.asfortranarray(nodes)

    assert nodes.dtype == np.dtype("d")
    cdef double[::1,:] nodes_mv = nodes
    nodes_rows = nodes.shape[0]
    nodes_cols = nodes.shape[1]

    if not nhbrdist.flags['F_CONTIGUOUS']:
        nhbrdist = np.asfortranarray(nhbrdist)

    assert nhbrdist.dtype == np.dtype("d")
    cdef double[::1,:] nhbrdist_mv = nhbrdist

    if nodes_cols != data_cols:
        raise Exception(f"When passing nodes, it must have the same number of columns as the data, nodes has {nodes_cols} columns, data has {data_cols} columns")
    if nodes_rows != xdim * ydim:
        raise Exception(f"When passing nodes, it must have the same number of rows as xdim * ydim. nodes has {nodes_rows} rows, xdim * ydim = {xdim * ydim}")

    if importance is not None:
        # scale the data by the importance weights
        raise NotImplementedError("importance weights not implemented yet")

    xDists = np.zeros(n_nodes, dtype=np.dtype("d"))
    cdef double [:] xDists_mv = xDists

    if seed is not None:
        C_SEED_RAND(seed)
    else:
        C_SEED_RAND(np.random.randint(low=1, high=65535))

    C_SOM(
        &data_mv[0, 0],
        &nodes_mv[0, 0],
        &nhbrdist_mv[0, 0],

        alpha_range[0],
        alpha_range[1],

        radius_range[0],
        radius_range[1],

        &xDists_mv[0],

        data_rows,
        data_cols,

        n_nodes,

        rlen,
        distf
        )

    return nodes


def map_data_to_nodes(nodes, newdata, distf=2):
    """Assign nearest node to each obersevation in newdata

    Both nodes and newdata must represent the same parameters, in the same order.

    Parameters
    ----------
    nodes : np.typing.NDArray[np.dtype("d")]
        Nodes of the SOM.
        shape = (node_count, parameter_count)
        Fortan contiguous preffered
    newdata: np.typing.NDArray[np.dtype("d")]
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
    (np.typing.NDArray[dtype("i")], np.typing.NDArray[np.dtype("d")])
        The first array contains the node index assigned to each observation.
            shape = (observation_count,)
        The second array contains the distance to the node for each observation.
            shape = (observation_count,)

    """

    if not nodes.flags['F_CONTIGUOUS']:
        nodes = np.asfortranarray(nodes)
    cdef double[::1,:] nodes_mv = nodes
    nodes_rows = nodes.shape[0]
    nodes_cols = nodes.shape[1]

    if not newdata.flags['F_CONTIGUOUS']:
        newdata = np.asfortranarray(newdata)
    cdef double[::1,:] newdata_mv = newdata
    newdata_rows = newdata.shape[0]
    newdata_cols = newdata.shape[1]

    nnClusters = np.zeros(newdata_rows, dtype=np.dtype("i"))
    nnDists = np.zeros(newdata_rows, dtype=np.dtype("d"))
    cdef int [:] nnClusters_mv = nnClusters
    cdef double [:] nnDists_mv = nnDists

    C_mapDataToNodes(
        &newdata_mv[0, 0],
        &nodes_mv[0, 0],
        nodes_rows,
        newdata_rows,
        nodes_cols,
        &nnClusters_mv[0],
        &nnDists_mv[0],
        distf
        )

    return (nnClusters, nnDists)
