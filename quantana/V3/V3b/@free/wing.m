function out = wing(obj,col)
%
% WING    Wing plot of free particle object
%
%            wing(free);
%
%            fob = gauss(free);
%            wing(fob);             % wing plot with red color
%            wing(fob,'r');
%
%         See also: FREE, GAUSS, SCEENE, PALE
%
   if (nargin < 2)
      col = 'r';
   end

   init = sceene(quantana);
   if (~init)
      sceene(quantana,'3D');    % setup for 3D plotting
   end
   
   wing(quantana,zspace(obj),wave(obj),col);
   
   if (~init)
      camera('zoom',1.8);
   end
   return
   
%eof   