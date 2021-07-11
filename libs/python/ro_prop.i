
%define %ro_property(CLASS, PROPERTY, GETTER)
  
  %immutable CLASS::PROPERTY;
  %ignore CLASS ##_## PROPERTY ##_get;
  %ignore CLASS ##_## PROPERTY ##_get_raw;

  %extend CLASS { 
    PyObject * PROPERTY;
  }  

  %{
    static PyObject * %mangle(CLASS) ##_## get #### PROPERTY ## (CLASS *, PyObject *);

    #define %mangle(CLASS) ##_## PROPERTY ##_get(x) CLASS ##_## PROPERTY ##_get_raw(x, self)
  %}

  %inline { 
    PyObject * CLASS ##_## PROPERTY ##_get_raw ## (CLASS * inst, PyObject * self) {return %mangle(GETTER)(inst, self);} 
  }
%enddef