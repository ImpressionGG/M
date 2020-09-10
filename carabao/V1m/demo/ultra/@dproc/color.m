function col = color(obj)
% 
% COLOR    Get color of a DPROC object
%      
%             obj = dproc           % create DPROC object
%             col = color(obj)      % color
%
%          See also   DISCO, DPROC

   col = obj.data.color;
   if isempty(col)
      col = 'b';
   end
   
% end
