Patches broken ctypes for Python 3.8.1 in alpine dockerimage.
Apparently this issue was introduced while fixing another bug but breaks depending libraries, e.g. ctypesgen (see https://bugs.python.org/msg359834). It was already fixed in Python master (https://github.com/python/cpython/pull/17960), but Python 3.8.2 is expected in mid feburary.
See also (https://bugzilla.redhat.com/show_bug.cgi?id=1794572).
Other affected versions are Python 3.7.6 and Python 3.8.0.
