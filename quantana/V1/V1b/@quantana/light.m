function obj = light(obj,pos1,col1,pos2,col2)
%
% LIGHT   Add (one time) a light to current axes
%
%            obj = light(quantana)
%            obj = light(quantana,[x1 y1 z1],[r1 g1 b1])
%            obj = light(quantana,pos1,rgb1,pos2,rgb2)
%
%         See also: QUANTANA, SURF
%
   init = option(obj,'light.init');
   if (init)
      return;     % already initialized
   end

   
   if (nargin < 2)
      pos1 = [40 100 20];
   end

   if (nargin < 3)
      col1 = [1 0.2 0.2];
   end
   
   if (nargin < 4)
      pos2 = [0.5 -1 0.4];
   end

   if (nargin < 5)
      col2 = [0.8 0.8 0];
   end
   
   if (nargin == 1)
       lhdl = light;
       lighting phong;
   else
      lhdl(1) = light('parent',gca,'position',pos1, 'style','local', ...
                      'color',col1);  %'Color',[0 0.8 0.8],

      lhdl(2) = light('parent',gca,'Position',pos2, 'color',col2);
      lighting phong;  material shiny;
   end
   
   obj = option(obj,'light.init',1, 'light.hdl',lhdl);
   return
   
% eof   
            