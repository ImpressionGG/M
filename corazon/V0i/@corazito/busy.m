function busy(o,msg)
%
% BUSY   Change mouse pointer to 'busy symbol' and set busy message in
%        figure bar.
%
%           busy(o)                    % set busy state
%           busy(o,'plotting ...')     % set busy state and set message
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZITO, READY
%
   fig = figure(o);
   set(fig,'pointer','watch');    % change pointer symbol to 'busy' symbol
   if (nargin >= 2)
      set(fig,'name',msg);
   end
end   
   