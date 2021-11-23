function oo = inv(o,M)
%
% INV    invert a CORASIM object
%
%           o = system(corasim,{num,den})
%           oo = inv(o)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH,POLY, MATRIX, DET
%
   switch o.type
      case {'strf','ztrf','qtrf'}
         [num,den] = peek(o);
         oo = poke(o,den,num);
              
      case {'szpk','zzpk','qzpk'}
         zeros = o.data.zeros;
         poles = o.data.poles;
         K = o.data.K;
         
         o.data.zeros = poles;
         o.data.poles = zeros;
         o.data.K = 1/K;
         oo = o;
         
      case {'modal'}
         [num,den] = peek(o);
         oo = trf(o,den,num);

      otherwise
         error('type no supported')
   end
end
