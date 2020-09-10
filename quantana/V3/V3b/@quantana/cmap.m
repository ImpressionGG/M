function [obj,map] = cmap(obj,name)
%
% CMAP   Set specific color map
%
%           cmap(quantana,'fire')       % set fire like color map
%           cmap(quantana,'phase')      % to visualize phases
%           cmap(quantana,'complex')    % to visualize complex numbers
%           cmap(quantana,'alpha')      % to visualize phases
%           cmap(quantana,'pale')       % to visualize pales
%
%           [obj,map] = cmap(obj,name); % returnmap without changing display

%        See also: QUANTANA, COLORMAP
%
   switch name
       case 'fire'
          map = colormap(hot(550));
          map = brighten(0.5);
          map = map(1:512,:);
          map(1,:) = [0.3 0.05 0.05];   % blue [0 0 0.3]
          
       case 'alpha'
          map = zeros(256,3);
          for (i=1:256)
             phi = 2*pi/256 * (i-1);
             z = exp(sqrt(-1)*phi);
             map(i,:) = pcolor(obj,z);
          end
           
       case 'phase'
          map = colormap(hsv(256));
           
       case 'complex'
          N = 64;
          Nb = N/4; Np = N*4;   % Nb = 8; Np = 32;      
          map = zeros(Np*Nb,3);
          
          for (b=1:Nb)     % brightness loop
             for (i=1:Np)  % phase loop
                phi = 2*pi/Np * (i-1);
                z = exp(sqrt(-1)*phi);
                idx = (b-1)*Np+i;
                map(idx,:) = (b/Nb)^0.9 * pcolor(obj,z);  % ^0.6
             end
          end
          
      case {'pale','jolly'};
         clist = color;      % get list of symbolic colors
         map = [];
         for (i=1:length(clist))
            rgb = color(clist{i});
            block = (1:16)'*rgb/16;
            %block = [8+(1:16)/2]'*rgb/16;
            map = [map; block];
            caxis([1 256]);
         end
            
       otherwise
          name
          error('bad name for colormap!');
   end
   
   obj = option(obj,'cmap.name',name);
   
   if (nargout <= 1)
       colormap(map);     % change display
       [m,n] = size(map);
   end
   
   return
   
% eof