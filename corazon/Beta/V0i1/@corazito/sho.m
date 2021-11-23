function oo = sho(o)                   % Get Shell Object            
%
% SHO   Get Shell Object
%
%    Pull or refresh shell object from current figure.
%
%       o = corazito.sho;         % pull shell object from current figure
%       o = corazito.sho(o);      % refresh shell object from current fig
%
%    Use a short hand for better readability.
%
%       sho = @corazito.sho       % provide short hand (8 �s)
%       sho = util(corazito,'sho')% provide short hand (190 �s)
%
%       o = sho();                % pull current object from current figure
%       o = sho(o);               % refresh current object from current fig
%
%    Copyright(c): Bluenetics 2020 
%
%    See also CORAZITO, UTIL, CUO
%
   if (nargin == 0)
      oo = pull(corazon);
   elseif (nargin == 1)
      oo = push(corazon,o);
   else
      error('0 or 1 input args expected!');
   end
end
