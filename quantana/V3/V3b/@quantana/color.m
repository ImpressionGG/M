function hdl = color(obj,hdl,psi)
%
% COLOR    Set colors of objects given by object handles. Colormap can
%          be any map defined by CMAP.
%
%             [obj,map] = cmap(quantana,'phase');
%             hdl = color(obj,hdl,psi);
%
%          See also: QUANTANA, CMAP, CINDEX
%
   C = cindex(obj,psi);
   
   name = option(obj,'cmap.name');
   [obj,map] = cmap(obj,name);
   
   col = map(C+1,:);
   for (j=1:length(hdl))
      set(hdl(j),'color',col(j,:));
   end
   return
   
% eof   