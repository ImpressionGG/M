function [z,p,k] = zpk(o,num,den)
%
% ZPK   Find zeros, poles and K-factor of a rational function
%
%          o = trf(corinth,[5 6],[1 2 3]);
%
%          [z,p,k] = zpk(o)
%          [z,p,k] = zpk(o,num,den)
%          [z,p,k] ) zpk(o,poly)
%
%       From a rational transfer function in polynomial form
%
%                    (s-z1)(s-z2)...(s-zn)       num(s)
%          G(s) =  K ---------------------  =  ----------
%                    (s-p1)(s-p2)...(s-pn)       den(s)
%
%       Find zeros, poles and K-factor. Vector den specifies the coeffi-
%       cients of the denominator in descending powers of s.  Matrix num 
%       indicates the numerator coefficients with as many rows as there 
%       are outputs.  
%
%       The zero locations are returned in the columns of matrix Z, with 
%       as many columns as there are rows in NUM.  The pole locations are
%       returned in column vector P, and the gains for each numerator 
%       transfer function in vector K. 
%
%       Copyright(c): Bluenetics 2020
%
%       See also: CORINTH, TRF
%
   switch nargin
      case {0,1}
         [num,den] = peek(o);
         [z,p,k] = Zpk(o,num,den);
      case 2
         den = 1;
         [z,p,k] = Zpk(o,num,den);
      case 3
         [z,p,k] = Zpk(o,num,den);
      otherwise
         error('1,2 or 3 input args expected');
   end
end

%==========================================================================
% Find Zeros, Poles and K-factor
%==========================================================================

function [z,p,k] = Zpk(o,num,den)
   [num,den] = Trim(o,num,den);

   if ~isempty(den)
       coef = den(1);
   else
       coef = 1;
   end
   if coef == 0
      error('denominator has zero leading coefficients');
   end

      % remove leading columns of zeros from numerator
   
   if ~isempty(num)
       while(all(num(:,1)==0) && length(num) > 1)
           num(:,1) = [];
       end
   end
   [ny,np] = size(num);

      % poles
      
   p  = roots(den);

      % zeros and gain
      
   k = zeros(ny,1);
   linf = inf;
   z = linf(ones(np-1,1),ones(ny,1));
   for i=1:ny
     zz = roots(num(i,:));
     if ~isempty(zz)
        z(1:length(zz),i) = zz;
     end
     ndx = find(num(i,:)~=0);
     if ~isempty(ndx)
        k(i,1) = num(i,ndx(1))./coef; 
     end
   end
end

%==========================================================================
% Helper
%==========================================================================

function [num,den] = Trim(o,num,den)
%
% TRIM Trim numerator and denominator to get equal length and perform 
%      consistency checks for proper transfer function.
%
%         [num,den] = Trim(o,num,den)
%
%   returns equivalent transfer function numerator and denominator where
%   length(numc) = LENGTH(den) if the transfer function num/den is proper,
%   otherwise causes an error.
%
   [nn,mn] = size(num);
   [nd,md] = size(den);

      % make sure DEN is a row vector, NUM is assumed to be in rows.
      
   if (nd > 1)
       error('denominator not a row vector');
   elseif (mn > md)
       error('improper transfer function');
   end

     % make NUM and DEN lengths equal
   
   num = [zeros(nn,md-mn),num];
end
