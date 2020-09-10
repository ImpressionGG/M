function fmt = kind(obj)
% 
% KIND     Get kind of a SMART object
%      
%             obj = smart                  % create SMART object
%             knd = kind(obj)              % get object's kind
%
%          See also CHAMEO

   fmt = property(obj,'kind');
   
% end
