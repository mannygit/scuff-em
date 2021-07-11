%{
int check_and_get_np_array(PyObject * npy_array, int *dtype, int n_dims, 
                           int * dims, void **data) {

    PyArrayObject * array = (PyArrayObject *)NULL;

    array = obj_to_array_no_conversion(npy_array, NPY_CDOUBLE);

    if (!array) {
      array = obj_to_array_no_conversion(npy_array, NPY_DOUBLE);
      if (!array) {
        
        SWIG_Python_RaiseOrModifyTypeError("fail!");
        return -1;
      }
      *dtype = NPY_DOUBLE;
    } else {
      *dtype = NPY_CDOUBLE;
    }

    PyErr_Clear();

    if (!array || !require_dimensions(array, n_dims) || !require_contiguous(array)
        || !require_native(array)) {
      SWIG_Python_RaiseOrModifyTypeError("requires a double or cdouble numpy array.");
      return -1;
    }

    for(int i = 0; i < n_dims; i++) {
      dims[i] = array_size(array, i);
    }
    *data = array_data(array);
    return 0;
}

%}