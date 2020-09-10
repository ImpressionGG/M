function obj = data(obj,d)
% 
% DATA   Get or set data of a SMART object
%      
%             obj = smart           % create SMART object
%             d = data(obj)         % get data
%             obj = data(obj,d)     % set data
%
%        See also: SMART

   switch obj.format
      case {'#DATA','#BULK'}
         % ok
      otherwise
         error('smart::data(): cannot get/set data of generic SMART objects!');
   end
   
   if (nargin == 1)
      obj = obj.data;              % raw data
   elseif (nargin == 2)
      obj.data = d;
   else
      error('smart::data(): 1 or 2 args expected!');
   end
   return
   
% end
