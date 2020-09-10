function choice(obj,list,callback)
% 
% CHOICE   Add a choice functionality to a menu item
%
%    Example
%
%       default('color','r');                 % set default for color
%
%       ob1 = mitem(core,'Simple');           % add rolldown header item
%       ob2 = mitem(ob1,'Color','','color');  % add roll down menu item
%
%       choice(ob2,{{'Red','r'},{'Blue','b'}});                % no refresh
%       choice(ob2,{{'Red','r'},{'Blue','b'}},'');             % refresh
%       choice(ob2,{{'Red','r'},{'Blue','b'}},'refresh(gfo)'); % refresh
%       
%    See also: CORE, MENU, MITEM, CHECK, DEFAULT, CHOICE
%
   CHC = 'choice(gcbo);';
   
   if (nargin == 2)
      choice(mitem(obj),list,CHC);
   elseif (nargin == 3)
      if isempty(callback)
         [func,mfile] = caller(obj);
         callback = call('refresh',mfile);
      end   
      CHCR = [CHC,callback];
      choice(mitem(obj),list,CHCR);
   else
      error('2 or 3 input args expected!');
   end
   return
end
