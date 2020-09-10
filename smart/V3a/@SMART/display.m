function display(obj)
% 
% DISPLAY  Display a SMART object
%      
%             obj = smart    % create SMART object
%             display(obj);
%
%          See also   SMART

   if (property(obj,'generic'))
      disp(['<Smart:',info(obj),'>']);
   else
      disp(['<Smart: ',info(obj),'>']);
   end
   
% eof