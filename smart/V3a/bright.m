function bright(fig)
%
% BRIGHT   set bright background of figure
%
%          See also: DARK, WHITEBG
%
   if (nargin < 1),
      fig = gcf;
   end
   
   dark(fig);
   whitebg(fig);        % invert background and set white
   set(fig,'color',[1 1 1]); % set(gcf,'color',[1 1 1]);
   
   figure(fig); % figure(gcf);   % shg

% eof
