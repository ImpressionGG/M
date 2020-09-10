function out = pale(obj,col)
%
% PALE    Pale plot of free particle object
%
%            pale(free);
%
%            fob = gauss(free);
%            pale(fob);             % pale plot with red color
%            pale(fob,'r');
%
%         See also: FREE, GAUSS, SCEENE, WING
%
   if (nargin < 2)
      col = 'r';
   end
   
   init = sceene(quantana);
   if (~init)
      sceene(quantana,'3D');    % setup for 3D plotting
   end
   
   pale(quantana,zspace(obj),wave(obj),col);
   
   if (~init)
      camera('zoom',1.8);
   end
   return
   
%eof   