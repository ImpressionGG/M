function display(obj)
% 
% DISPLAY  Display a CORE object
%      
%             obj = shell(typ)    % construct a CORE object
%             display(obj);
%
%          See also: CORE, DISP, DATA, GET
%
   if isempty(get(obj,'title'))
      disp(['   <',info(obj),'>']);
   elseif strcmp(type(obj),'generic')
      disp(['   <generic ',class(obj),'>']);
   else
      disp(['   <',class(obj),': ',info(obj),'>']);
   end
   return
end
