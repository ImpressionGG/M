function [V,lambda] = gain(o)
%
% GAIN   Calculate gain and lambda of a transfer function.
%
%           G = trf(o,[1 2],[1 5 6 0 0])
%           [V,lambda] = gain(G)
%
%        To do so the transfer function has to bewritten in the following
%        form which directly allows to read V and lambda
%
%                     V        p(s)
%           G(s) = -------- * ------    with p(0) = q(0) = 1 
%                  s^lambda    q(s)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORASIM, TRF
%
   switch o.type
      case 'trf'
         [V,lambda] = Gain(o);
      otherwise
         error('implementation');
   end
end

function [V,lambda] = Gain(o)          % Calculation of Gain and Lambda
   assert(type(o,{'trf'}));
   
   o = trim(o);
   [num,den] = peek(o);
   
      % for zero numerator V = 0, lambda = 0

   if isequal(den,0)
      error('denominator must be non-zero');
   end
      
   if isequal(num,0)
      V = 0;  lambda = 0;
      return
   end
      
      % calculate V and lambda
      
   lambda = 0;
   for (i=length(num):-1:1)
      if (num(i) == 0)
         lambda = lambda - 1;
         num(end) = [];
      else
         break;
      end
   end
   
   for (i=length(den):-1:1)
      if (den(i) == 0)
         lambda = lambda + 1;
         den(end) = [];
      else
         break;
      end
   end
   
   V = num(end)/den(end);
end