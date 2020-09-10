function gtree(obj,level)
%
% GTREE   Print graphics tree:  
%
%            gtree(obj,level) 
%
%         Without input arguments obj = gcf and level = 0;
%
   if ( nargin < 1 ), obj   = gcf; end
   if ( nargin < 2 ), level = 0;   end

   type = get(obj,'type');
   chld = get(obj,'children');

   space = char(' ' + zeros(1,3*level));

%
% Print
%
   fprintf([space,type,' (%g): '],obj);
   
   if ( strcmp(type,'axes') )
      pos = get(obj,'position');
      vis = strcmp('on',get(obj,'visible'));
      fprintf(' [%g %g %g %g]   visible=%g',pos(1),pos(2),pos(3),pos(4),vis);
      tit = get(get(obj,'tit'),'string');
      if (length(tit) > 1),
         fprintf(['  ',tit]);
      end
   end

   if ( strcmp(type,'uicontrol') )
      pos = get(obj,'position');
      vis = strcmp('on',get(obj,'visible'));
      fprintf(' [%g %g %g %g]   visible=%g',pos(1),pos(2),pos(3),pos(4),vis);
   end

   if ( strcmp(type,'uimenu') )
      label = get(obj,'label');
      fprintf([' ',label]);
   end

   fprintf('\n');

%
% Children
%
   for i=1:length(chld),
      gtree(chld(i),level+1);
   end

% eof
