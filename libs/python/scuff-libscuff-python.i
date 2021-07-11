%{
#include "libscuff.h"
%}

%newobject scuff::RWGGeometry::GetFields;

%extend scuff::RWGGeometry {

  %exception GetFields {
    $action
    if (PyErr_Occurred()) SWIG_fail;
  }
  
   HMatrix *GetFields(IncField *IF, PyObject *KN, cdouble Omega, PyObject *XMatrix) {
     HMatrix *xm = NULL;
     HVector *kn = NULL;

    xm = hmatrix_from_pyobject(XMatrix);
    kn = hvector_from_pyobject(KN);

    if (kn && xm) {
      return $self->GetFields(IF, kn, Omega, xm);
    }
    return NULL;
   }
}
%ignore scuff::RWGGeometry::GetFields(IncField *IF, HVector *KN, cdouble Omega, double *kBloch, HMatrix *XMatrix, HMatrix *FMatrix=NULL);
%ignore scuff::RWGGeometry::GetFields(IncField *IF, HVector *KN, cdouble Omega, HMatrix *XMatrix, HMatrix *FMatrix=NULL);
%ignore scuff::RWGGeometry::GetFields(IncField *IF, HVector *KN, cdouble Omega, double *kBloch, double *X, cdouble *EH);
%ignore scuff::RWGGeometry::GetFields(IncField *IF, HVector *KN, cdouble Omega, double *X, cdouble *EH);