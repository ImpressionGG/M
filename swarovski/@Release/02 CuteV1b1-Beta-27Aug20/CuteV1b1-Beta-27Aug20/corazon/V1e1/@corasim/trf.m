function oo = trf(o,num,den,T)
%
% TRF   Create a transfer function
%
%           o = system(corasim,A,B,C,D)
%           oo = trf(o)                % cast (e.g. from a system (A,B,C,D)
%
%       1) Continuous type (s-type) transfer function
%
%           oo = trf(o,num,den)        % create from numerator/denominator
%           oo = trf(o,[2 1],[1 5 6])  % create from numerator/denominator
%           oo = trf(corasim)          % same as trf(o,[1],[1])
%
%       2) Discrete type (z-type) transfer function
%
%           oo = trf(o,num,den,T)      % create from numerator/denominator
%           oo = trf(o,[2 1],[1 5 6],T)% create from numerator/denominator
%           oo = trf(corasim,1,1,T)
%
%        Example 1: Construct s-type transfer function
%
%                          5 s^2 + 14 s + 8                  
%                  G(s) = -------------------
%                           1 s^2 + 2 s + 1                  
%
%           oo = trf(o,[5 14 8],[1 2 1])
%
%        Example 2: Construct z-type transfer function
%
%                          3 z^2 + 7 z + 5                  
%                  G(s) = ------------------- @ T = 0.1
%                           7 z^2 + 2 z + 3                  
%
%           oo = trf(o,[3 7 5],[7 2 3],0.1)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORASIM, SYSTEM
%
   if (nargin == 1)
      if (isequal(o.type,'css') || isequal(o.type,'dss'))
         error('implementation');
      else
         oo = trf(o,1,1);
         return
      end
      
   elseif (nargin == 2)
      
      den = 1;  T = 0; typ = 'strf';
      
   elseif (nargin == 3)
      
      T = 0; typ = 'strf';
      
   elseif (nargin == 4)
      
      typ = 'ztrf';
      
   else
      error('1 to 4 args expected');
   end

      % setup object
      
   oo = type(o,typ);
   
   system.den = den;
   system.num = num;
   system.T = T;
   
   oo.par.system = system;
end      