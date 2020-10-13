function bag = pack(o)
%
% PACK   Pack CORAZITA object into a bag:
%
%           bag = pack(o)              % pack CORAZITA object into a bag
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZITA
%
   bag.tag = o.tag;
   bag.type = o.type;
   bag.par = o.par;
   bag.data = o.data;
   bag.work = o.work;
end
