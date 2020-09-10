function knd = kind(obj)
% 
% KIND     Get kind of a SMART object
%      
%             obj = smart                  % create SMART object
%             knd = kind(obj)              % get object's kind
%
%          See also CHAMEO

   knd = property(obj,'kind');
   
% end
