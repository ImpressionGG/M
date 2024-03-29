function [oo,den,T] = trf(o,num,den,T)                                         
%
% TRF     Make transfer function
%
%            oo = trf(corasim);                  G(s) = 1/1
%            oo = trf(o,num)                     % deniminator = [1]
%
%            oo = trf(o,num,den)                 % s-transfer function
%            oo = trf(o,num,den)                 % s-transfer function
%            oo = trf(o,[2 3],[1 5 6])           % s-transfer function
%
%            oo = trf(o,num,den,0)               % s-transfer function
%            oo = trf(o,num,den,T)               % z-transfer function
%            oo = trf(o,num,den,-T)              % q-transfer function
%   
%            oo = trf(o,{zeros,poles,K})         % s-transfer function       
%            oo = trf(o,{zeros,poles,K},T)       % z-transfer function       
%            oo = trf(o,{zeros,poles,K},-T)      % q-transfer function       
%
%            oo = trf(o)                         % cast to transfer fct
%
%            [num,den,T] = trf(o)                % peek num/den/T
%
%         Copyright(c): Bluenetics 2020
%
%         See also: CORASIM, SYSTEM, PEEK, ZPK, GAIN
%
   if (nargout > 1 && nargin == 1)
      [oo,den,T] = peek(o);                      % forward to peek method
   elseif (nargin == 1)
      if type(o,{'shell'})
         oo = system(o,{1,1});
      elseif type(o,{'szpk','zzpk','qzpk'})
         oo = Zp2Tf(o);
      elseif type(o,{'psiw'})
         oo = system(o);                         % cast psiw to system
         oo = trim(oo);                          % cast system to trf
      else
         oo = trim(o);                           % cast to trf
      end
   elseif (nargin == 2)
      zpk = num;                                 % rename arg2
      if iscell(zpk)
         oo = TrfZpk(o,zpk);
      else
         oo = system(o,{num,[1]});
      end
   elseif (nargin == 3)
      zpk = num;  T = den;                       % rename arg2 & arg3
      if iscell(zpk)
         oo = TrfZpk(o,zpk,T);
      else         
         oo = system(o,{num,den});
      end
   elseif (nargin == 4)
      oo = system(o,{num,den},T);
   else
      error('1 up to 4 args expected');
   end
end

%==========================================================================
% Create Transfer Function from Zeros, Poles and K
%==========================================================================

function oo = TrfZpk(o,zpk,T)          % Create Trf from Zero/Poles/K  
   if (nargin < 3)
      T = 0;
   end
   
   if (length(zpk) ~= 3)
      error('arg2 ({zeros,poles,K}) must have 3 list elements');
   end
   
   zeros = zpk{1};  zeros = zeros(:);
   if ~isa(zeros,'double')
      error('double or complex vector expected for zeros');
   end

   poles = zpk{2};  poles = poles(:);
   if ~isa(poles,'double')
      error('double or complex vector expected for poles');
   end
   
   K = zpk{3};
   if ~isa(K,'double') || length(K) ~= 1
      error('double scalar expected for K');
   end
   
   if (T > 0)
      oo = corasim('zzpk');            % discrete system, z-trf
   elseif (T < 0)
      oo = corasim('qzpk');            % discrete system, q-trf
   else
      oo = corasim('szpk');            % continuous system, s-trf
   end
      
   oo.data.T = T;                      % store sampling time
   oo.data.zeros = zeros;
   oo.data.poles = poles;
   oo.data.K = K;
end
function oo = Zp2Tf(o)                 % Convert Zeros/Poles/K to TRF  
%
% ZP2TF	Zero-pole to transfer function conversion.
%	      
%           oo = Zp2Tf(o,Z,P,K)  forms the transfer function:
%
%			           num(s)
%		      G(s) = -------- 
%			           den(s)
%
%	given a set of zero locations in vector Z, a set of pole locations
%	in vector P, and a gain in scalar K.  Vectors NUM and DEN are 
%	returned with numerator and denominator coefficients in descending
%	powers of s.  See TF2PZ to convert the other way.
%
   assert(type(o,{'szpk','zzpk','qzpk'}));
   
   z = o.data.zeros;
   p = o.data.poles;
   K = o.data.K;
   T = o.data.T;
   
   den = real(Poly(p(:)));
   [m,n] = size(z);
   
   num = [];
   for j=1:n
      zj = z(:,j);
      pj = real(Poly(zj)*K(j));
      num(j,:) = [zeros(1,1+m-length(pj)) pj];
   end
   
   if isempty(num)
      oo = trf(o,K,den);
   else
      oo = trf(o,num,den,T);
   end
   
   function p = Poly(s)
      if isa(s,'sym')
         p = charpoly(diag(s));
      else
         p = poly(s);
      end
   end
end
