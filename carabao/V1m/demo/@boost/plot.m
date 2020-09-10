function oo = plot(o,varargin)         % Boost Plot Method             
%
%  PLOT   Plot method for BOOST objects
%
%            plot(o,'Phase')           % phase plane plot
%
%         See also: BOOST
%
   [gamma,oo] = manage(o,varargin,@Default,@Setup,@Plot,@Phase,@Print);
   oo = gamma(oo);
end

%==========================================================================
% Plot Menu Setup
%==========================================================================

function oo = Setup(o)                 % Plot Menu
   setting(o,{'print.lines'},10);
   
   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = mitem(oo,'Basic');
   oooo = menu(ooo,'Plot');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Stream Plot',{@Plot,'Stream'});
   ooo = mitem(oo,'Phase Plot',{@Plot,'Phase'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Print');
   oooo = mitem(ooo,'t,y,q',{@Print,{'t','y','q','phi'}});
   oooo = mitem(ooo,'t,y,q,b,g',{@Print,{'t','y','q','b','g'}});
   oooo = mitem(ooo,'t,y,q,b,g,x1,x2,z1,z2',...
             {@Print,{'t','y','q','b','g','x1','x2','z1','z2'}});
   ooo = mitem(oo,'Lines',{},'print.lines');
   choice(ooo,{{'10',10},{'20',20},{'All',inf}},{});
end
function oo = Plot(o)                  % Plot Callback                 
   args = arg(o,0);                    % get arg list
   oo = arg(o,[{'Plot'},args]);        % add 'Plot' header to arg list
   oo = cast(oo,'caramel');            % cast to caramel object
   oo = plot(oo);                      % call plot(oo,'Plot')
end
function oo = Default(o)               % Default Plot Entry Point      
   co = cast(o,'caramel');             % cast to CARAMEL
   oo = plot(co,'Default');            % delegate to caramel/plot
end

%==========================================================================
% Local Plot Functions
%==========================================================================

function oo = Phase(o)                 % Phase Plot                    
   function oo = SystemPhase(o)        % System Phase Plane Plot       
      oo = current(o);
      x1 = data(oo,'x1');
      x2 = data(oo,'x2');

      cls(o);
      plot(x1,x2,'g-');  hold on;
      plot(x1,x2,'k.');
      title('Phase Plot X1/X2');
   end
   function oo = ObserverPhase(o)      % Observer Phase Plane Plot     
      oo = current(o);
      [x1,x2,z1,z2] = data(oo,'x1','x2','z1','z2');
      G = opt(o,'study.G');

      cls(o);
      plot(x1,x2,'g-');  hold on;
      plot(x1,x2,'k.');
      plot(z1,z2,'m-');  hold on;
      plot(z1,z2,'m.');
      title(sprintf('Phase Plot X/Z (G = %g)',G));
   end

   type = active(o);                   % get active type
   switch type
      case 'system'
         oo = SystemPhase(o);
      case 'observer'
         oo = ObserverPhase(o);
      otherwise
         oo = ObserverPhase2(o);
   end
   set(gca,'DataAspectRatio',[1 1 1]);
end

%==========================================================================
% Local Plot Functions
%==========================================================================

function oo = Print(o)
   oo = current(o);
   list = arg(o,1);
   lines = opt(o,'print.lines');
   n = length(oo.data.t);
   if isinf(lines)
      lines = n;
   end
   lines = min(lines,n);
   
   for (j=1:length(list))
      sym = list{j};
      if (j == 1)
         fprintf('%8s',list{j});
      else
         fprintf('%10s',list{j});
      end
   end
   fprintf('\n');
   
   bulk = [];
   for (j=1:length(list))
      sym = list{j};
      bulk(:,end+1) = data(oo,sym)';
   end
   disp(bulk(1:lines,:));
end