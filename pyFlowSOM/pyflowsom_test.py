from pathlib import Path

import numpy as np
import pandas as pd
import pytest

from . import map_data_to_codes, som

THIS_DIR = Path(__file__).parent


@pytest.fixture(scope='session')
def example_som_input():
    """Each row is a pixel, each column is a marker
    original image could be: 66 x 631 = 41,646
    """
    df = pd.read_csv(THIS_DIR.parent / 'examples' / 'example_som_input.csv')
    arr = df.to_numpy()
    assert arr.shape == (41646, 16)
    assert arr.dtype == np.float64
    return arr


@pytest.fixture(scope='session')
def example_node_output():
    """Each row is a node, each column is a marker
    """
    df = pd.read_csv(THIS_DIR.parent / 'examples' / 'example_node_output.csv')
    arr = df.to_numpy()
    assert arr.shape == (100, 16)
    assert arr.dtype == np.float64
    return arr


@pytest.fixture(scope='session')
def example_cluster_groundtruth():
    """Each row is a cluster, each column is a marker
    """
    df = pd.read_csv(THIS_DIR.parent / 'examples' / 'example_clusters_output.csv')
    arr = df['cluster'].to_numpy()
    assert arr.shape == (41646,)
    assert arr.dtype == np.int
    return arr


def test_som_runs(example_som_input):
    som_out = som(example_som_input, xdim=10, ydim=10, rlen=10)


def test_map_data_to_codes(example_som_input, example_node_output, example_cluster_groundtruth):
    codes, dists = map_data_to_codes(example_node_output, example_som_input)

    assert codes.shape == (41646,)
    assert dists.shape == (41646,)
    assert np.array_equal(example_cluster_groundtruth, codes)


def test_map_data_to_codes_handles_c_continuous_arrays(
        example_som_input,
        example_node_output,
        example_cluster_groundtruth):

    cluster, dists = map_data_to_codes(example_node_output, example_som_input)

    assert cluster.shape == (41646,)
    assert dists.shape == (41646,)
    assert np.array_equal(example_cluster_groundtruth, cluster)


def test_som_and_check_node_output(example_som_input, example_node_output):
    node_output = som(example_som_input, xdim=10, ydim=10, rlen=10)

    assert node_output.shape == (100, 16)
    assert example_node_output.shape == (100, 16)
    assert np.testing.assert_array_almost_equal(node_output, example_node_output, decimal=3)


def test_som_and_map_end_to_end_and_check_clusters(example_som_input, example_cluster_groundtruth):
    node_output = som(example_som_input, xdim=10, ydim=10, rlen=10)
    clusters, dists = map_data_to_codes(node_output, example_som_input)

    assert example_cluster_groundtruth.shape == clusters.shape
    assert np.array_equal(example_cluster_groundtruth, clusters)


def test_som_and_map_end_to_end_and_save_results(example_som_input, example_cluster_groundtruth):

    node_output = som(example_som_input, xdim=10, ydim=10, rlen=10)
    clusters, dists = map_data_to_codes(node_output, example_som_input)

    import pandas as pd
    pd.DataFrame(clusters, columns=("cluster",)) \
        .to_csv('clusters_from_python.csv', index=False)
    pd.DataFrame(example_cluster_groundtruth, columns=("cluster",)) \
        .to_csv('clusters_from_example.csv', index=False)
