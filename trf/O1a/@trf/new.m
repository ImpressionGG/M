function oo = new(o,varargin)          % Pid1 Plot Method
%
% NEW   New transfer function
%
%           new(o)                     % setup menu
%           new(o,'PT1')               % new PT1 Transfer Function
%           new(o,'PT2')               % new PT2 Transfer Function
%
   [gamma,oo] = manage(o,varargin,@New,@Stuff,@Plant,@Controller,...
                                  @System,@PT1,@PT2);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = New(o)                   % New Menu Items                
   oo = mhead(o,'New');
   ooo = menu(oo,'NewShell');          % add New Shell menu
   ooo = mitem(oo,'Package',{@PackageCb});
   ooo = mitem(oo,'-');
   ooo = Plant(oo);                    % add New/Plant sub menu
   ooo = Controller(oo);               % add New/Controller sub menu
   ooo = System(oo);                   % add New/System sub menu
   ooo = mitem(oo,'-');
   ooo = Stuff(oo);                    % add New/Stuff sub menu
   return

   function oo = PackageCb(o)          % New Package Callback           
      run = 0;                         % init run number
      mach = '';
      for (i=1:length(o.data))
         oo = o.data{i};
         if o.is(get(oo,'kind'),'pkg')
            package = get(oo,{'package','0000.0'});
            idx = findstr('.',package);
            if ~isempty(idx)
               pnum = sscanf(package(idx+1:end),'%f');
               mach = package(2:idx-1);
               run = max(run,pnum);
            end
         end
      end
      
      if ~isempty(mach)
         machine = ['9500',mach];
         run = run + 1;                % run number
         o = set(o,'machine',machine,'run',run);
      end
      
      o = opt(o,'plain',true);         % provide a plain name
      oo = new(o,'Package','pkg');     % new plain package
      
         % paste package object into shell

      if ~isempty(oo)
         oo.tag = o.tag;               % inherit tag from parent
         oo = balance(oo);             % balance object
         paste(o,{oo});                % paste new object into shell
      end
   end
end
function oo = Plant(o)
   oo = plant(o);                      % add New/Plant sub menu
end
function oo = Controller(o)
   oo = controller(o);                 % add New/Controller sub menu
end
function o = Stuff(o)
   oo = mitem(o,'Stuff');
   ooo = shell(oo,'Stuff','weird');
   ooo = shell(oo,'Stuff','ball');
   ooo = shell(oo,'Stuff','cube');
end

%==========================================================================
% System Creation
%==========================================================================

function o = System(o)                 % add New/Systems menu          
   oo = mitem(o,'Systems');
   ooo = mitem(oo,'PT1 System',{@PT1});
   ooo = mitem(oo,'PT2 System',{@PT2});
end
function oo = PT1(o)                   % New PT1 System                 
%
% PT1   Create a system with transfer function 
%                      V
%          G(s) = -----------          % V = 1, T = 5
%                   1 + s*T
%
   [V,T] = get(o,{'V',1},{'T',1});
   oo = trf(V,[T 1]);                  % transfer function
   
   oo = set(oo,'V',V,'T',T);
   oo = set(oo,'edit',{{'Gain V','V'},{'Time Constant T','T'}});

   head = 'PT1(s) = V / (s*T + 1)';
   params = sprintf('V = %g, T = %g',V,T);
   oo = finish(o,oo,'PT1 System',{head,params});
end
function oo = PT2(o)                   % New PT2 System                 
%
% PT2   Create a system with transfer function 
%                            V
%          G(s) = -------------------------    % V = 1, T = 5, D = 0.7 
%                   1 + 2*D*(s*T) + (s*T)^2
%
   [V,T,D] = get(o,{'V',1},{'T',5},{'D',0.7});
   oo = trf(V,{},{[1/T D]});           % transfer function

   oo = set(oo,'V',V,'T',T,'D',D);
   oo = set(oo,'edit',{{'Gain V','V'},{'Time Constant T','T'},...
                       {'Damping D','D'}});
   
   head = 'PT2(s) = V / (s^2*T^2 + 2*D*s*T + 1)';
   params = sprintf('V = %g, T = %g, D = %g',V,T,D);
   oo = finish(o,oo,'PT2 System',{head,params});
end
