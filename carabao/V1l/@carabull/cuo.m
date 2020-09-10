function oo = cuo(o)                   % Get Current Shell Object            
%
% CUO   Get Current Shell Object
%
%    Pull or refresh current object from current figure.
%
%       o = carabull.cuo;         % pull current object from current figure
%       o = carabull.cuo(o);      % refresh current object from current fig
%
%    Use a short hand for better readability.
%
%       cuo = @carabull.cuo            % provide short hand (8 µs)
%       cuo = util(carabull,'cuo')     % provide short hand (190 µs)
%
%       o = cuo();                % pull current object from current figure
%       o = cuo(o);               % refresh current object from current fig
%
%    See also CARABULL, UTIL, SHO
%
   if (nargin == 0)
      oo = current(pull(carabao));
   elseif (nargin == 1)
      oo = current(pull(carabao),o);
      push(oo);
      if (nargout > 0)
         oo = pull(carabao);
      end
   else
      error('0 or 1 input args expected!');
   end
end
