function sigma = rstd(arg1,arg2)
%
% RSTD      Radial standard deviation
%
%              sigma = rstd(r)
%              sigma = rstd(x,y)
%
%              Sigma = rstd(R)     % column wise
%              Sigma = rstd(X,Y)   % column wise
%
%           Theory:
%
%              sigma = sqrt(sum(r(i).*r(i)) / (N-1))
%
%                where r(i) = sqrt((x(i)-mean(x))^2 + (y(i)-mean(y))^2)
%
%           See also: ROBO
%
   if ( nargin <= 1 )
      R = arg1;
   elseif ( nargin == 2 )
      X = arg1;  Y = arg2;
      if any(size(X)~=size(Y))
         error('sizes of arg1 and arg2 must match!');
      end
      [m,n] = size(X);
      X0 = ones(m,1)*mean(X);
      Y0 = ones(m,1)*mean(Y);
      DX = X-X0;
      DY = Y-Y0;
      R = sqrt(DX.*DX + DY.*DY);
   else
      error('1 or 2 input args expected!')
   end
   
   N = size(R,1);
   sigma = sqrt(sum(R.*R)/(N-1));
   
% eof