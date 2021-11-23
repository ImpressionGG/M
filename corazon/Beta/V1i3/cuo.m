function oo = cuo(o)                   % Get Current Shell Object            
%
% CUO   Get/Set Current Shell Object
%
%    Pull or refresh current object from current figure.
%
%       oo = cuo;                 % pull current object from current figure
%       oo = cuo(oo);             % refresh current object from current fig
%
%    Remark: use 'cuo' only in the command console! 
%    In program code use method 'current' instead!
%
%       oo = current(corazon)     % same as: oo = cuo
%       current(corazon,oo)       % same as cuo(oo)
%
%    Copyright(c): Bluenetics 2020
%
%    See also CORAZITO, UTIL, SHO, CURRENT
%
   so = pull(corazon);            % pull shell object
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