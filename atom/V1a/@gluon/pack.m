function bag = pack(o)
%
% PACK   Pack GLUON object into a bag:
%
%           bag = pack(o)              % pack GLUON object into a bag
%
%        Code lines: 7
%
%        See also: GLUON
%
   bag.tag = class(o);
   bag.typ = "";
   bag.par = [];
   bag.dat = [];
   bag.wrk = [];
end
