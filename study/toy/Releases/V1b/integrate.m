function I = integrate(F,z)
%
% INTEGRATE   Numerical integration
%
%    Calculate the integral(min(z):max(z)){F(z)*dz}
%
%       I = integrate(F,z)
%
%    Formula:
%
%       Let F = [F(1), F(2), ..., F(n)]'
%       and z = [z(1), z(2), ..., z(n)]
%    or
%       Let F = [f1, f2, ..., fm]          (m columns)
%       with f = [f(1), f(2), ..., f(n)]'
%
%             max(z)
%       I = Integral f(z)*dz ~ f'*(dz1+dz2)/2
%             min(z)
%    where
%       dz1 := [z(2)-z(1), z(3)-z(2), ..., z(n)-z(n-1),  0   ]'
%       dz2 := [    0    , z(2)-z(1), z(3)-z(2),..., z(n)-z(n-1)]'
%
%   See also: CORE
%
   if (min(size(z)) ~= 1)
      error('z (arg2) must be an n-vector!');
   end

   if (min(size(F)) == 1)
      F = F(:);             % make sure we have a vector
   end
   
   if (size(F,1) ~= length(z))
      error('sizes of F and z (arg1 & arg2) must match!');
   end
   
   z = z(:);
   dz = sdiff(z);

   I = dz' * F;    % results in a row vector of integral numbers
   return

%==========================================================================

function example
%
% EXAMPLE   Numerical integration example
%
   f = [1 2 3 1 2]'
   z = [1 2 4 7 8]'

   I = integrate(f,z)

   if (I ~= 14)
      error('integration error!');
   end

   F = [f 2*f 3*f]
   I = integrate(F,z)

   if (any(I ~= [14 28 42]))
      error('integration error!');
   end

