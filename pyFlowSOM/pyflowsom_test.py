import pytest
import pandas as pd
from pathlib import Path
import numpy as np

from . import square_each, som, map_data_to_codes

THIS_DIR = Path(__file__).parent


@pytest.fixture(scope='session')
def example_som_input():
    return pd.read_csv(THIS_DIR.parent / 'examples' / 'example_som_input.csv')


@pytest.fixture(scope='session')
def example_node_output():
    return pd.read_csv(THIS_DIR.parent / 'examples' / 'example_node_output.csv')


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


def test_map_data_to_codes(example_som_input, example_node_output):
    mapping_out = map_data_to_codes(example_node_output, example_som_input)
