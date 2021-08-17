function ready(o)
%
% READY   Change mouse pointer to 'ready symbol' and restore object's 
%         title in figure bar.
%
%            ready(o)                  % set ready state
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CARABUL, BUSY
%
   fig = figure(o);
   if isempty(fig)
      fig = gcf(o);
   end
   
   if ~isempty(fig)                    % only if there is an active figure
      set(fig,'pointer','arrow');      % change pointer symbol to 'ready'
      
      if isequal(class(o),'corazita')
         fig = figure(o);              % object's figure handle
         if isequal(current,fig)
            menu(o,'Title');           % restore object title
         end
      end
   end
end   
   