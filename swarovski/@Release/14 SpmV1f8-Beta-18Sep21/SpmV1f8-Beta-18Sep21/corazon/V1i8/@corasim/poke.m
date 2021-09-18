function o = poke(o,oo,i,j)            % Poke CORASIM Object @ Index    
%
% POKE   Poke CORASIM object to an index location of an encapsulating
%        CORASIM matrix
%     
%           o = poke(o,oo,i,j)         % poke oo to i/j-th location  
%           o = poke(o,num,den)        % poke numerator/denominator
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORASIM, PEEK, POKE
%
   if (nargin == 3)
      if ~type(o,{'strf','ztrf','qtrf'})
         error('transfer function type expected');
      end
      num = oo;  den = i;              % rename input args
   end
   
   switch o.type
      case {'strf','ztrf','qtrf'}
         o.data.num = num;
         o.data.den = den;
         
      case 'matrix'
         o.data.matrix{i,j} = oo; 
         
      otherwise
         error('bad type');
   end
end
