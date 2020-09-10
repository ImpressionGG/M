function busy(o,msg)
%
% BUSY   Change mouse pointer to 'busy symbol' and set busy message in
%        figure bar.
%
%           busy(o)                    % set busy state
%           busy(o,'plotting ...')     % set busy state and set message
%
%        See also: CARABULL, READY
%
   set(gcf,'pointer','watch');    % change pointer symbol to 'busy' symbol
   if (nargin >= 2)
      set(figure(o),'name',msg);
   end
end   
   