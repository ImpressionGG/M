function [out1,out2] = resi(X,Y,kind)
%
% RESI      Residual vector set of a general mapping.
%           The function internally uses MAP.
%
%              R = resi(X,Y,0)   % calculate residual vector set of linear mapping
%              R = resi(X,Y,1)   % calculate residual vector set of affine map
%              R = resi(X,Y,2)   % calculate residual vector set of order 2 map
%
%              R = resi(X,Y)     % affine map by default (kind  1)
%              [R,T] = map(X,Y,kind)   % also return mapping coefficients
%
%           Theory
%
%              R := Y - T*X  where T: ||R|| = ||Y - T*X|| -> min
%
%           Example:
%
%              C = camera([0 2 0],[80 40],[30 30 30]*deg);
%              V = vchip; F = photo(C,V);
%              R = resi(V,F,1)
%
%           See also: ROBO, MAP
%
   if (nargin <  2)
      error('at least two input args expected!')
   end

   if (nargin < 3) kind = 1; end

   T = map(X,Y,kind);
   R = Y - map(T,X);

   if (nargout > 0)
      out1 = R;  out2 = T;
   else   % nargout = 0
      if (kind == 0 | kind == 1 | kind == 2 | kind == 3)
         if ( size(X,1) ~= 2 ) error('only 2D vectors allowed for direct analysis!'); end
         if ( kind == 1 )
            par = hskr(T);
            ro = round(10*par(1)/deg*1000)/10;
            kx = round(10*(par(2)-1)*1e5)/10;
            ky = round(10*(par(3)-1)*1e5)/10;
            sh = round(10*par(4)*1e5)/10;
            mx = par(5);
            my = par(6);
         end

         devs = devi(R);
         sx = round(10*devs(6))/10;    % standard deviation x
         sy = round(10*devs(7))/10;    % standard deviation y

         rx = round(10*devs(14))/10;   % range x
         ry = round(10*devs(15))/10;   % range y
         
         if ( kind == 1 )
            txt{1} = sprintf('MX: %g µm',round(10*mx)/10);
            txt{2} = sprintf('MY: %g µm',round(10*my)/10);
            txt{3} = sprintf('RO: %g m°',ro);
            txt{4} = sprintf('KX: %g µm/dm',kx);
            txt{5} = sprintf('KY: %g µm/dm',ky);
            txt{6} = sprintf('SH: %g µm/dm',sh);
         end

         txt{7} = sprintf('SX: %g µm',sx);
         txt{8} = sprintf('SY: %g µm',sy);
         txt{9} = sprintf('RX: %g µm',rx);
         txt{10} = sprintf('RY: %g µm',ry);
            
         if ( kind == 1 )
            fprintf('Princpal:\n')
            for (i=1:6) fprintf(['   ',txt{i},'\n']); end
         end
         fprintf('Residual:\n')
         for (i=7:10) fprintf(['   ',txt{i},'\n']); end
      else
         error(sprintf('Direct analysis not implemented for arg3 = %g',kind));
      end
   end

% eof