function oo = plot(o,varargin)         % ANTENNA Plot Method           
%
% PLOT   ANTENNA plot method
%
%           plot(o)                    % default plot method
%           plot(o,'Plot')             % default plot method
%
%           plot(o,'Plot3D')           % 3D Antenna Diagram
%           plot(o,'PlotPolar')        % plot polar antenna diagram
%
%        See also: ANTENNA, SHELL
%
   [gamma,oo] = manage(o,varargin,@Plot,@Menu,@Callback,...
                       @Plot3D,@PlotPolar,@PlotXY,@PlotXZ,@PlotYZ);
   oo = gamma(oo);
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Menu(o)                  % Setup Plot Menu               
   oo = mitem(o,'3D Diagram',{@Callback,'Plot3D'});
   enable(oo,basket(o),{'ant'});
   
   oo = mitem(o,'-');
   oo = mitem(o,'Antenna Characteristics',{@Callback,'PlotPolar'});
   enable(oo,basket(o),{'pol','ant'});
end

%==========================================================================
% General Callback and Acting on Basket
%==========================================================================

function oo = Callback(o)              % General Callback              
%
% CALLBACK   A general callback with refresh function redefinition, screen
%            clearing, current object pulling and forwarding to executing
%            local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
  
   oo = current(o);                    % get current object
   gamma = eval(['@',mfilename]);
   oo = gamma(oo);                     % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end
function o = Basket(o)                 % Acting on the Basket          
%
% BASKET  Plot basket, or perform actions on the basket, screen clearing, 
%         current object pulling and forwarding to executing local func-
%         tion, reporting of irregularities and dark mode support
%
   refresh(o,o);                       % use this callback for refresh
   cls(o);                             % clear screen

   gamma = eval(['@',mfilename]);
   oo = basket(o,gamma);               % perform operation gamma on basket
  
   if ~isempty(oo)                     % irregulars happened?
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end

%==========================================================================
% Plot Functions
%==========================================================================

function oo = Plot(o)                  % Default Plot                  
   cls(o);                             % clear screen
   switch o.type
      case 'ant'                       % 3D antenna data
         oo = Plot3D(o);
      case 'pol'                       % polar antenna data
         oo = PlotPolar(o);          
      otherwise
         oo = []; return;
   end
end

%==========================================================================
% 3D-Plot of Type 'ant' Objects
%==========================================================================

function oo = Plot3D(o)                % Plot 3D Antenna Diagram       
   if ~o.is(o.type,'ant')
      oo = [];  return;
   end

      % brew-up measurement data and store brewed results in variables
      
   oo = brew(o);
   
      % access variables
      
   [gamma,phi_i,rho_i] = var(oo,'gamma,phi_i,rho_i');
   [X_meas,Y_meas,Z_meas] = var(oo,'X_meas,Y_meas,Z_meas');   
   n_theta = var(oo,'n_theta');

      % first bunch of plots
      % n_theta: samples on elevation
      
   for (j=1:n_theta)
      plot3(X_meas(:,j),Y_meas(:,j),Z_meas(:,j));
      hold on;
   end
   
      % setup and label axes
      
   axis([-30 30 -30 30 -30 30]);
   xlabel('X-ACHSE');
   ylabel('Y-ACHSE');
   zlabel('Z-ACHSE');
   
      % surf plot
   
   mapping = opt(o,{'style.mapping',1});
   %n_phi = n_az;
   
   if (mapping > 0)
      [phi_eut,theta_eut,rho_eut] = var(oo,'phi_eut,theta_eut,rho_eut');

      az= phi_eut.*pi/180;
      el= (theta_eut.*pi/180);
      azs = 0*pi/180;
      azi = 10*pi/180;
      aze = 360*pi/180;
      els = -90*pi/180;
      eli = 10*pi/180;
      ele = 90*pi/180;
      
      [Az_m El_m] = meshgrid(azs:azi:aze,els:eli:ele);
      
         %Interpolate the nonuniform gain data onto the uniform grid
         
      Zi = griddata(az,el,rho_eut,Az_m,El_m,'cubic');
      
         %Generate the cartesian coordinates
         
      [x y z] = sph2cart(Az_m,El_m,Zi);
      
         %Plot surface and colour according to Zi
         
      if opt(o,{'view.wireframe',0})
         surf(x,y,z);                  % wireframe)
      else
         surf(x,y,z,Zi,'FaceColor','interp','EdgeColor','none',...
                       'FaceLighting','phong');
      end
   else  
      %X_meas = cos(phi_meas.*pi/180).*cos(gamma.*pi/180).*rho_meas;
      % = sin(phi_meas.*pi/180).*cos(gamma.*pi/180).*rho_meas;
      %Z_meax = sin(gamma.*pi/180).*rho_meas;
      %[X Y Z] = [X_meas;Y_meas;Z_meas];
      X=X_meas;
      Y=Y_meas;
      Z=Z_meas;
      rho_meas = data(oo,'rho');
      %surf(X,Y,Z,'FaceColor','interp',...
      %   'EdgeColor','none',...
      %   'FaceLighting','phong');
      surf(X,Y,Z,rho_meas,'FaceColor','interp',...
         'EdgeColor','none',...
         'FaceLighting','phong');
      %sur2stl('testsurf1.stl', X , Y , Z,'ascii');
      
      %  surf(X,Y,Z); % wireframe
      %daspect([5 5 5]);
      %%mesh(X,Y,Z);
   end %if 
   
   camlight right
   axis vis3d;
   %rotate3D on;
   ax=gca;
   %fig2u3d(ax);
   %figure2xhtml;

      % display heading
      
   uscore = util(sho,'uscore');
   heading(o);
end

%==========================================================================
% Polar Plot of Type 'pol' and 'ant' Objects
%==========================================================================

function oo = PlotPolar(o)                                             
%
% PlotPolar  Plot antenna characteristics in polar coordinates
%
%               phi = 0:10:360;
%               db = 30*sin(4*phi/180+pi);
%
%               oo = antenna('polar');       % polar data type
%               oo = data(oo,'phi,db',phi,db);
%               oo = opt(oo,'min,max',-50,50);
%               plot(oo);
%    
   switch o.type
      case 'pol'                       % polar data         
         oo = o;                       % no errors
      case 'ant'
         o = Ant2Pol(o);               %  convert object type
      otherwise
         oo = [];  return;
   end

   phi = data(o,'phi') * pi/180;
   db = data(o,'db');
   
   oo = with(o,'diagram');
   diagram(oo,phi,db);                  % plot antenna diagram
end
function oo = Ant2Pol(o)                                               
   oo = brew(o);                       % brew-up measurement data
   
      % access variables
      
   [X_meas,Y_meas,Z_meas] = var(oo,'X_meas,Y_meas,Z_meas');   
   n_theta = var(oo,'n_theta');

      % first bunch of plots
      % n_theta: samples on elevation
      
   j = round((n_theta+1)/2);
   x = X_meas(:,j);
   y = Y_meas(:,j);
   z = Z_meas(:,j);
   
   phi = atan2(y,x) * 180/pi;
   db = sqrt(x.*x + y.*y);
   
      % create polar typed ANTENNA object
      
   oo = type(o,'pol');                 % change type to polar data type
   oo = data(oo,'phi,db',phi,db);
end
