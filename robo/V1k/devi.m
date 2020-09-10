function [devs,E] = devi(X,Y)
%
% DEVI      Deviation analysis
%
%              devi(X,Y)          % textual display of deviations
%              devi(X)            % same as devi(X,0*X)
%              devs = devi(X,Y)   % return deviation values by a row vector
%
%           Description:
%
%              devs(1)   mean value r          (= sqrt(mx^2+my^2+mz^2))
%              devs(2)   mean value x
%              devs(3)   mean value y
%              devs(4)   mean value z
%              devs(5)   r-standard deviation  (= sqrt(sx^2 + sy^2 + sz^2))
%              devs(6)   x-standard deviation
%              devs(7)   y-standard deviation
%              devs(8)   z-standard deviation
%              devs(9)   max deviation (distance)
%              devs(10)  x-max deviation
%              devs(11)  y-max deviation
%              devs(12)  z-max deviation
%              devs(13)  max peak to peakmax deviation (distance)
%              devs(14)  x-pp deviation
%              devs(15)  y-pp deviation
%              devs(16)  z-pp deviation
%
%           Example:
%
%              C = map(X,Y,1);
%              devi(map(C,X),Y);
% 
%           See also: ROBO, VPLT, VCAT, VLETTER, VCHIP
%
   if ( nargin < 2) Y = 0*X; end

   X = velim(X);  Y = velim(Y);
   
   if any(size(X) ~= size(Y))
      error('sizes of X and Y must match!')
   end
   [m,n] = size(X);
   
   if ( m < 2 | m > 4 ) error('2D, 3D or 4H vector sets expected!'); end
   
   if ( size(X,1) == 4 ) X = ihom(X);  Y = ihom(Y); end
   [m,n] = size(X);
   
   E = X-Y;   % error vector set
   
      % now calculate r as the row vector of ||.||2-distances
   
   if ( m == 2 )
      x = E(1,:);  y = E(2,:);  z = 0*y;
   elseif ( m == 3 )
      x = E(1,:);  y = E(2,:);  z = E(3,:);
   else
      error('bug!')
   end
   
   r = sqrt(x.*x + y.*y + z.*z);
   
   meanx = mean(x);
   meany = mean(y);
   meanz = mean(z);
   meanr = sqrt(meanx^2 + meany^2 + meanz^2);
   
   stdx = std(x);
   stdy = std(y);
   stdz = std(z);
   stdr = sqrt(stdx^2+stdy^2+stdz^2);
   
   maxr = max(abs(r));
   maxx = max(abs(x));
   maxy = max(abs(y));
   maxz = max(abs(z));
   
   ppx = max(x) - min(x);
   ppy = max(y) - min(y);
   ppz = max(z) - min(z);
   ppr = sqrt(ppx^2 + ppy^2 + ppz^2);
   
   if ( nargout == 0 )
      fprintf('   total mean value:     %g\n',meanr);
      fprintf('   mean value x:         %g\n',meanx);
      fprintf('   mean value y:         %g\n',meany);
      if (m >= 3) fprintf('   mean value z:         %g\n',meanz); end
      fprintf('\n');
      fprintf('   standard deviation:   %g\n',stdr);
      fprintf('   standard x-deviation: %g\n',stdx);
      fprintf('   standard y-deviation: %g\n',stdy);
      if (m >= 3)  fprintf('   standard z-deviation: %g\n',stdz); end
      fprintf('\n');
      fprintf('   max deviation:        %g\n',maxr);
      fprintf('   max x-deviation:      %g\n',maxx);
      fprintf('   max y-deviation:      %g\n',maxy);
      if (m >= 3) fprintf('   max z-deviation:      %g\n',maxz); end
      fprintf('\n');
      fprintf('   total range:         %g\n',ppr);
      fprintf('   range x:             %g\n',ppx);
      fprintf('   range y:             %g\n',ppy);
      if (m >= 3) fprintf('   range z:             %g\n',ppz); end
   else
      devs = [meanr meanx meany meanz stdr stdx stdy stdz maxr maxx maxy maxz ppr ppx ppy ppz];
   end
   
% eof