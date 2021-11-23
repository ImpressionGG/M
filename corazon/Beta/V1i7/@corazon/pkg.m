%
% PKG       Retrieve package object corresponding to given object with
%           inherited options from shell object.
%
%                po = pkg(oo);         % retrieve package object  
%                po = pkg(oo,o);       % retrieve pkg obj (explicite sho)   
%
%           The package object is identified by an object's package ID:
%
%              package = get(o,'package');
%
%           If package ID is invalid or empty, or if given object is a
%           shell object then an empty matrix is returned. THe options to
%           inherit are taken from the shell object which is implicetly
%           fetched by a 'o = pull(oo)' call from the shell.
%
%           If this is not intended then the shell object can be provided 
%           explicitely by second input arg.
%
%           Example 1:
%              assert(type(oo,{'dat')})
%              po = pkg(oo)            % inherit options from sho
%
%           Example 2:
%
%              assert(type(oo,{'dat')})
%              o = opt(sho,'color','r');
%              po = pkg(oo,o)          % inherit options from o
%              assert(isequal(opt(po,'color'),'r')
%
%           Copyright(c): Bluenetics 2021 
%
%           See also: CORAZON, CONTAINER, CHILDREN, PULL
%
