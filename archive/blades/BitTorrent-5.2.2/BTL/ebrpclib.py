# by Greg Hazel

import xmlrpclib
from xmlrpclib2 import *
from BTL import ebrpc

old_PyCurlTransport = PyCurlTransport
class PyCurlTransport(old_PyCurlTransport):

    def set_connection_params(self, h):
        h.add_header('User-Agent', "ebrpclib.py/1.0")
        h.add_header('Connection', "Keep-Alive")
        h.add_header('Content-Type', "application/octet-stream")
    
    def _parse_response(self, response):
        # read response from input file/socket, and parse it
        return ebrpc.loads(response.getvalue())[0]

# --------------------------------------------------------------------
# request dispatcher

class _Method:
    # some magic to bind an EB-RPC method to an RPC server.
    # supports "nested" methods (e.g. examples.getStateName)
    def __init__(self, send, name):
        self.__send = send
        self.__name = name
    def __getattr__(self, name):
        return _Method(self.__send, "%s.%s" % (self.__name, name))
    def __call__(self, *args, **kwargs):
        args = (args, kwargs)
        return self.__send(self.__name, args)
    # ARG! prevent repr(_Method()) from submiting an RPC call!
    def __repr__(self):
        return "<%s instance at 0x%08X>" % (self.__class__, id(self))


# Double underscore is BAD!
class EBRPC_ServerProxy(xmlrpclib.ServerProxy):
    """uri [,options] -> a logical connection to an EB-RPC server

    uri is the connection point on the server, given as
    scheme://host/target.

    The standard implementation always supports the "http" scheme.  If
    SSL socket support is available (Python 2.0), it also supports
    "https".

    If the target part and the slash preceding it are both omitted,
    "/RPC2" is assumed.

    The following options can be given as keyword arguments:

        transport: a transport factory
        encoding: the request encoding (default is UTF-8)

    All 8-bit strings passed to the server proxy are assumed to use
    the given encoding.
    """

    def __init__(self, uri, transport=None, encoding=None, verbose=0,
                 allow_none=0):
        # establish a "logical" server connection

        # get the url
        import urllib
        type, uri = urllib.splittype(uri)
        if type not in ("http", "https"):
            raise IOError, "unsupported EB-RPC protocol"
        self.__host, self.__handler = urllib.splithost(uri)
        if not self.__handler:
            self.__handler = "/RPC2"

        if transport is None:
            if type == "https":
                transport = xmlrpclib.SafeTransport()
            else:
                transport = xmlrpclib.Transport()
        self.__transport = transport

        self.__encoding = encoding
        self.__verbose = verbose
        self.__allow_none = allow_none

    def __request(self, methodname, params):
        # call a method on the remote server

        request = ebrpc.dumps(params, methodname, encoding=self.__encoding,
                              allow_none=self.__allow_none)

        response = self.__transport.request(
            self.__host,
            self.__handler,
            request,
            verbose=self.__verbose
            )

        if len(response) == 1:
            response = response[0]

        return response

    def __repr__(self):
        return (
            "<ServerProxy for %s%s>" %
            (self.__host, self.__handler)
            )

    __str__ = __repr__

    def __getattr__(self, name):
        # magic method dispatcher
        return _Method(self.__request, name)
    
def new_server_proxy(url, max_connects=None, timeout=None):
    c = cache_set.get_cache(PyCURL_Cache, url, max_per_cache=max_connects)
    t = PyCurlTransport(c, max_connects=max_connects, timeout=timeout)
    return EBRPC_ServerProxy(url, transport=t)

ServerProxy = new_server_proxy
