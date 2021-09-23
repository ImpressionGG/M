function bag = pack(o)
%
% PACK   Pack CORAZITO object into a bag:
%
%           bag = pack(o)              % pack CORAZITO object into a bag
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZITO
%
   bag.tag = class(o);
   bag.type = '';
   bag.par = [];
   bag.data = [];
   bag.work = [];
end
