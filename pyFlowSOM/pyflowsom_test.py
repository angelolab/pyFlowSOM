import pytest
import pandas as pd
from pathlib import Path
import numpy as np

from . import square_each, som, map_data_to_codes

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


def test_square_each_nonsquare_raises():
    mat = np.array([[1, 2, 3], [4, 5, 6]], dtype=np.float64)

    with pytest.raises(ValueError):
        square_each(mat)


def test_square_each_noncontiguous_raises():
    mat = np.array([[1, 2, 3, 4], [5, 6, 7, 8]], dtype=np.float64)

    with pytest.raises(ValueError):
        square_each(mat[:, ::2])


def test_square_each():
    mat = np.array([[1, 2], [4, 5]], dtype=np.float64)

    assert np.array_equal(np.array([[1, 4], [16, 25]], dtype=np.float64), square_each(mat))


def test_som(example_som_input):
    som_out = som(example_som_input, xdim=10, ydim=10, rlen=10)


def test_map_data_to_codes(example_som_input, example_node_output, example_cluster_groundtruth):
    codes, dists = map_data_to_codes(example_node_output, example_som_input)
    assert codes.shape == (41646,)
    assert dists.shape == (41646,)
    assert np.array_equal(example_cluster_groundtruth, codes)
