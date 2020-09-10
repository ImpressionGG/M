function animate(o,X,Y,Z,color,rough)  % Animation
%
% ANIMATE   3D Animation   
%
%    Shows an animated body which can be parametrized by roughness
%    and color
%
%       animate(o,X,Y,Z,color,rough)   % animation with roughness & color
%       animate(o,X,Y,Z,'r',1)         % smooth red body
%       animate(o,X,Y,Z,'g',3)         % handy green body
%       animate(o,X,Y,Z,'b',2)         % harsh blue body
%       animate(o,X,Y,Z)               % color = 'w', rough = 0
%
%    Code lines: 40
%
%    See also: CARABULL
%
   if (nargin < 5)
      color = 'w';
   end

   if (nargin < 6)
      rough = 0;
   end

   o = caracow;
   o.data.X = X;
   o.data.Y = Y;
   o.data.Z = Z;
   
   o.work.hax = cla;                          % clear axes
   set(gcf,'WindowButtonDownFcn',@Stop);
   
   persistent time
   time = 0;  hdl = [];

   while(time >= 0)
      eval('delete(hdl);','');         % delete current drawings
      hdl = Thing(o,color,rough);      % plot thing
      view(o.work.hax,20*time,50);     % change view azimuth angle
      time = time + 0.3;               % increment time
      shg;  pause(0.1);                % show graphics & pause
   end
   
   function Stop(varargin)             % stop animation callback       
      time = -1;                       % stop animation
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function hdl = Thing(o,color,rough)    % Plot Thing            
%
% PLOT-THING   Plot 'bizarre thing', parameter rough (arg3) controls
%              the surface rooughness
%
%                 Thing(o,'r',0)       % smooth red surface
%                 Thing(o,'b',1)       % slightly rough blue surface
%                 Thing(o,'y',9)       % harsh yellow surface
%
   X = o.data.X;  X = X + rough*randn(size(X))/500;
   Y = o.data.Y;  Y = Y + rough*randn(size(Y))/500;
   Z = o.data.Z;  Z = Z + rough*randn(size(Z))/500;  
   
   hax = o.work.hax;
   hdl = surf(hax,X,Y,Z,'FaceColor',color,'LineStyle','none');   
   light('color',[1 1 1]);
   set(hax,'dataaspect',[1 1 1],'visible','off');
   set(hax,'xlim',[-2 2],'ylim',[-2 2],'zlim',[-2 2],'cameraviewangle',3.5);
   shg                                 % show graphics
end
  