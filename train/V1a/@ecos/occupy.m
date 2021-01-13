function oo = occupy(o,page)
%
% OCCUPY   Return page occupation as a 2xn table with page index as first
%          column and location index as second column
%
%             tab = occupy(o)
%
%          With additional page argument return next free location (or
%          empty if page is full)
%
%             free = occupy(o,page)
%
%          See also: ECOS
%
   if (nargin == 1)
      oo = Table(o);
   else
      oo = Free(o,page);
   end
end

%==========================================================================
% Occupation Table
%==========================================================================

function tab = Table(o)
   o = pull(o);
   list = o.data;
   
   tab = [nan,nan];
   for (i=1:length(list))
      oo = list{i};
      page = get(oo,'page');
      location = get(oo,{'index',nan});
      
      idx = find(tab(:,1)==page && tab(:,2)==location);
      if isempty(idx)
         tab(end+1,1:2) = [page,location];
      end
   end  
   
   tab(1,:) = [];
end

%==========================================================================
% Next Free Location
%==========================================================================

function free = Free(o,page)
   tab = Table(o);
   if isempty(tab)
      free = 1;
      return
   end
      
   idx = find(tab(:,1) == page);

   if isempty(idx)
      free = 1;
   else
      tab = tab(idx,:);             % reduce table to page entries
      index = tab(:,2);

      free = [];                    % by default no free entries

      for (i=1:10)
         if isempty(index==i)
            free = i;
            break;
         end
      end
   end
end
