import pytest
import pandas as pd
from pathlib import Path
import numpy as np

from . import som, map_data_to_codes

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
    """Each row is a cluster, each column is a marker
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


def test_som(example_som_input):
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

    codes, dists = map_data_to_codes(example_node_output, np.ascontiguousarray(example_som_input))
    assert codes.shape == (41646,)
    assert dists.shape == (41646,)
    assert np.array_equal(example_cluster_groundtruth, codes)
