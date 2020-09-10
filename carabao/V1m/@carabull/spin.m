function spin(o)                       % Spin View
%
% SPIN   Spin View   
%
%    See also: CARABULL
%
   %set(gcf,'WindowButtonDownFcn',@Stop);

   hax = gca;
   set(hax,'dataaspect',[1 1 1],'visible','off');

   persistent time
   time = 0;  hdl = [];

   va = get(hax,'CameraViewAngle');    % initial view angle

   set(gcf,'WindowButtonDownFcn','terminate(sho)');
   timer(o,0.01);
   while(~stop(o) && time >= 0)
      view(hax,20*time,50);            % change view azimuth angle
      set(hax,'CameraViewAngle',va);   % maintain view angle

      time = time + 0.2;               % increment time
      drawnow;  pause(0.1);            % show graphics & pause
   end
   set(gcf,'WindowButtonDownFcn','');
   
%  function Stop(varargin)             % stop animation callback       
%     time = -1;                       % stop animation
%  end
end
 