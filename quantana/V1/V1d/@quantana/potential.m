function out = potential(obj,arg,z,param);
%
% POTENTIAL   3D plot of given potential
%
%           hdl = potential(quantana,'poly',z,[a0 a1 a2]) % polynom
%           hdl = potential(quantana,harmonic)            % harmonic oscillator
%
%        Options
%           potential(option(quantana,'potential.width',5),harmonic);
%           potential(option(quantana,'potential.trsp',0.5),harmonic);
%           potential(option(quantana,'potential.color','b'),harmonic);
%
%        See also: QUANTANA, PALE, WING, BALLEY
%
   width = either(option(obj,'potential.width'),5);
   trsp = either(option(obj,'potential.trsp'),0.5);
   col = either(option(obj,'potential.color'),0.5*[0 0 1]);
   np = either(option(obj,'potential.points'),50);
   
   if (isa(arg,'harmonic'))
      hob = arg;  z = zspace(hob);  dat = data(hob);
      z = min(z):[max(z)-min(z)]/np:max(z);               % z-coordinate          
      coeff = dat.m*dat.omega^2/2;  arg = 'poly';
      f = coeff * z.*z;
   elseif (strcmp(arg,'poly'))
      z = min(z):[max(z)-min(z)]/np:max(z);               % z-coordinate          
      f = 0*z;  zp = 0*z + 1;
      for (j=1:length(param))
         f = f + param(j) * zp;
         zp = zp .* z;
      end
   end
   
   w = [-width/2 width/2];           % cross coordinate

   [W,Z] = meshgrid(w,z);            % calculate mesh grid   
   [W,F] = meshgrid(w,f);            % calculate mesh grid   
   
   X = Z;                            % our main coordinate
   Y = W;                            % cross coordinate
   Z = F;                            % potential coordinate
   
   caxis manual;  caxis([0 1]);
   C = cindex(obj,0*Z+1,col);        % color indices

   hdl = surf(X,Y,Z,C,'EdgeColor','none');
   alpha(hdl,trsp);
   
   caxis([0 1]);                     % need to set again, as surf changes 
   
   daspect([1 1 1]);                 % set uniform data aspect ratios
   if (nargout > 0)
      out = hdl;
   end
   return
   
% eof