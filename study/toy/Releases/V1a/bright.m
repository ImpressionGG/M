function bright(fig)
%
% BRIGHT   Set bright background of figure
%
%             bright              % use current figure
%             bright(fig)         % use specified figure
%
%          See also: CORE, DARK
%
   if (nargin < 1) fig = gcf; end
   
   dark(fig);
   whitebg(fig);        % invert background and set white
   set(gcf,'color',[1 1 1]);
   
   figure(gcf);   % shg
   return
end

