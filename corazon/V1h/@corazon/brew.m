function oo = brew(o,varargin)
%
% BREW   Corazon BREW method - to be used as a skeleton for particular
%        brew method of a dirived object. BREW is closely related to the 
%        CACHE method (see corazon/cache for details).
%
%           oo = brew(oo,'Polar')      % brew polar cache segment
%
%           oo = brew(oo,'All')        % brew all cache segments
%           oo = brew(oo)              % same as above
%
%        Remark: BREW should be written to reject container objects
%
%        Example: a 'polar' cache segment is supported which provides
%        cached radius (r) and cached angle (p like phi), while angle
%        is either in degrees or radians, controlled by setting
%        'polar.unit'.
%
%           setting(sho,'polar.deg',true);
%           oo = data(corazon('pol'),'x,y',randn(1,10),randn(1,10));
%           oo = brew(oo,'Polar');     % brew polar cache segment
%           paste(oo)                  % make current object
%
%           oo = current(sho)
%           p = cache(oo,'polar.p')    % get cached phi in degrees
%
%        if we change polar unit then by accessing the cache an implicite
%        cache refresh happens by calling brew method
%
%           setting(sho,'polar.deg',false);
%           oo = current(sho)
%           p = cache(oo,'polar.p')    % get cached phi in radians
%
%        The according local brewer function is
%
%           function oo = Polar(o)     % Brewer for Polar Cache Segment
%              deg = opt(o,{'polar.deg',0});
%              [x,y] = data(o,'x,y');
%              r = sqrt(x.*x+y.*y);
%              p = atan2(y,x) * o.iif(deg,180/pi,1);
%              oo = cache(o,{'polar','Polar'},struct('r',r,'p',p));
%           end
%
%       Copyright(c): Bluenetics 2020
%
%       See also: CORAZON, CACHE
%
   if container(o)
      error('brew does not work for container objects');
   end
   
   [gamma,oo] = manage(o,varargin,@All,@Polar);
   oo = gamma(oo);
end

%==========================================================================
% Brew All 
%==========================================================================

function oo = All(o)                   % Brew All                      
   oo = Polar(o);                      % brew polar cache segment
end

%==========================================================================
% Brew Polar Cache Segment 
%==========================================================================

function oo = Polar(o)                 % Brew Polar Cache Segment                      
   deg = opt(o,{'polar.deg',0});       % degrees (1) or radians (0)

   [x,y] = data(o,'x,y');              % fetch x/y data
   r = sqrt(x.*x+y.*y);                % calc radius of polar coordinates
   p = atan2(y,x);                     % calc phi (in rad) of polar coord
   
   if (deg)                            % conversion to degrees required?
      p = p*180/pi;                    % convert phi to degrees
   end
   
      % store r and p in 'polar' cache segment ...
      
   bag.r = r;  bag.p = p;
   oo = cache(o,{'polar','Polar'},bag);% stoee r and p in 'polar' cache
end

