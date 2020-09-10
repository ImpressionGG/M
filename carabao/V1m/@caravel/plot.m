function oo = plot(o,varargin)
%
% PLOT   Caravel plot method
%
%           plot(o,'Image')            % plot image object
%           plot(o)                    % same as above
%
%        Example 1:
%           o = load(caravel,'myimage.png');
%           plot(o);
%
%        Example 2:
%           o = image(caravel,'Load','myimage.png');
%           plot(o);
%
%        See also: CARAVEL, IMAGE
%
   [gamma,oo] = manage(o,varargin,@Image);
   oo = gamma(oo);
end

%==========================================================================
% Local Plot Functions
%==========================================================================

function oo = Image(o)                 % Plot Image                    
   if (container(o))
      cls(o);                          % clear screen
      set(figure(o),'color',[1 1 1]);  % white background

      setting(o,'plot.handles',[]);    % clear handles
      list = basket(o);
      for (i=1:length(list))
         oo = list{i};
         plot(oo,'Image');
         hold on;                      % hold drawings
      end
%     set(figure(o),'color',[1 1 1]);  % white back ground
%     light('color',[1 1 1]);          % setup light for 3D graphics

      if container(current(o))
         comment = {'plot overlay of all objects of the','shell''s container object'};
         what(o,'All objects of the shell',comment);
      end
   else
      oo = image(o,'Plot');
      set(gca,'dataaspect',[1 1 1]);
   end
end
