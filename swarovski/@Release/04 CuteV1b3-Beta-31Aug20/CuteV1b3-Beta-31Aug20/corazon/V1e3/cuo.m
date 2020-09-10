function oo = cuo(o)                   % Get Current Shell Object            
%
% CUO   Get/Set Current Shell Object
%
%    Pull or refresh current object from current figure.
%
%       o = cuo();                % pull current object from current figure
%       o = cuo(o);               % refresh current object from current fig
%
%    See also CORAZITO, UTIL, SHO
%
   so = pull(corazon);                 % pull shell object
   if (nargin == 0)
      oo = current(so);
   elseif (nargin == 1)
      current(so,o);
      if (nargout > 0)
         oo = pull(so);
      end
   else
      error('0 or 1 input args expected!');
   end
end