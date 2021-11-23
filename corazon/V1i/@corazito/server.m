%
% SERVER   Create a CORLEON server object with query info from bag. 
%
%    A Corleon object is generated with query information which is com-
%    posed from the provided bag information. If for some reason CORLEON
%    class is not accessible (e.g. not configured, then query returns an 
%    empty object [].
%
%       o = server(corazito,bag)       % return corleon object, or empty
%
%    Remarks: bag must be a structure with the following 5 member tags:
%    tag, type, par, data and work.
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO, CORLEON
%
