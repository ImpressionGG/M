%
% CAST   Cast object to another class. Casting means that all properties
%        are left unchanged (also 'tag' property!).
%
%           o = corazon;               % create a CORAZON object
%           oo = cast(o,'corshito');   % cast to a CORSHITO object
%           o = cast(oo);              % cast CORSHITO back to CORAZON
%
%           [o1,o2] = cast(o1,o2);     % cast to same type
%
%        After casting the CORAZON object to a CORSHITO object the 'tag'
%        property has still the value 'corazon'. This is in contrast to
%        object construction.
%
%           o = corazon;               % create a CORAZON object
%           oo = corshito(o);          % construct CORSHITO from CORAZON
%
%        Object construction sets the 'tag' property equal to the class
%        name.
%
%        There is sometimes the need to convert an object o to another
%        one with class and tag from object oo. This can be done by:
%
%           o = corazon;               % create a CORAZON object
%           oo = corshito;             % create a CORSHITO object
%           o = cast(o,oo)             % class & tag conversion to CORSHITO
%           o = cast(o,corshito)       % same as above
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZON, CONSTRUCT
%
