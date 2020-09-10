function [m,n] = sizes(obj)
% 
% SIZES  Get sizes of process Discrete Process Object
%      
%             m_n = sizes(obj)
%             [m,n] = sizes(obj)
%
%          See also   DISCO, DPROC

% check arguments

   switch kind(obj)
      case 'process'
         mn = obj.data.sizes;
         m = mn(1);  n = mn(2);
      case {'sequence','chain'}
         m = 1;  n = length(obj.data.list);
      otherwise
         m = 1;  n = 1;
   end

   if (nargout <= 1) m = [m n]; end
 
% eof