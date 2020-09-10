function bag = pack(o)
%
% PACK   Pack CARABULL object into a bag:
%
%           bag = pack(o)              % pack CARABULL object into a bag
%
%        Code lines: 7
%
%        See also: CARABULL
%
   bag.tag = class(o);
   bag.type = '';
   bag.par = [];
   bag.data = [];
   bag.work = [];
end
