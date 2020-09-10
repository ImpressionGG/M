function shit(o,rough,color)           % Shit Animation
%
% SHIT   Shit Animation   
%
%    Shows an animated shit which can be parametrized by roughness
%    and color
%
%       shit(o,rough,color)            % shit with roughness & color
%       shit(o,1,'r')                  % smooth red shit
%       shit(o,3,'g')                  % handy green shit
%       shit(o,9,'b')                  % harsh blue shit
%
%    Code lines: 40
%
%    See also: CARACOW
%
   o = Provide(o);                     % provide data, if not available
   hax = cla;                          % clear axes
   o = work(o,'hax',hax);              % carry current axes handle
   set(gcf,'WindowButtonDownFcn',@Stop);
   
   persistent time
   time = 0;  hdl = [];

   while(time >= 0)
      eval('delete(hdl);','');         % delete current drawings
      hdl = Bizzare(o,rough,color);    % plot bizzare thing
      view(hax,20*time,50);            % change view azimuth angle
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

function o = Provide(o)
%
% PROVIDE   Provide data, if not provided
%
   X = data(o,'X');
   if isempty(X)
      k = 2;  p = 10;  r = 0.6;      % frequencies
      [S,B] = meshgrid(-pi/2:pi/5000:pi/2,[-3,3]);
      
         % U/V determines the helix, X/Y/Z determines the path
         
      U = B.*cos(p*23*S);  V = B.*sin(p*23*S);
      X = r*sin(k*39*S); Y = r*sin(k*83*S);  Z = r*sin(k*47*S);

         % the path fills a cube. squease cube into ball
         
      R = sqrt(X.*X+Y.*Y+Z.*Z);  R = max(0.3*ones(size(R)),R);
      X = X./R;  Y = Y./R;  Z = Z./R;    % cube shape -> ball shape 
      
         % combine the path with the helix
         
      Y = Y + 0.1*U;  Z = Z + 0.1*V;
      o = data(o,'X',X);  o = data(o,'Y',Y);  o = data(o,'Z',Z);
   end
end

function hdl = Bizzare(o,rough,color)  % Plot Bizzare Thing            
%
% PLOT-THING   Plot 'nucleonic thing', Parameter roughness (arg2) controls
%              the surface rooughness
%
%                 PlotThing(o,0,'r')   % smooth red surface
%                 PlotThing(o,1,'b')   % slightly rough blue surface
%                 PlotThing(o,9,'y')   % harsh yellow surface
%
   X = data(o,'X');  X = X + rough*randn(size(X))/250;
   Y = data(o,'Y');  Y = Y + rough*randn(size(Y))/250;
   Z = data(o,'Z');  Z = Z + rough*randn(size(Z))/250;  
   
   smash = data(o,'smash');   
   if isempty(smash)
      smash = 0.1;
   end
   Z = Z*smash;
   
   hax = work(o,'hax');
   hdl = surf(hax,X,Y,Z,'FaceColor',color,'LineStyle','none');   
   light('color',[1 1 1]);
   set(hax,'dataaspect',[1 1 1],'visible','off');
   set(hax,'xlim',[-2 2],'ylim',[-2 2],'zlim',[-2 2],'cameraviewangle',3.5);
   shg                                 % show graphics
end
  