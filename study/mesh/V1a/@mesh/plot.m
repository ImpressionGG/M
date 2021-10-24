function oo = plot(o,varargin)         % MESH Plot Method
%
% PLOT   MESH plot method
%
%           plot(o)                    % default plot method
%           plot(o,'Plot')             % default plot method
%
%           plot(o,'PlotX')            % stream plot X
%           plot(o,'PlotY')            % stream plot Y
%           plot(o,'PlotXY')           % scatter plot
%
%        See also: MESH, SHELL
%
   [gamma,oo] = manage(o,varargin,@Plot,@Menu,@WithCuo,@WithSho,@WithBsk,...
                       @Overview,@PlotX,@PlotY,@PlotXY);
   oo = gamma(oo);
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Menu(o)                  % Setup Plot Menu
%
% MENU  Setup plot menu. Note that plot functions are best invoked via
%       Callback or Basket functions, which do some common tasks
%
   oo = mitem(o,'Overview',{@WithCuo,'Overview'});
end

%==========================================================================
% Launch Callbacks
%==========================================================================

function oo = WithSho(o)               % 'With Shell Object' Callback  
%
% WITHSHO General callback for operation on shell object
%         with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
 
   gamma = eval(['@',mfilename]);
   oo = gamma(o);                      % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end
function oo = WithCuo(o)               % 'With Current Object' Callback
%
% WITHCUO A general callback with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
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
function oo = WithBsk(o)               % 'With Basket' Callback        
%
% WITHBSK  Plot basket, or perform actions on the basket, screen clearing, 
%          current object pulling and forwarding to executing local func-
%          tion, reporting of irregularities and dark mode support
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
% Default Plot Functions
%==========================================================================

function oo = Plot(o)                  % Default Plot
%
% PLOT The default Plot function shows how to deal with different object
%      types. Depending on type a different local plot function is invoked
%
   args = arg(o);                      % this is for debug only!
o = arg(o,{[]});
      % arglist could be for corazon/plot, which means that we just call
      % corazon plot with the syntax plot(corazon,o). If corazon/plot
      % recognizes a proper arglist it performs the plot call and returns
      % either the plot handles or NaN, which means that we are done
      % and return from the function call (with empty out arg)
      
   oo = plot(corazon,o);               % if arg list is for corazon/plot
   if ~isa(oo,'corazon')               % is oo an array of graph handles?
      %return                           % in such case we are done - bye!
   else
      oo = o;                          % make sure we return a MESH object
   end

   cls(o);                             % clear screen
   switch o.type
      case 'traf'
         oo = Overview(o);
      otherwise
         oo = [];  return              % no idea how to plot
   end
end

%==========================================================================
% Local Plot Functions (are checking type)
%==========================================================================

function o = Overview(o)              % Plot Overview
   if ~type(o,{'traf'})
      oo = []; return                  % no idea how to plot this type
   end

   Tobs = o.data.Tobs/1000;
   t = o.data.t/1000;
   [m,n] = size(t);
   i1 = 1:2:n-1;  i2 = i1+1;
   
   y = (1:size(t,1))'*ones(size(t(1,:))); 
   
   plot([0,Tobs],y(:,[1,n]),'b');
   hold on;
   plot(t(:,i1),y(:,i1),'c>'); 
   plot(t(:,i2),y(:,i2),'c<');
   subplot(o);
   
      % find collisions
      
   [m,n] = size(t);
   for (i=1:m)
      for (j=1:2:n-1)
         lower = t(i,j)*ones(m,n);  upper = t(i,j+1)*ones(m,n);
         collision = (t >lower & t < upper);
      end
      
      for (k=1:m)
         if any(collision(k,:))
            plot(t(i,j:j+1),[i i],'ro');
            for (l=1:n)
               if collision(k,l)
                  plot(t(k,l)*[1 1],[i,k],'r');
                  %plot(t(k,l),k,'yo');
               end
            end
         end
      end
   end
   heading(o);
end
