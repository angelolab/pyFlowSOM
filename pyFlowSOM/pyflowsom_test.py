from . import c_plus_seven


def test_import():
    assert 8 == c_plus_seven(1)
