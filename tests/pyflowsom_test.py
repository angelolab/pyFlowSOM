from pathlib import Path

import numpy as np
import pandas as pd
import pytest

from pyFlowSOM import map_data_to_nodes, som

THIS_DIR = Path(__file__).parent
EX_DIR = THIS_DIR.parent / 'examples'


@pytest.fixture(scope='session')
def example_som_input_df():
    """Each row is a pixel, each column is a marker

    Returns the df with marker names
    """
    np.random.seed(42)
    return pd.DataFrame(np.random.rand(500, 16))


@pytest.fixture()
def example_som_input(example_som_input_df):
    """Each row is a pixel, each column is a marker
    original image could be: 66 x 631 = 41,646
    """
    arr = example_som_input_df.to_numpy(copy=True)
    assert arr.shape == (500, 16)
    assert arr.dtype == np.dtype("d")
    return arr


@pytest.fixture(scope='session')
def example_node_output_df():
    """Each row is a node, each column is a marker

    Returns the df with marker names
    """
    return pd.read_csv(EX_DIR / 'example_node_output.csv', dtype=np.dtype("d"))


@pytest.fixture()
def example_node_output(example_node_output_df):
    """Each row is a node, each column is a marker"""
    arr = example_node_output_df.to_numpy(copy=True)
    assert arr.shape == (100, 16)
    assert arr.dtype == np.dtype("d")
    return arr


@pytest.fixture(scope='session')
def example_cluster_groundtruth_df():
    return pd.read_csv(
        EX_DIR / 'example_clusters_output.csv',
        usecols=["cluster"], dtype=np.dtype("i"))


@pytest.fixture()
def example_cluster_groundtruth(example_cluster_groundtruth_df):
    """Each row is a cluster, each column is a marker"""
    arr = example_cluster_groundtruth_df['cluster'].to_numpy(copy=True)
    assert arr.shape == (500,)
    assert arr.dtype == np.dtype("i")
    return arr


def test_map_data_to_nodes(example_som_input, example_node_output, example_cluster_groundtruth):
    nodes, dists = map_data_to_nodes(example_node_output, example_som_input)

    assert nodes.shape == (500,)
    assert dists.shape == (500,)
    np.testing.assert_array_equal(example_cluster_groundtruth, nodes)


def test_map_data_to_nodes_handles_c_continuous_arrays(
        example_som_input,
        example_node_output,
        example_cluster_groundtruth):

    cluster, dists = map_data_to_nodes(example_node_output, example_som_input)

    assert cluster.shape == (500,)
    assert dists.shape == (500,)
    np.testing.assert_array_equal(example_cluster_groundtruth, cluster)


def test_som_and_check_node_output(example_som_input, example_node_output):
    node_output = som(example_som_input, xdim=10, ydim=10, rlen=10)

    assert node_output.shape == (100, 16)
    assert example_node_output.shape == (100, 16)
    np.testing.assert_allclose(node_output, example_node_output)


def test_som_and_map_end_to_end_and_check_clusters(example_som_input, example_cluster_groundtruth):
    node_output = som(example_som_input, xdim=10, ydim=10, rlen=10)
    clusters, dists = map_data_to_nodes(node_output, example_som_input)

    assert example_cluster_groundtruth.shape == clusters.shape
    np.testing.assert_array_equal(example_cluster_groundtruth, clusters)
