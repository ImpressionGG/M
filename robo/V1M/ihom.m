function [V,v] = ihom(Vh)
%
% IHOM      Inverse homogeneous coordinate transformation
%
%              v = ihom(vh)      % coordinate vector
%              V = ihom(Vh)      % set of coordinate vectors
%
%              [T,v] = ihom(Th)  % decomposition of Th = hom(T,v) 
%
%           Works with 2- or 3-vectors or matrices
%
%           Theory:
%
%              ihom(v) = v(1:m-1) / v(m)  % m = length(v)
%
%           Note: ihom(Vh) = ihom(k*Vh) for all k~=0 !!!
%
%           See also: ROBO, HOM
%
   [m,n] = size(Vh);
   
   if ( nargout == 1 )
      V = Vh(1:m-1,:) ./ (ones(m-1,1)*Vh(m,:)); 
   elseif (nargout == 2)
      if (m ~= n | m < 3 | m > 4) error('arg1 must be a quadratic 3H or 4H matrix!'); end
      if ( m == 3 )
         V = Vh(1:2,1:2);  v = Vh(1:2,3);
      elseif (m == 4)
         V = Vh(1:3,1:3);  v = Vh(1:3,4);
      else
         error('bug!')
      end
   else
      error('only one or two output args expected!');
   end

% eof   