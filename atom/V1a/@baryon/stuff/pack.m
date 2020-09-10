function bag = pack(o)
%
% PACK   Pack CARABAO object into a bag:
%
%           bag = pack(o)              % pack object into a bag
%
%        Code lines: 6
%
%        See also: CARABAO, UNPACK, CONSTRUCT
%
   bag.tag = o.tag;
   bag.type = o.type;
   bag.par = o.par;
   bag.data = o.data;
   bag.work = o.work;

      % if data is a list we have to pack all list elements
      
   if iscell(bag.data)
      list = bag.data;
      for (i=1:length(list))
         list{i} = pack(list{i});
      end
      bag.data = list;
   end
end
