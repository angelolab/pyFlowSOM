import pytest
import numpy as np

from . import c_plus_seven, square_each


def test_import():
    assert 8 == c_plus_seven(1)


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
