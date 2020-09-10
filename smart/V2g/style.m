function hdl = style(hdl,col,width)
%
% STYLE   Change style parameters (color and line width) according to
%         a graphic object's handle. Graphics objects can be either lines
%         orpatches.
%
%            hdl = plot([0 1],[0 1]);
%            style(hdl,'g');     % set green color 
%            style(hdl,'g',3);   % set green color and also linewidth = 3
%
%            hdl = patch([0 1 1 0 0],[0 0 1 1 0]);
%            style(hdl,'g');     % set green color 
%            style(hdl,'g',3);   % set green color and also linewidth = 3
%
%         See a convinient syntax for an easy plot including color and
%         line width setting:
%
%            style(plot(x,y),'r',3);       % to plot a line
%            style(plot(x,y,'o'),'r',3);   % to plot balls
%
%            style(patch(x,y,'-'),'r',3);  % note: patch requires a '-' arg
%
%         See also: SMART, COLOR, PLOT, PATCH

   if (nargin < 2)
       error('2 or 3 args expected!');
   end
   
   for (i=1:length(hdl))
      type = get(hdl(i),'Type');
      switch type
         case 'line'
            set(hdl,'color',color(col));
            if (nargin == 3)
               set(hdl,'linewidth',width);
            end
      
         case 'patch'
            set(hdl,'facecolor',color(col));
            if (nargin == 3)
               set(hdl,'linewidth',width);
            end
      end
   end
   return
   
% eof      
   
