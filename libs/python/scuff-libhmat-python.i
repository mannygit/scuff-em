%include "array_interface.i"
%include "ro_prop.i"

%{
#include "libhmat.h"
%}

%numpy_typemaps(cdouble, NPY_CDOUBLE, int)

%apply (int DIM1, int DIM2, double *INPLACE_ARRAY2) {(int NRows, int NCols, double* data)}
%rename (HMatrix_from_double) HMatrix::HMatrix(int NRows, int NCols, double *data);

%apply (int DIM1, int DIM2, cdouble *INPLACE_ARRAY2) {(int NRows, int NCols, cdouble* data)}
%rename (HMatrix_from_cdouble) HMatrix::HMatrix(int NRows, int NCols, cdouble *data);

/**
    HVector
*/
%{

void fill_hvector_array_info(HVector * v, void ** data, int * shape, int * npy_type) {
    if (!v->RealComplex) {
        *data = (void *)v->DV;
        *npy_type = NPY_DOUBLE;
    } else {
        *data = (void *)v->ZV;
        *npy_type = NPY_CDOUBLE;
    }
    *shape = v->N;
}

HVector * hvector_from_np_array(PyObject * npy_array) {

    void * data = NULL;
    int dims[1] = {0};
    int dtype = 0; 

    if(check_and_get_np_array(npy_array, &dtype, 1, dims, &data) < 0) {
      return NULL;
    }

    return new HVector(dims[0], dtype == NPY_CDOUBLE, (void *)data);
}

HVector * hvector_from_pyobject(PyObject * pyobj) {
  HVector *v = NULL;

  if (SWIG_ConvertPtr(pyobj, (void **) &v, SWIGTYPE_p_HVector, 0 | 0) == -1)
    v = hvector_from_np_array(pyobj);
  
  return v;
}

%}

// HVectors are one dimensional arrays
%ND_ARRAY_INTERFACE(1)
%nd_ai_provider(1, HVector, fill_hvector_array_info)

%extend HVector {

  %exception HVector(PyObject *pyobj) {
    $action
    if (PyErr_Occurred()) SWIG_fail;
  }

  HVector(PyObject *pyobj) {
    return hvector_from_pyobject(pyobj);
  }
}

/**
 HMatrix
*/

// Unsafe for python due to potential memory leaks. Use filename based constructors directly
%ignore HMatrix::InitMatrix;
%ignore HMatrix::ReadFromFile;
%ignore HMatrix::ImportFromHDF5;
%ignore HMatrix::ImportFromText;

%{

void fill_hmatrix_array_info(HMatrix * m, void ** data, int * shape, int * npy_type) {
    if (!m->RealComplex) {
        *data = (void *)m->DM;
        *npy_type = NPY_DOUBLE;
    } else {
        *data = (void *)m->ZM;
        *npy_type = NPY_CDOUBLE;
    }
    *shape++ = m->NR;
    *shape = m->NC;
}

HMatrix * hmatrix_from_np_array(PyObject * npy_array) {

    void * data = NULL;
    int dims[2] = {0, 0};
    int dtype = 0; 

    if(check_and_get_np_array(npy_array, &dtype, 2, dims, &data) < 0) {
      return NULL;
    }

    return new HMatrix(dims[0], dims[1], dtype == NPY_CDOUBLE, LHM_NORMAL, data);
}

HMatrix * hmatrix_from_pyobject(PyObject * pyobj) {
  HMatrix *m = NULL;

  if (SWIG_ConvertPtr(pyobj, (void **) &m, SWIGTYPE_p_HMatrix, 0 | 0) == -1)
    m = hmatrix_from_np_array(pyobj);

  return m;
}
%}

// HMatrix are 2 dimensional matrices
%ND_ARRAY_INTERFACE(2)
%nd_ai_provider(2, HMatrix, fill_hmatrix_array_info)


%extend HMatrix {

  %exception HMatrix(PyObject *pyobj) {
    $action
    if (PyErr_Occurred()) SWIG_fail;
  }

  HMatrix(PyObject *pyobj) {
    return hmatrix_from_pyobject(pyobj);
  }

}

