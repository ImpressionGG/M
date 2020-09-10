function ready(o)
%
% READY   Change mouse pointer to 'ready symbol' and restore object's 
%         title in figure bar.
%
%            ready(o)                  % set ready state
%
%        See also: CARABUL, BUSY
%
   current = gcf(o);                   % current figure
   if ~isempty(current)                % only if there is an active figure
      set(gcf,'pointer','arrow');      % change pointer symbol to 'ready'
      
      fig = figure(o);                 % object's figure handle
      if isequal(current,fig)
         menu(o,'Title');              % restore object title
      end
   end
end   
   