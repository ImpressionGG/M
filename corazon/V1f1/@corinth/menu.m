function oo = menu(o,varargin)         % Corazon Menu Building Blocks  
% 
% MENU   Package to provides building blocks for CORINTH menu
%      
%           menu(o,locfunc)            % call local function 

%        Display Functions
%           oo = menu(o,'About')       % display object info ('about me')
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORINTH, SHELL, MITEM, CHECK, CHOICE, CHARM
%
   [gamma,o] = manage(o,varargin,@About);
   oo = gamma(o);
end

%==========================================================================      
% Helpers
%==========================================================================      

function oo = About(o)                 % Display Object Info           
%
% ABOUT   About the current object (object info)
%
   refresh(o,o);
   oo = current(o);

   switch oo.type
      case 'number'
         title = get(oo,{'title',...
                         sprintf('rational number (#%g)',digits(oo))});
         txt = display(oo);
         for (i=1:size(txt,1))
            comment{i} = txt(i,:);
         end
         
         message(oo,title,comment);
         
      case 'poly'
         title = get(oo,{'title',sprintf('polynomial (%g)',...
                                          order(oo))});
         txt = display(oo);
         for (i=1:size(txt,1))
            comment{i} = txt(i,:);
         end
         
         message(oo,title,comment);
 
      case 'ratio'
         [on,od] = peek(oo);
         title = get(oo,{'title',sprintf('rational function (%g/%g)',...
                                          order(on),order(od))});
         txt = display(oo);
         for (i=1:size(txt,1))
            comment{i} = txt(i,:);
         end
         
         message(oo,title,comment);
 
      otherwise
         menu(o,'Home');
   end
end
