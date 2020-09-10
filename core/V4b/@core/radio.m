function hdl = radio(obj,labels,callback,userdata)
%
% RADIO   Add a radio button bar
%
%    Stop flag is cleared by TIMER function
%    and set by butpress, if butpress properly set to Stop()
%
%       hdl = radio(obj,labels,callback,ud);
%
%       hdl = radio(obj,{'Red','Green','Blue'},'RadioHandler',1:3)
%       hdl = radio(obj,{'Red','Green','Blue'},'RadioHandler')
%
%    See also: CORE, CLS
%
   if (nargin < 4)
      userdata = labels;
   end
   
   pos = get(gcf,'position');   % get position of figure
   width = pos(3);              % get figure width
   
   n = length(labels);
   w = width/n;
   h = 25;
   
   for (i=1:n)
      lab = labels{i};
      if ~isa(lab,'char')
         error('all labels must be character strings!');
      end
      
      hdl(i) = uicontrol('parent',gcf,'style','pushbutton','String',lab);
      set(hdl(i),'position',[(i-1)*w,0,w,h]);
      
      set(hdl(i),'callback',callback);      
      
      if isa(userdata,'double')
         ud = userdata(i);
      elseif isa(userdata,'cell')
         ud = userdata{i};
      else
         error('userdata must be double or list!');
      end
      set(hdl(i),'userdata',ud);
   end
   return
end
