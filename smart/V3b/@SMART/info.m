function txt = info(obj,mode)
% 
% INFO  Get info of a SMART object
%      
%             obj = smart           % create SMART object
%             txt = info(obj)       % get SMART object's info
%
%          See also   SMART

%    if (nargin <= 1), mode = 0; end
   
   title = property(obj,'title');
   
   if (isempty(title))
      txt = ['Smart: ',obj.format];
   else
      txt = title;
   end
   
% end
