function show(o,filename)
%
% SHOW   Show image object, using proper direction and data aspect ratio
%
%           oo = import(caravel,filename);
%           show(oo);
%
%        Compact statement to show an image to be loaded from file:
%
%           show(caravel,filename)
%
%        See also: CARAVEL
%
   if (nargin == 2)
      o = import(caravel,filename);
   end
   
   cls(o);
   
   fig = figure(o);
   hax = gca(fig);
   
   ydir = get(hax,'ydir');
   hdl = image(o.data.image);
   if ~isempty(o.data.cmap)
       colormap(o.data.cmap);
   end
   set(hax,'ydir','reverse');
   set(hax,'DataAspect',[1 1 1]);
   set(hax,'Visible','off');
end

