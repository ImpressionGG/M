function dst = distance(obj,idx)
% 
% Dstance  Get distance info of a TDMOBJ
%      
%             obj = tdmobj(data)    % create TDM object
%             dst = distance(obj,i) % distance info
%             dst = distance(obj)   % i = 0
%
%          See also   DANA, TDMOBJ
%
   fmt = format(obj);
   
   if ( nargin < 2 )
      idx = 1;
   end
   
   prop = property(obj,'kind');
   
   if strcmp(prop,'CAP')
      dst = [10000 10000];
   elseif isequal(fmt,'#TDK01')
      if ( idx == 1 )
         dst = obj.data.caldistance;
      else
         dst = obj.data.distance{idx-1};
      end
   elseif isequal(fmt,'#TDK02')
      if ( nargin <= 1 ), idx = {1:length(count(obj))}; end
      list = iscell(idx);
      if (list), idx = idx{1}; end
      dst=cell(1,length(idx));
      for k=1:length(idx)
         dst{k} = obj.data.data{idx(k)}.distance;
      end
      if (~list), dst = dst{1}; end
   else
      dst = get(obj,'distance');             
   end
end   

