function ok = argcheck(low,high,number)
%
% ARGCHECK   Check number of input arguments. Raise error if not between
%            low and high.
%
%               o.argcheck(low,high,number)
%
%            See also: CORAZITO
%
   if (number < low)
      error('Not enough input arguments.')
   elseif (number > high)
      error('Too many input arguments.')
   end
   ok = false;
end
