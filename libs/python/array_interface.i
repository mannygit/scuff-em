%ignore "_destroy_ai_capsule";

%inline %{ 

void _destroy_ai_capsule(PyObject *capsule) {
  PyObject *context = (PyObject *)PyCapsule_GetContext(capsule);
  void *iface = (void *)PyCapsule_GetPointer(capsule, NULL);
  free(iface);
  Py_DecRef(context);
}

PyObject * _new_ai_capsule(PyObject * parent, void * ai_ptr) {
  PyObject * capsule = PyCapsule_New(ai_ptr, NULL, _destroy_ai_capsule);
  PyCapsule_SetContext(capsule, parent);
  Py_IncRef(parent);
  return capsule;
}

%}



%define %ND_ARRAY_INTERFACE(ND)
  %ignore _##ND##D_ai_t;
  %ignore _##ND##D_ai_new;
%{

  typedef struct  {
    PyArrayInterface iface;
    npy_intp shape[ND];
  } _##ND##D_ai_t;

  int _##ND##D_ai_new(_##ND##D_ai_t ** ptr_out, int npy_type) {
    _##ND##D_ai_t * s;
    PyArray_Descr * descr;
    
    descr = PyArray_DescrFromType(npy_type);
    if(descr == NULL) {
      return 1;
    }

    s = (_##ND##D_ai_t *)malloc(sizeof(_##ND##D_ai_t));

    if(s == NULL) {
      return 1;
    }

    s->iface.two = 2;
    s->iface.flags = NPY_ARRAY_C_CONTIGUOUS |  NPY_ARRAY_ALIGNED  |  NPY_ARRAY_NOTSWAPPED | NPY_ARR_HAS_DESCR;
    s->iface.nd = ND;
    s->iface.shape = s->shape;
    s->iface.strides = NULL; 
    s->iface.descr = (PyObject *)descr;
    s->iface.data = NULL;
    *ptr_out = s;
    return 0;
  }


%}

%enddef


%define %nd_ai_provider(ND, CLASS, FILL_CB)
  
  %extend CLASS { 
    PyObject * get__array_struct__(PyObject * pyself) {
      PyObject * capsule = NULL;
      void * data = NULL;
      int shape[ND];
      int npy_type = 0;
      int i;
      _##ND##D_ai_t * iface = NULL; 

      FILL_CB($self, &data, shape, &npy_type);

      if(_##ND##D_ai_new(&iface, npy_type)){
        return NULL;
      }

      iface->iface.data = data;
      for(i = 0; i < ND; i++)
        iface->shape[i] = shape[i];

      capsule = _new_ai_capsule(pyself, iface);
      return capsule;      
    }
  }

  %ro_property(CLASS, __array_struct__, CLASS::get__array_struct__);

%enddef