function bag = pack(o)
%
% PACK   Pack CARACOW object into a bag:
%
%           bag = pack(o)              % pack CARACOW object into a bag
%
%        Code lines: 6
%
%        See also: CARACOW
%
   bag.tag = o.tag;
   bag.type = o.type;
   bag.par = o.par;
   bag.data = o.data;
   bag.work = o.work;
end
