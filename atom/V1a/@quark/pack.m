function bag = pack(o)
%
% PACK   Pack QUARK object into a bag:
%
%           bag = pack(o)              % pack QUARK object into a bag
%
%        Code lines: 6
%
%        See also: QUARK
%
   bag.tag = o.tag;
   bag.typ = o.typ;
   bag.par = o.par;
   bag.dat = o.dat;
   bag.wrk = o.wrk;
end
