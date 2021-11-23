function y = rsp(o,u,t)
%
% RSP    Input output response of a system
%
%        1) Continuous system
%
%           Gs = trf(o,1,[1,1])
%           t = 0:0.005:5;  
%           u = [ones(1,300),zeros(1,200),ones(1,100),zeros(1,length(t)-600]
%           y = rsp(Gs,u,t);
%
%        2) discrete system
%
%           Hz = trf(o,[1 -1],[1 0.99],0.005)
%           u = [ones(1,300),zeros(1,200),ones(1,100),zeros(1,length(t)-600]
%           y = rsp(Hz,u);
%
%        Options:
%           in:     input index  (default 1)
%           out:    output index (default 1)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORASIM
%
   switch o.type
      case {'css'}
         oo = o;
      case {'dss','ztrf'}
         error('implementation');
      case 'strf'
         oo = system(o);
      otherwise
         error('implementation');
   end
   
   in = opt(o,{'in',1});
   out = opt(o,{'out',1});

   if isequal(oo.type,'css')
      T = mean(diff(t));
      oo = c2d(oo,T);   
      oo = sim(oo,u,[],t);
   else
      oo = sim(oo,u,[]);
   end

   y = data(oo,'y');
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
   A = get(o,'system.A');
   ev = eig(A);
   tmax = 5*max(1./abs(ev));

   T = opt(o,{'simu.dt',tmax/1000});
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
