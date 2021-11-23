%
% UPGRADE  Upgrade an object by adding package info data
%
%             oo = upgrade(o,oo)       % upgrade object, given package obj
%             oo = upgrade(o,oo,list)  % upgrade object, list of packages
%
%             tags = upgrade(o)        % return upgrade tag list
%
%          oo is the data object, while for 2 input args o is a package
%          object from which data is copied to the data object. For 3 input
%          args package object is one of the objects in list (arg3) and
%          upgrade() method must find out proper package object in list
%          based on data object's package identifier.
%     
%
%          Options:
%             files          upgrade only if file name is listed in
%                            package (default: false)
%
%          Copyright(c): Bluenetics 2020
%
%          See also: CORAZON, READ, IMPORT, COLLECT
%
