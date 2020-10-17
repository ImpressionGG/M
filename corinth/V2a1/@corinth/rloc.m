function rloc(o,num,den)               % Plot Root Locus               
%
% RLOC  Root locus plot
%
%          rloc(G)                     % plot root locus of system
%          rloc(o,num,den)             % plot root locus of transfer fct.
%
%       Options
%
%          xlim              real part limits        (default: [])
%          ylim              imaginary part limits   (default: [])
%
%       Copyright8c): Bluenetics 2020
%
%       See also: CORINTH, TRF
%
   if (nargin == 1)
      switch o.type
         case 'trf'
            [num,den] = peek(o);
         otherwise
            error('type not yet supported');
      end
   elseif (nargin == 3)
      'ok';
   else
      error('1 or 3 input args expected');
   end
   
      % plot root locus ...
      
   oo = inherit(corasim,o);            % inherit options to new corasim obj
   rloc(oo,num,den);                   % delegate to corasim/rloc
end