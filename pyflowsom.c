#define PY_SSIZE_T_CLEAN
#include <Python.h>

static PyObject *
pyflowsom_greet(PyObject *self, PyObject *args)
{
    const char *name;

    if (!PyArg_ParseTuple(args, "s", &name))
        return NULL;

    int sts = 6;
    return PyLong_FromLong(sts);
}

static PyMethodDef PyFlowSomMethods[] = {
    {"greet", pyflowsom_greet, METH_VARARGS,
     "Greet users"},
    {NULL, NULL, 0, NULL}        /* Sentinel */
};

static struct PyModuleDef pyflowsommodule = {
    PyModuleDef_HEAD_INIT,
    "pyflowsom",   /* name of module */
    "docstring for module", /* module documentation, may be NULL */
    -1,       /* size of per-interpreter state of the module,
                 or -1 if the module keeps state in global variables. */
    PyFlowSomMethods
};

PyMODINIT_FUNC
PyInit_pyflowsom(void)
{
    return PyModule_Create(&pyflowsommodule);
}
