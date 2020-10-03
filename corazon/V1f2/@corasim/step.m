function out = step(o)
%
% STEP   Plot step response
%
%           G = trf(o,1,[1,1])
%           step(G);
%
%        Options:
%           in:     input index  (default 1)
%           out:    output index (default 1)
%           tmax:   maximum simulation time (default: [] - auto)
%           dt:     simulation increment (default: [] - auto)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORASIM
%
   o = Inherit(o);                     % inherit options from shell
   
   switch o.type
      case {'css'}
         oo = o;
      case {'dss','ztrf'}
         error('implementation');
      case 'strf'
         oo = system(o);
      case 'modal'
         oo = system(o);
      otherwise
         error('implementation');
   end
   
   in = opt(oo,{'in',1});
   out = opt(oo,{'out',1});

   t = Time(oo);
   u = StepInput(oo,t,in);

   if (isempty(u))
      oo = var(oo,'u,x,y,t',[],[],[],[]);
   else
      oo = sim(oo,u,[],t);
   end
   
   if (nargout == 0)
      %plot(oo);
      [t,y] = var(oo,'t,y');
      if ~isempty(t)
         col = opt(o,{'color','r'});
         plot(oo,t,y,col);
      end
      
      name = get(o,'name');
      if ~isempty(name)
         title([name,' - Step Response']);
      else
         title('Step Response');
      end
      
      [xunit,yunit] = opt(o,'xunit,yunit');
      if ~isempty(xunit)
         xlabel(['[',xunit,']']);
      end
      if ~isempty(yunit)
         ylabel(['[',yunit,']']);
      end
      
      dark(o);
   else
      out = oo;
   end
end

%==========================================================================
% Helper
%==========================================================================

function title = Title(o)              % Get Object Title              
   title = get(o,{'title',[class(o),' object']});
   return
   
   dir = get(o,'dir');   
   idx = strfind(dir,'@');
   if ~isempty(dir)
      [package,typ,name] = split(o,dir(idx(1):end));
      title = [title,' - [',package,']'];
   end
end
function t = Time(o)                   % Get Time Vector     
   o = Timing(o);
   [tmax,dt] = opt(o,'tmax,dt');
   t = 0:dt:tmax;
end
function t = OldTime(o)                   % Get Time Vector               
   A = get(o,'system.A');   
   ev = eig(A);
   tmax = 5*max(1./abs(ev));

   T = opt(o,{'simu.dt',tmax/1000});
   T = T(1);
   tmax = opt(o,{'simu.tmax',tmax});
   t = 0:T:tmax;
end
function u = StepInput(o,t,index)      % Get Step Input Vector         
%
% STEPINPUT   Get step input vector (and optional time vector)
%
%                u = StepInput(o,t,index)
%
   [~,m] = size(o);                   % number of inputs
   if (m == 0)
      u = [];
      return
   end
   
   if (index > m)
      title = sprintf('Output #%g not supported!',index);
      comment = {sprintf('number of outputs: %g',m)};
      message(o,title,comment);
      error(title);
      return
   end
   
   I = eye(m);
   u = I(:,index)*ones(size(t));
end
function o = Inherit(o)                % inherit options from shell    
   if isempty(figure(o))
      so = pull(o);
      if ~isempty(so)
         o = inherit(o,so);
         o = with(o,'simu');
         o = with(o,'scale');
      end
   end
end
function oo = Timing(o)
%
% TIMING   Set timing options
%
%             oo = Timing(o)
%             [tmax,dt] = opt(o,'tmax,dt')
%
   tmax = opt(o,'tmax');
   dt = opt(o,'dt');
   
   if isempty(tmax) 
      poles = roots(den(o));
      zeros = roots(num(o));

      [mag,idx] = sort(abs(poles));
      T = 1/min(mag);
      tmax = 10*T;
      
      if isempty(dt)
         dt = tmax / 1000;
      end
   end
   
   oo = opt(o,{'tmax'},tmax);
   oo = opt(oo,{'dt'},dt);
end
