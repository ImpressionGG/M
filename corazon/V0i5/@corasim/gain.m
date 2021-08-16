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
   if type(o,{'css'})
      [A,B,C,D] = system(o);
      if (det(A) ~= 0)
         lambda = 0;
         V = -C*inv(A)*B + D;
         if (V ~= 0)                   % if no zero at s=0
            return;                    % found - bye!
         end                           % otherwise chose path via trf
      end
      o = trf(o);                      % convert to transfer function
   elseif type(o,{'modal'})
      o = trf(o);                      % convert to transfer function
   end
   
   if type(o,{'strf','qtrf'})
      [V,lambda] = TrfGain(o);
   elseif type(o,{'szpk'})
      [V,lambda] = ZpkGain(o);
   else
      error('only types strf, qtrf, css and modal are supported');
   end
end

function [V,lambda] = TrfGain(o)       % Calculation of Gain and Lambda
   assert(type(o,{'strf','qtrf'}));
   
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
function [V,lambda] = ZpkGain(o)       % Calculation of Gain and Lambda
   assert(type(o,{'szpk'}));
   
   [z,p,k] = zpk(o);
   lambda = 0;
   idx = find(z==0);
   lambda = lambda - length(idx);
   if ~isempty(idx)
      z(idx) = [];
   end
   
   idx = find(p==0);
   lambda = lambda + length(idx);
   if ~isempty(idx)
      p(idx) = [];
   end
   
   V = k*prod(-z)/prod(-p);
   if (abs(imag(V)/real(V)) < eps)
      V = real(V);
   end
end
