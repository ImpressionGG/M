function oo = trf(o,num,den,T)
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
%            oo = trf(o,num,den,T)               % z-transfer function
%            oo = trf(o,num,den,-T)              % q-transfer function
%   
%            oo = trf(o)                         % cast to transfer fct
%
%         Copyright(c): Bluenetics 2020
%
%         See also: CORASIM, SYSTEM, PEEK
%
   if (nargin == 1)
      if isequal(o.type,'shell')
         oo = system(o,{1,1});
      else
         oo = trim(o);                          % cast to trf
      end
   elseif (nargin == 2)
      oo = system(o,{num,[1]});
   elseif (nargin == 3)
      oo = system(o,{num,den});
   elseif (nargin == 4)
      oo = system(o,{num,den},T);
   else
      error('1 up to 4 args expected');
   end
end
