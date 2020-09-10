function check(obj,callback)
% 
% CHECK   Add a check functionality to a menu item
%
%    Example
%
%       default('bullets',1);                    % set default for bullets
%
%       ob1 = mitem(core,'Simple');              % add rolldown header item
%       ob2 = mitem(ob1,'Bullets','','bullets'); % add roll down menu item
%
%       check(ob2);                    % check functionality (no refresh)
%       check(ob2,'refresh(gfo)');     % check functionality (with refresh)
%       
%    See also: CORE, MENU, MITEM, CHOICE, DEFAULT
%
   CHK = 'check(gcbo);'; 

   if (nargin == 1)
      check(mitem(obj),CHK);
   elseif (nargin == 2)
      if isempty(callback)
         [func,mfile] = caller(obj);
         callback = call('refresh',mfile);
      end
      
      CHKR = [CHK,callback];
      check(mitem(obj),CHKR);
   else
      error('1 or 2 input args expected!');
   end
   return
end
