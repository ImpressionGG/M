function oo = sho(o)                   % Get Shell Object            
%
% SHO   Get Shell Object
%
%    Pull or refresh shell object from current figure.
%
%       o = carabull.sho;         % pull shell object from current figure
%       o = carabull.sho(o);      % refresh shell object from current fig
%
%    Use a short hand for better readability.
%
%       sho = @carabull.sho       % provide short hand (8 µs)
%       sho = util(carabull,'sho')% provide short hand (190 µs)
%
%       o = sho();                % pull current object from current figure
%       o = sho(o);               % refresh current object from current fig
%
%    See also CARABULL, UTIL, CUO
%
   if (nargin == 0)
      oo = pull(carabao);
   elseif (nargin == 1)
      oo = push(carabao,o);
   else
      error('0 or 1 input args expected!');
   end
end
