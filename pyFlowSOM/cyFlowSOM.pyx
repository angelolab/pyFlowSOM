cdef extern from "flowsom.c":
    cpdef int c_plus_seven(int a)
    void c_square_each(double *, unsigned int)

import numpy as np

def square_each(np_mat):
    if not np_mat.flags['C_CONTIGUOUS']:
        raise ValueError("Array must be C contiguous")

    cdef double[:,::1] mat = np_mat

    if not mat.shape[0] == mat.shape[1]:
        raise ValueError("Matrix must be square")

    c_square_each(&mat[0, 0], mat.shape[0])

    return mat

