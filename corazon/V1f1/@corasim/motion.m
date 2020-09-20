function varargout = motion(o,varargin)                                
%function [tout,tsvajd,out3,vaj] = motion(o,smax,vmax,amax,tj,unit,infotext)
%
% MOTION   Calculate (plot) motion profile comprising jerk, acceleration,
%          velocity and distance over time. Either plot profile or return
%          duration to perform motion.
%
%             motion(o,smax,vmax,amax,tj,unit)
%             motion(o,smax,vmax,amax,tj,unit,text)
%             motion(o,smax,vmax,amax,[tj algo],unit)   % specify algorithm 
%
%          Brew variables
%
%             oo = motion(o,'Brew');
%
%          Plot Overview
%
%             motion(o,'Overview');
%
%          Return time to perform motion:
%
%             t = motion(o,smax,vmax,amax,tj,unit)      
%
%          Return times to reach positions s1 .. sn
%
%             t = motion(o,[s1..sn],vmax,amax,tj,unit)  
%              
%          Performing motion to distance max(s1,..,sn)
%
%             motion(o,NaN,vmax,amax,[tj mode]);        % plot motion map
%   
%          Retrieve internal variables:
%
%             [t,tsvajd,tref] = motion(o,[s1..sn],vmax,amax,tj,unit)   
%
%             motion(o,smax)           % vmax = 1000 mm/s, amax = 1e4 mm/s2
%                                      % tj = 0, unit = 'mm'
%
%          To calculate values of s, v, a and j at time stamps t
%          use the following syntax:
%
%             out = motion(o,{smax,t},vmax,amax,tj,unit)
%
%          where
%             t = out(1,:)             % time vector
%             s = out(2,:)             % distance vector
%             v = out(3,:)             % velocity vector
%             a = out(4,:)             % acceleration vector
%             j = out(5,:)             % jerk vector
%             d = out(6,:)             % dirac vector
%
%          Meaning of arguments:
%             s:          distance                [mm by default]
%             s1, .., sn: intermediate distances  [mm by default]
%             vmax:       maximum velocity        [mm/s or rev/s]
%             amax:       maximum acceleration    [mm/s2 or rev/s2]
%             tj:         S-time (=> jerk time)   [s]
%             algo:       algorithm (0: Datacon, 1: ETEL (default), 2: HUX)
%             unit: text denoting physical unit for position
%             infotext:   overwrite default text
%
%             t:          duration of motion
%             tsvaj:      values of time (t), distance(s), velocity (v), acceleration (a) and jerk (j)
%             tref:       reference duration of motion with s-time = 0
%
%          Examples:
%             motion(o,200,1,10);                     % 200mm, 1000mm/s, 10000mm/s2, S-time=0
%             motion(o,200,1e3,10e3,0.03,'mm');       % 200mm, 1000m/s,  10000mm/s2, S-time=30ms
%             motion(o,180,10*360,100*360,0.05,'°');  % 180°,  10rev/s, 100rev/s2, S-time=50ms
%
%             motion(o,{200,0:0.001:0.2},1e3,10e3,0.03);  % 200mm, 1000m/s,  10000mm/s2, S-time=30ms
%
%          Copyright(c): Bluenetics 2020
%
%          See also: CORASIM, DUTY
%
   [oo,gamma] = Manage(o,varargin,nargout);     % handle input args
   olist = gamma(oo);                  % invoke local handler function
   
   if isobject(olist)
      varargout{1} = olist;
   else
      for (i=1:length(olist))
         varargout{i} = olist{i};
      end
   end
end

%==========================================================================
% Main Motion Function - Handles Everything
%==========================================================================

function olist = Motion(o)             % Classical Motion Work Horse   
%
% MPOTION Motion work horse
%
%            [tout,tsvajd,out3,vaj,o] = Motion(o)
%
   o = CornerStones(o);                % calculate corner stones     
   
      % calculate presignal times
      
   vaj = [];                           % default init
   if ~isempty(var(o,'si'))
      [ti,vaj] = PreSignalTimes(o);
      o = var(o,'ti',ti);
   end
      
      % plot motion profile or return data
      
   if (var(o,'doplot'))
      Plot(o);
      olist = {o};
   else
      %o = var(o,'ti',ti);
      %o = var(o,'si',si);
      [tout,tsvajd,out3] = OutArgs(o); % provide output args

      nout = var(o,'nargout');         % nargout of calling function
      if (nout >= 1)
         olist{1} = tout;
      end
      if (nout >= 2)
         olist{2} = tsvajd;
      end
      if (nout >= 3)
         olist{3} = out3;
      end
      if (nout >= 4)
         olist{4} = vaj;
      end
      if (nout >= 5)
         olist{5} = o;
      end
   end
end
function olist = Trace(o)              % Calculate Motion Trace        
   o = CornerStones(o);                % calculate corner stones     
   bag = var(o);
   T = bag.T;  TT = bag.TT;
   S = bag.S;  SS = bag.SS;
   V = bag.V;  VV = bag.VV;
   A = bag.A;  AA = bag.AA;
   J = bag.J;  JJ = bag.JJ;
   D = bag.D;  DD = bag.DD; 
   
   T = [0 T];   % shift right time vector (to provide 'T(0) = 0')
   J = [0 J];   % shift jerk vector (to provide 'J(0) = 0')
   D = [0 D];   % shift Dirac vector (to provide 'D(0) = 0')
   A = [0 A];   % initialize acceleration vector
   V = [0 V];   % initialize velocity vector
   S = [0 S];   % initialize distance vector

   ti = bag.ti;
   
   t = [];  j = [];  a = [];  v = [];  s = [];
     
   for (i=2:10)  % since we use right shifted vectors, we run i in the range 2:8 instead of 1:7
      idx = find(T(i-1) <= ti & ti < T(i));          
      %tt = T(i-1):[T(i)-T(i-1)]/10:T(i);
      tt = ti(idx);
      if ~isempty(idx)
         jj = 0*tt + J(i);
         aa = [D(i)+A(i-1)] + J(i)*[tt-T(i-1)];
         vv = V(i-1) + [D(i)+A(i-1)]*[tt-T(i-1)] + J(i)/2*[tt-T(i-1)].^2;
         ss = S(i-1) + V(i-1)*[tt-T(i-1)] + [D(i)+A(i-1)]/2*[tt-T(i-1)].^2 + J(i)/6*[tt-T(i-1)].^3;
         
%        subplot(211); hold on
%        plot(tt*1000,vv,'b.');
%        subplot(212); hold on
%        plot(tt*1000,ss,'b.');

         t = [t tt];  j = [j jj];  a = [a aa];  v = [v vv];  s = [s ss];
      end
   end
   
   idx = find(T(i) <= ti & ti < max(ti));
   tt = ti(idx);
   jj = 0*tt;  aa = 0*tt;  vv = 0*tt;  ss = 0*tt + max(s);
   
%  subplot(211); hold on
%  plot(tt*1000,vv,'b.');  set(gca,'xlim',[0 max(tt*1000)]);
%  subplot(212); hold on
%  plot(tt*1000,ss,'b.');  set(gca,'xlim',[0 max(tt*1000)]);
         t = [t tt];  j = [j jj];  a = [a aa];  v = [v vv];  s = [s ss];
   bag.t = t;
   bag.j = j;
   bag.a = a;
   bag.v = v;
   bag.s = s;
   o = var(o,bag);
   olist = {o};
end

%==========================================================================
% Plot
%==========================================================================

function oo = Overview(o)              % Plot Overview
   oo = Brew(o);

   [t,s,v,a,j] = var(oo,'t,s,v,a,j');
   [tunit,sunit] = data(o,'tunit,sunit');
   
   switch sunit
      case 'mm'
         oo = opt(oo,'yscale',1e3,'yunit',sunit);
      case 'um'
         oo = opt(oo,'yscale',1e6,'yunit',sunit);
      otherwise
         oo = opt(oo,'yscale',1e0,'yunit',sunit);
   end
   
   cls(o);
   PlotV(oo,2211);
   PlotS(oo,2221);
   PlotJ(oo,2212);
   PlotA(oo,2222);
   heading(o);
   
   function PlotS(o,sub)
      subplot(o,sub);
      plot(o,t,s,'g');
      title('Stroke');
      xlabel(['time [',o.either(tunit,'1'),']']);
      ylabel(['s [',o.either(sunit,'1'),']']);
      set(gca,'Xlim',[min(t),max(t)]);
      subplot(o);                      % subplot done
   end
   function PlotV(o,sub)
      subplot(o,sub);
      plot(o,t,v,'bc');
      title('Velocity');
      xlabel(['time [',o.either(tunit,'1'),']']);
      ylabel(['s [',o.either(sunit,'1'),'/s]']);
      set(gca,'Xlim',[min(t),max(t)]);
      subplot(o);                      % subplot done
   end
   function PlotA(o,sub)
      subplot(o,sub);
      plot(o,t,a,'r');
      title('Acceleration');
      xlabel(['time [',o.either(tunit,'1'),']']);
      ylabel(['s [',o.either(sunit,'1'),'/s2]']);
      set(gca,'Xlim',[min(t),max(t)]);
      subplot(o);                      % subplot done
   end
   function PlotJ(o,sub)
      subplot(o,sub);
      plot(o,t,j,'yyr');
      title('Jerk');
      xlabel(['time [',o.either(tunit,'1'),']']);
      ylabel(['j [',o.either(sunit,'1'),'/s3]']);
      set(gca,'Xlim',[min(t),max(t)]);
      subplot(o);                      % subplot done
   end
end
function o = Plot(o)                   % Plot Profile                  
   ti = []; vi = []; unit = [];        % local variables
   unit = [];  smax = [];
   
   [t,s,v,T,S,V,TT,SS,VV,si] = var(o,'t,s,v,T,S,V,TT,SS,VV,si');
   [vfac,angle,unit1,unit] = var(o,'vfac,angle,unit1,unit');
   [tref,tadd,tmax] = var(o,'tref,tadd,tmax');
   [smax,vmax,amax] = var(o,'smax,vmax,amax');
   [vm,am,tj,lcolor,algo] = var(o,'vm,am,tj,lcolor,algo');

   refmode = var(o,'refmode');
   if (refmode)
      cls(o);
   end

   Velocity(o,211);                    % plot velocity
   Vlabels(o,211);                     % velocity labels

   Stroke(o,212);                      % plot stroke
   Slabels(o,212);                     % stroke labels

   PreSignals(o,211);                  % plot pre-signals

   function o = Velocity(o,sub)        % Plot Velocity Profile         
      subplot(o,sub);
      hold on;

      for (i=1:length(T))
         plot(o,[T(i) T(i)]*1000,[0 V(i)]*vfac,[lcolor,'K:']);
         hold on
      end
      plot(o,t*1000,v*vfac,lcolor, TT*1000,VV*vfac,[lcolor,'Ko']);
      subplot(o);                      % subplot done
   end
   function o = Stroke(o,sub)          % Plot Stroke Profile           
      subplot(o,sub);
      hold on

      for (i=1:length(T)) 
         plot(o,[T(i) T(i)]*1000,[0 S(i)],[lcolor,':']);
      end
      plot(o,t*1000,s,lcolor, TT*1000,SS,[lcolor,'o']);
      subplot(o);                      % subplot done
   end
   function o = Vlabels(o,sub)         % Velocity Labels               
      subplot(o,sub);
      infotext = var(o,'infotext');
      title(sprintf(['%s: %g ',unit,' / %g ms (%g ms + %g ms)'],infotext,Rd(smax),Rd(tmax*1000),Rd(tref*1000),Rd(tadd*1000)));


      if angle
         xlabel(sprintf(['n_m = %g ',unit1,'/s (%g),   a_m = %g ',...
                         unit1,'/s^2 (%g), t_j = %g ms (%g)'],...
                         Rd(vm/360),Rd(vmax/360),Rd(am/360),...
                         Rd(amax/360),Rd(tj*1000),Rd(tj*1000)));
         ylabel(['n [',unit1,'/s]']);
      else
         xlabel(sprintf(['v_m = %g ',unit,'/s (%g),   a_m = %g ',unit,'/s^2 (%g), t_j = %g ms (%g)'],Rd(vm),Rd(vmax),Rd(am),Rd(amax),Rd(tj*1000),Rd(tj*1000)));
         ylabel(['v [',unit,'/s]']);
      end
      ylim = get(gca,'ylim'); set(gca,'ylim',[0 ylim(2)]);

      hold on
      ta = T(4);  vm = max(V);  tv = max(T)-2*ta;
      plot(o,[ta ta]*1000,[0 vm]*vfac,'K:');
      plot(o,[ta+tv ta+tv]*1000,[0 vm]*vfac,'K:');
      plot([0 ta ta+tv 0]*1000,[0 vm vm 0]*vfac,'Ko');
      set(gca,'xlim',[0 tmax*1000]);
      subplot(o);                      % subplot done
   end
   function o = Slabels(o,sub)         % Stroke Labels                 
      subplot(o,sub);
      if (var(o,'refmode'))
         ta = T(4);  vm = max(V);  tv = max(T)-2*ta;
         plot(o,[ta ta 0]*1000,[0 S(4) S(4)],'K:');
         plot(o,[ta+tv ta+tv 0]*1000,[0 S(5) S(5)],'K:');
         plot(o,[tmax tmax 0]*1000,[0 smax smax],'K:');
         plot(o,[0 ta ta+tv tmax]*1000,[0 S(4) S(5), smax],'Ko');
      end

      if (isempty(si))
         [tduty,acont,dut] = duty(o,smax,vmax,amax,[tj algo],unit,var(o,'infotext'));
         xlabel(sprintf(['T_{duty}= %g ms,   a_{cont}= %g %s/s^2,   duty = %g %%'],Rd(tduty*1000),Rd(acont*vfac),unit1,Rd(dut*100)));
      end

      if angle
         ylabel(['phi [',unit,']']);
      else
         ylabel(['s [',unit,']']);
      end

      set(gca,'xlim',[0 tmax*1000]);
      subplot(o);                      % subplot done
   end
   function o = PreSignals(o,sub)      % Plot Pre-Signals              
      if ~isempty(si)
         subplot(211);
         plot(o,[1;1]*[ti(:)*1000]',[0*vi(:) vi(:)]'*vfac,'r:', [0;1]*[ti(:)*1000]',[vi(:) vi(:)]'*vfac,'r:');
         plot(ti*1000,vi*vfac,'ro');

         subplot(212);
         plot([1;1]*[ti(:)*1000]',[0*si(:) si(:)]','r:', [0;1]*[ti(:)*1000]',[si(:) si(:)]','r:');
         plot(ti*1000,si,'ro');

         nsi = min(length(si),4);
         if (nsi == 1) xlab = 'pre signal: '; else xlab = 'pre signals: '; end 
         for i=1:nsi
            xlab = [xlab,sprintf(['%g',unit,':%g ms'],Rd(si(i)),Rd(ti(i)*1000))];
            if (i<nsi) xlab = [xlab,', ']; end
         end
         xlabel(xlab);         
      end
      subplot(o);                      % subplot done
   end
end

%==========================================================================
% Brew Variables
%==========================================================================

function oo = Brew(o)                  % Brew Variables                
   [smax,vmax,amax,tj,unit] = data(o,'smax,vmax,amax,tj,sunit');
   [tmax,tsvajd,tref,~,o] = motion(o,smax,vmax,amax,tj,unit);   
   
   tmax = opt(o,{'tmax',tmax});
   dt = opt(o,{'dt',tmax/1000});
   
   t = 0:dt:tmax;
   o = Simu(o,t);
   oo = o;
end
function o = CornerStones(o)           % Calculate Corner Stones       
   o = ReferenceTime(o);               % Calculate Reference Time     
   o = Convert(o);                     % convert according to unit
   
      % start calculating 
   
   tj = var(o,'tj');
   algo = var(o,'algo');
   
   if (tj == 0)
      o = ReferenceProfile(o);
   elseif (algo == 0)                  % tj > 0, Datacon algorithm      
      o = DataconProfile(o);           % Datacon motion profile
   elseif (algo == 1)                  % tj > 0, ETEL algorithm      
      o = EtelProfile(o);              % ETEL motion profle
   elseif (algo == 2)                  % tj > 0, modified ETEL algorithm      
      o = HuxProfile(o);               % Hux motion profle
   elseif (algo == 3)                  % tj > 0, ETEL algorithm (alternative code)
      o = AlternativeProfile(o);       % alternative ETEL motion profle
   else
      error(sprintf('Bad argument algo: %g',algo));
   end
   
   o = Finish(o);                      % calc intermediate values
end

%==========================================================================
% Some Work Horse Functions
%==========================================================================

function o = Pack(o,smax,vmax,amax,tj) % Pack Parameters into Vars     
   bag = var(o);                       % get bag of variables
   bag.smax = smax;
   bag.vmax = vmax;
   bag.amax = amax;
   bag.tj = tj;
   o = var(o,bag);                     % pack into variables
end
function [sm,vm,am,tj] = Unpack(o)     % Unpack Parameters from Vars   
   bag = var(o);
   sm = bag.smax;
   vm = bag.vmax;
   am = bag.amax;
   tj = bag.tj;
end
function o = Store(o,T,J,D,tmax)       % Store Motion Core Parameters  
   bag = var(o);                       % fetch variable structure
   bag.tmax = tmax;                    % store tmax
   bag.T = T;                          % store Time vector
   bag.J = J;                          % store Jerk vector
   bag.D = D;                          % store Dirac vector
   o = var(o,bag);                     % restore modified variables
end
function o = Convert(o)                % Convert According to Unit     
   [smax,vmax,amax,tj] = Unpack(o);    % unpack variables
   unit = var(o,'unit');
   
   angle = strcmp(unit,'grd') | strcmp(unit,'deg') | strcmp(unit,'°');
   if (angle)
      vfac = 1/360; 
      unit = 'rev';
      kconv = 1;  % kconv = 360; 
      vmax = vmax*kconv;  % convert from rev/s to °/s
      amax = amax*kconv;  % convert from rev/s2 to °/s2
   else 
      vfac = 1;
      kconv = 1;  % kconv = 1000; 
      vmax = vmax*kconv;   % convert from m/s to mm/s
      amax = amax*kconv;   % convert from m/s2 to mm/s2
   end
   o = Pack(o, smax,vmax,amax,tj);
   o = var(o,'angle',angle);           % flag, indicating angle
   o = var(o,'unit',unit);             % unit
   o = var(o,'vfac',vfac);             % velocity factor
   o = var(o,'kconv',kconv);           % conversion factor
end

function o = ReferenceTime(o)          % Calculate Reference Time      
   refmode = var(o,'refmode');
   doplot = var(o,'doplot');
   
   if ~refmode
      [smax,vmax,amax,tj] = Unpack(o);
      tref = motion(o,smax(length(smax)),vmax,amax,NaN);                   % calculate reference duration
      if (doplot) 
         unit = var(o,'unit');
         motion(o,smax(length(smax)),vmax,amax,NaN,unit);
      end                              % plot reference motion      
      lcolor = 'bc';
   else
      tref = 0;  tj = 0;  lcolor = 'g';
      o = var(o,'tj',tj);
   end
   
   o = var(o,'tref',tref);
   o = var(o,'lcolor',lcolor);
end
function o = Finish(o)                 % Finish Calculations           
   [smax,vmax,amax,tj] = Unpack(o);
   tref = var(o,'tref');
   tmax = var(o,'tmax');
   vmax = var(o,'vmax');
   tadd = tmax-tref;		   % additional time to jerk-less motion profile
   T = var(o,'T');
   J = var(o,'J');
   D = var(o,'D');
   epsi = var(o,'epsi');
   
% symmetric conditions define the rest of the time vector and jerk profile

   T = [T(1:4), tmax-T(4:-1:1), tmax];
   J = [J(1:4), 0, J(4:-1:1)];
   D = [D(1:4), 0, D(4:-1:1)];
   
   for (i=2:9)
      if (abs(T(i)-T(i-1))<epsi) J(i) = 0; end        % clear jerk if no relevant time for it
   end
   
% jerk profile is now defined, so calculate the rest of the motion profile

      % shift right vectors to artificially provide T(0), J(0), A(0), V(0), S(0) bei shifting left

   T = [0 T];   % shift right time vector (to provide 'T(0) = 0')
   J = [0 J];   % shift jerk vector (to provide 'J(0) = 0')
   D = [0 D];   % shift Dirac vector (to provide 'D(0) = 0')
   A = 0*T;     % initialize acceleration vector
   V = 0*T;     % initialize velocity vector
   S = 0*T;     % initialize distance vector
      
   t = [];  j = [];  a = [];  v = [];  s = [];
      
   for (i=2:10)  % since we use right shifted vectors, we run i in the range 2:8 instead of 1:7
      A(i) = [D(i)+A(i-1)] + J(i)*[T(i)-T(i-1)];
      V(i) = V(i-1) + [D(i)+A(i-1)]*[T(i)-T(i-1)] + J(i)/2*[T(i)-T(i-1)]^2;
      S(i) = S(i-1) + V(i-1)*[T(i)-T(i-1)] + [D(i)+A(i-1)]/2*[T(i)-T(i-1)]^2 + J(i)/6*[T(i)-T(i-1)]^3;
         
      tt = T(i-1):[T(i)-T(i-1)]/10:T(i);
      jj = 0*tt + J(i);
      aa = [D(i)+A(i-1)] + J(i)*[tt-T(i-1)];
      vv = V(i-1) + [D(i)+A(i-1)]*[tt-T(i-1)] + J(i)/2*[tt-T(i-1)].^2;
      ss = S(i-1) + V(i-1)*[tt-T(i-1)] + [D(i)+A(i-1)]/2*[tt-T(i-1)].^2 + J(i)/6*[tt-T(i-1)].^3;
         
      t = [t tt];  j = [j jj];  a = [a aa];  v = [v vv];  s = [s ss];
   end
      
% save in variables TT, JJ, AA, VV, SS and reduce T(0), J(0), A(0), V(0), S(0) bei shifting left

   TT = T;  DD = D;  JJ = J;  AA = A;  VV = V;  SS = S;
   T(1) = [];  D(1) = [];  J(1) = [];  A(1) = [];  V(1) = [];  S(1) = [];
      
   vm = max(V);  am = max(A);  tm = max(T);
      
   if (any(A>amax+epsi)) fprintf('invariant violation am  = %g > amax (smax: %g, vmax: %g, amax: %g, tj: %g)\n',max(A),max(smax),vmax,amax,tj); end
   if (any(V>vmax+epsi)) fprintf('invariant violation vm  = %g > vmax (smax: %g, vmax: %g, amax: %g, tj: %g)\n',max(V),max(smax),vmax,amax,tj); end
   if (any(S>max(smax)+epsi)) fprintf('invariant violation sm  = %g > smax (smax: %g, vmax: %g, amax: %g, tj: %g)\n',max(S),max(smax),vmax,amax,tj); end
      
   bag = var(o);
   bag.T = T;  bag.TT = TT;  bag.t = t;
   bag.S = S;  bag.SS = SS;  bag.s = s;
   bag.V = V;  bag.VV = VV;  bag.v = v;
   bag.A = A;  bag.AA = AA;
   bag.J = J;  bag.JJ = JJ;
   bag.D = D;  bag.DD = DD; 
   o = var(o,bag);
end
function o = Simu(o,t)                 % Finish Calculations           
   [smax,vmax,amax,tj] = Unpack(o);
   tref = var(o,'tref');
   tmax = var(o,'tmax');
   vmax = var(o,'vmax');
   tadd = tmax-tref;		   % additional time to jerk-less motion profile
   T = var(o,'T');
   J = var(o,'J');
   D = var(o,'D');
   epsi = var(o,'epsi');
   
% symmetric conditions define the rest of the time vector and jerk profile

   T = [T(1:4), tmax-T(4:-1:1), tmax];
   J = [J(1:4), 0, J(4:-1:1)];
   D = [D(1:4), 0, D(4:-1:1)];
   
   for (i=2:9)
      if (abs(T(i)-T(i-1))<epsi) J(i) = 0; end        % clear jerk if no relevant time for it
   end
   
% jerk profile is now defined, so calculate the rest of the motion profile

      % shift right vectors to artificially provide T(0), J(0), A(0), V(0), S(0) bei shifting left

   T = [0 T];   % shift right time vector (to provide 'T(0) = 0')
   J = [0 J];   % shift jerk vector (to provide 'J(0) = 0')
   D = [0 D];   % shift Dirac vector (to provide 'D(0) = 0')
   A = 0*T;     % initialize acceleration vector
   V = 0*T;     % initialize velocity vector
   S = 0*T;     % initialize distance vector
      
   j = [];  a = [];  v = [];  s = [];
      
   for (i=2:10)  % since we use right shifted vectors, we run i in the range 2:8 instead of 1:7
      A(i) = [D(i)+A(i-1)] + J(i)*[T(i)-T(i-1)];
      V(i) = V(i-1) + [D(i)+A(i-1)]*[T(i)-T(i-1)] + J(i)/2*[T(i)-T(i-1)]^2;
      S(i) = S(i-1) + V(i-1)*[T(i)-T(i-1)] + [D(i)+A(i-1)]/2*[T(i)-T(i-1)]^2 + J(i)/6*[T(i)-T(i-1)]^3;
         
      %tt = T(i-1):[T(i)-T(i-1)]/10:T(i);
      
      if (i < 10)
         idx = find(t >= T(i-1) & t < T(i));
      else
         idx = find(t >= T(i-1) & t <= T(i));
      end
      
      tt = t(idx);
      
      if ~isempty(tt)
         jj = 0*tt + J(i);
         aa = [D(i)+A(i-1)] + J(i)*[tt-T(i-1)];
         vv = V(i-1) + [D(i)+A(i-1)]*[tt-T(i-1)] + J(i)/2*[tt-T(i-1)].^2;
         ss = S(i-1) + V(i-1)*[tt-T(i-1)] + [D(i)+A(i-1)]/2*[tt-T(i-1)].^2 + J(i)/6*[tt-T(i-1)].^3;
         
         j = [j jj];  a = [a aa];  v = [v vv];  s = [s ss];
      end
   end
   
   if (length(t) > length(a))
      one = 1+0*(length(a)+1:length(t));
      j = [0*one];
      a = [a,a(end)*one];
      v = [v,v(end)*one];
      s = [s,s(end)*one];
   end
      
% save in variables TT, JJ, AA, VV, SS and reduce T(0), J(0), A(0), V(0), S(0) bei shifting left

   TT = T;  DD = D;  JJ = J;  AA = A;  VV = V;  SS = S;
   T(1) = [];  D(1) = [];  J(1) = [];  A(1) = [];  V(1) = [];  S(1) = [];
      
   vm = max(V);  am = max(A);  tm = max(T);
      
   if (any(A>amax+epsi)) fprintf('invariant violation am  = %g > amax (smax: %g, vmax: %g, amax: %g, tj: %g)\n',max(A),max(smax),vmax,amax,tj); end
   if (any(V>vmax+epsi)) fprintf('invariant violation vm  = %g > vmax (smax: %g, vmax: %g, amax: %g, tj: %g)\n',max(V),max(smax),vmax,amax,tj); end
   if (any(S>max(smax)+epsi)) fprintf('invariant violation sm  = %g > smax (smax: %g, vmax: %g, amax: %g, tj: %g)\n',max(S),max(smax),vmax,amax,tj); end
      
   o = var(o,'T,TT,t,S,SS,s',T,TT,t,S,SS,s);
   o = var(o,'V,VV,v,A,AA,a',V,VV,v,A,AA,a);
   o = var(o,'J,JJ,j,D,DD',J,JJ,j,D,DD);   
end
function [ti,vaj] = PreSignalTimes(o)  % Calculate Pre-Signal Times    
   bag = var(o);
   TT = bag.TT;  SS = bag.SS;  VV = bag.VV;  AA = bag.AA;
   T = bag.T;  S = bag.S;  J = bag.J;
   si = bag.si;
   epsi = bag.epsi;
   tmax = bag.tmax;
   
   ti = zeros(size(si));
   vi = zeros(size(si));
   ai = zeros(size(si));
   ji = zeros(size(si));

      % note: TT(k) = T(k-1), JJ(k) = J(k-1), AA(k) = A(k-1), VV(k) = V(k-1), SS(k) = S(k-1)

   for (k=1:9)
      idx = find(SS(k) <= si & si < S(k));
      if ~isempty(idx)
         ji(idx) = J(k) * ones(size(idx));
         for (i=1:length(idx))
            ti(idx(i)) = TT(k) + CubeSolve([J(k)/6,AA(k)/2,VV(k),SS(k)-si(idx(i))],[TT(k)-epsi T(k)+epsi]-TT(k));
         end
         vi(idx) = VV(k) + AA(k)*(ti(idx)-TT(k)) + J(k)/2*(ti(idx)-TT(k)).^2;
         ai(idx) = AA(k) + J(k)*(ti(idx)-TT(k));
      end         
   end
   ti(length(ti)) = tmax;
   vaj = [vi;ai;ji];
end

function [o,gamma] = Manage(o,inargs,nout)  % Handle Input Args        
   if isequal(inargs,{'Brew'})
      gamma = @Brew;
      return
   elseif isequal(inargs,{'Overview'})
      gamma = @Overview;
      return
   end
   
   if length(inargs) == 1 && iscell(inargs{1})
      nin = 1;  smax = inargs{1};
   else
      [nin,smax,vmax,amax,tj,unit,infotext] = o.args(inargs);
   end
   Nargin = 1 + nin;
   
   o = var(o,'nargout',nout);
   doplot = (nout == 0);

   gamma = @Motion;                    % the default handling function
   algo = opt(o,{'algo',1});           % ETEL algorithm by default
   epsi = 1e6*eps;                     % numerical epsilon for this script
   si = [];                            % init presignal distance
   ti = [];                            % init time vector

   if (Nargin == 2) && isequal(smax,inf)
      MotionTest(o);
      o = [];
      return;
   end

   if (Nargin < 2) 
      smax = opt(o,{'smax',100});
   end

   if iscell(smax)
      if length(smax) ~= 2
         error('arg2 must be a 2-element list!');
      end
      ti = smax{2};  smax = smax{1};
      gamma = @Trace;                  % calculate trace
   end

   if (length(smax) > 1) 
      if (min(size(smax)) ~= 1)
         error('arg1 must be a scalar or vector!');
      end
      si = smax;
      smax = max(si(:));
   end


   if (Nargin < 3)
      vmax = opt(o,{'vmax',1000});
   end
   if (Nargin < 4) 
      amax = opt(o,{'amax',10000});
   end

   if (Nargin < 5) 
      tj = opt(o,{'tj',0});
   end
   if (length(tj) > 1)
      algo = tj(2); tj = tj(1);
   end

   if (Nargin < 6)
      unit = opt(o,{'unit','mm'});;
   end
   if (Nargin < 7)
      infotext = sprintf('Motion profile (Algo %g)',algo); 
      infotext = opt(o,{'info',infotext});
   end

   refmode = isnan(tj);

   if (isempty(smax) || iscell(smax))
      fprintf('*** motion(o,[],...) or motion(o,{},...) no more supported!');
      fprintf('*** use motion(o,NaN,...) instead!');
      smax = NaN;
   end
   if isnan(smax)
      %if (iscell(smax)) smax = smax{1}; end
      %MotionMap(o,smax,vmax,amax,tj,algo,unit,infotext);
      %o = [];                          % indicate a termination of caller
      gamma = @MotionMap;
   end

   o = Pack(o,smax,vmax,amax,tj);      % pack into variables
   o = var(o,'refmode',refmode);
   o = var(o,'doplot',doplot);
   o = var(o,'infotext',infotext);
   o = var(o,'unit',unit);
   o = var(o,'epsi',epsi);
   o = var(o,'si',si);
   o = var(o,'ti',ti);
   o = var(o,'algo',algo);
end
function [t,tsvajd,tref] = OutArgs(o)  % Provide Output Args           
   bag = var(o);
   
   if (isempty(bag.si))
      t = bag.T(9);
   else
      t = bag.ti;
   end
   
   tsvajd = [ [0 bag.T(:)']
              [0 bag.S(:)']
              [0 bag.V(:)'] / bag.kconv
              [0 bag.A(:)'] / bag.kconv
              [0 bag.J(:)'] / bag.kconv
              [0 bag.D(:)'] / bag.kconv
            ]';
         
   tref = bag.tref;    
end

%==========================================================================
% Profiles
%==========================================================================

function o = ReferenceProfile(o)       % Calculate Reference Profile   
   [smax,vmax,amax,tj] = Unpack(o);    % unpack key parameters
   tc = vmax/amax;                     % characteristic time constant
   sv0 = vmax*tc;                      % characteristic distance regarding velocity mode 
   sm0 = sv0;  sa0 = sv0;              % characteristic distance regarding mixed & acceleration mode 

   tj = 0; tn = 0;  th = 0;            % jerk time
   am = amax;                          % actual maximum acceleration

   if (smax >= sv0)                    % velocity mode? (trapezoidal)
      tp = tc;                         % peak time
      sv = smax - am*tp^2;             % distance of constant velocity
      tv = sv/vmax;                    % velocity time
      vm = vmax;
   else
      tp = sqrt(smax/amax);            % peak time
      tv = 0;                          % velocity time
      vm = am*tp;                      % actual maximum velocity
   end
   tmax = 2*(tj+tp+tn+th) + tv;        % total duration of motion

   T = [tj, tj+tp, tj+tp+tn, tj+tp+tn+th];  % time vector
   J = [0, 0, 0, 0];                   % jerk vector
   D = [1, 0,-1, 0]*amax;              % dirac vector

   o = Store(o,T,J,D,tmax);            % store motion core parameters
end
function o = DataconProfile(o)         % Datacon Motion Profile        
   [smax,vmax,amax,tj] = Unpack(o);    % unpack key parameters

   tj = min(tj,sqrt(vmax/amax*tj));    % actual jerk time regarding velocity limit (except jerk mode!)
   am = amax*tj/tj;                    % actual maximum acceleration

   sa0 = 2*am*tj^2;                    % characteristic distance regarding acceleration mode 
   sv0 = vmax*(vmax/am+tj);            % characteristic distance regarding velocity mode 

   j0 = amax/tj;                       % maximum positive jerk
   tc = vmax/amax;                     % characteristic time constant

   tp = max(vmax/am-tj,0);             % peak time
   tv = 0;  th = 0;                    % velocity time by default and time of high jerk

   if (smax >= sv0)                    % velocity mode? (trapezoidal)
      tn = tj;                         % normal jerk time
      sv = smax - sv0;                 % distance of constant velocity
      tv = sv/vmax;
   elseif (smax >= sa0)                % acceleration mode? (tetragonal)
      tn = tj;                         % time of normal jerk
      vm = sqrt((am*tj/2)^2+am*smax) - am*tj/2;   % max velocity
      tp = vm/am - tj; 		            % peak time
   else                                % jerk mode? (trigonal)
      tj = (smax/2/amax*tj)^(1/3);     % distance limiting jerk time
      tp = 0;  tn = tj;                % peak time and normal jerk time are zero
   end
   tmax = 2*(tj+tp+tn+th) + tv;        % total duration of motion

   T = [tj, tj+tp, tj+tp+tn, tj+tp+tn+th];    % time vector
   J = [1, 0,  -1, 0]*j0;              % jerk vector
   D = [0, 0, 0, 0];                   % Dirac vector         

   o = Store(o,T,J,D,tmax);            % store motion core parameters
end
function o = EtelProfile(o)            % Etel Motion Profile           
   [smax,vmax,amax,tj] = Unpack(o);    % unpack key parameters

   tc = vmax/amax;                        % characteristic time constant
   sc = vmax*tc;                          % characteristic distance
   j0 = amax/tj;                          % maximum positive jerk

   tb = sqrt(smax/amax);                  % acceleration time for reference motion 
   tx = (smax/vmax-tc-tj)/2;              % auxillary time 1

   if (smax >= sc)                        % high distance?
      tj = min(tj,tc);                    % jerk time for high distances
      am = j0*tj;                         % actual maximum acceleration
      tv = 2*max([tx,-tx-tc,0]);          % time of constant velocity
      tp = Sel(vmax/am-tj,vmax/am+2*tx);  % peak time        
      th = Sel(-tx,tx+tc);                % time of high jerk
      tn = tj-2*th;                       % time of normal jerk
   else                                   % low distance?
      tp = Sel(tb-tj);                    % peak time
      tj = tb-tp;                         % jerk time
      th = Sel(tb-tj/2,tj/2);             % time of high jerk
      tv = Sel(tj-2*tb);                  % time of constant velocity
      tn = tj/2-th-tv/2;                  % time of normal jerk
   end
   tmax = 2*(tj+tp+tn+th) + tv;           % total duration of motion

   T = [tj, tj+tp, tj+tp+tn, tj+tp+tn+th];% time vector
   J = [1, 0,  -1, -2]*j0;                % jerk vector
   D = [0, 0, 0, 0];                      % Dirac vector         

   o = Store(o,T,J,D,tmax);            % store motion core parameters
end
function o = HuxProfile(o)             % Hux Motion Profile            
   [smax,vmax,amax,tj] = Unpack(o);    % unpack key parameters

   tj = min(tj,sqrt(vmax/amax*tj));    % actual jerk time regarding velocity limit (except jerk mode!)
   am = amax*tj/tj;                    % actual maximum acceleration

   sv0 = vmax*(vmax/am+tj);            % characteristic distance regarding velocity mode 
   sa0 = amax*tj^2;                    % characteristic distance regarding acceleration mode 
   sx0 = CubeSolve([1,-3*sv0,3*sv0^2+vmax^3/amax*tj,-sv0^3],[0 sv0]);      
   sp0 = vmax^2/amax; 
   sm0 = max(sx0,sp0);                 % characteristic distance regarding mixed mode 

   j0 = amax/tj;                       % maximum positive jerk
   tc = vmax/amax;                     % characteristic time constant

   tp = max(vmax/am-tj,0);             % peak time
   tv = 0;                             % velocity time by default
   th = 0;                             % high jerk time

   if (smax >= sv0)                    % velocity mode? (trapezoidal)
      tn = tj;                         % normal jerk time
      sv = smax - sv0;                 % distance of constant velocity
      tv = sv/vmax;
   elseif (smax >= sm0)                % mixed mode? (pentagonal)
      tn = tj*(smax-sm0)/(sv0-sm0);    % time of normal jerk
      th = (tj-tn)/2;                  % time of high jerk     
   elseif (smax >= sa0)                % acceleration mode? (tetragonal)
      tn = 0;  th = tj/2;              % time of normal and high jerk
      v0 = -am*tj/4 + am*sqrt(smax/am);% reference velocity
      tp = v0/amax - 3/4*tj;           % peak time
   else                                % jerk mode? (trigonal)
      tj = (smax/amax*tj)^(1/3);       % distance limiting jerk time
      tp = 0;  tn = 0;  th = tj/2;     % peak time and normal jerk time are zero, high jerk is active
   end
   tmax = 2*(tj+tp+tn+th) + tv;        % total duration of motion

   T = [tj, tj+tp, tj+tp+tn, tj+tp+tn+th]; % time vector
   J = [1, 0,  -1, -2]*j0;             % jerk vector
   D = [0, 0, 0, 0];                   % Dirac vector         

   o = Store(o,T,J,D,tmax);            % store motion core parameters
end
function o = AlternativeProfile(o)     % Alternative ETEL Profile      
   [smax,vmax,amax,tj] = Unpack(o);    % unpack key parameters

   tc = vmax/amax;                     % characteristic time constant
   sc = vmax*tc;                       % characteristic distance
   j0 = amax/tj;                       % maximum positive jerk

   tb = sqrt(smax/amax);               % jerk time for low distances 
   tj = min(tj,tc);                    % jerk time for high distances
   am = j0*tj;                         % actual maximum acceleration

   sv0 = vmax*(tc+tj);                 % characteristic distance regarding velocity mode 
   sa0 = amax*tj^2;                    % characteristic distance regarding acceleration mode 
   sm0=max(sc,sv0-vmax*tj);            % characteristic distance regarding mixed mode 

   tf = (smax - sv0)/vmax/2;           % fictive time
   tp = vmax/am-tj;                    % peak time
   tv = 0;                             % velocity time by default
   th = 0;                             % high jerk time

   if (smax >= sv0)                    % velocity mode? (trapezoidal)
      tv = 2*tf;
      tn = tj;     
   elseif (smax >= sm0)                % mixed mode? (pentagonal)
      th = max(0,-tf);
      tn = tj - 2*th;
   elseif (smax >= sa0)                % acceleration mode? (tetragonal)
      tn = 0; th = tj/2;               % time of normal and high jerk
      tp = tb-tj;                      % peak time
   elseif (smax >= sc)                 % low velocity mode? (tetragonal)
      tp = (smax-sc)/vmax;             % peak time
      tv = tj - 2*tc - (smax-sc)/vmax;
      th = max(0,-tv/2);               % time of high jerk
      tn = tj-2*th;                    % time of normal jerk
      tv = max(0,tv);
   else                                % jerk mode? (trigonal)
      tj = tb;                         % jerk time
      tp = 0; 
      th = max(tb-tj/2,0);             % time of high jerk
      tv = max(tj-2*tb,0);             % time of constant velocity
      tn = tj/2 - th - tv/2;
   end
   tmax = 2*(tj+tp+tn+th) + tv;        % total duration of motion

   T = [tj, tj+tp, tj+tp+tn, tj+tp+tn+th];% time vector
   J = [1, 0,  -1, -2]*j0;             % jerk vector
   D = [0, 0, 0, 0];                   % Dirac vector         

   o = Store(o,T,J,D,tmax);            % store motion core parameters
end

%==========================================================================
% Helper
%==========================================================================

function y = Rd(x)                     % Round To One Digit After Comma
   y = round(10*x)/10;
end
function y = Sel(x1,x2,x3)             % Select Minimum Positive Number
   if (nargin < 2) x2 = inf; end
   if (nargin < 3) x3 = inf; end
   y = max(0,min([x1 x2 x3]));
end
function x = CubeSolve(c,limits)       % Solve Cubic Equation          
%
% CUBESOLVE solve cubic equation by interval half method
%
%           c(1)*x^3 + c(2)*x^2 + c(3)*x + c(4) = 0
%
   if (nargin < 2) limits = [-10000 10000]; end
   
   X = limits;   % short hand form
   Y = c(1)*X.^3 + c(2)*X.^2 + c(3)*X + c(4);
   
   n = 50;           % 50 iterations
   for (i=1:n)
      if (all(Y>0) | all(Y<0))
         error(sprintf('problem solving cubic equation: Y=[%g %g] for X=[%g %g]',Y(1),Y(2),X(1),X(2)));
      end
      
      if (Y(1) > Y(2)) Y = Y([2 1]);  X = X([2 1]); end  
      
      x = mean(X);
      y = c(1)*x^3 + c(2)*x^2 + c(3)*x + c(4);
      
      %fprintf('x: [%g %g] %g;  y: [%g %g] %g\n',X(1),X(2),x,Y(1),Y(2),y);
      
      if (y == 0)
         break;
      elseif (y < 0)
         X(1) = x;  Y(1) = y;
      else
         X(2) = x;  Y(2) = y;
      end
   end
end      
function olist = MotionMap(o,smax,vmax,amax,tj,algo,unit,infotext)     
%
% MOTIONMAP   Plot motion map
%
   if (nargin < 2)
      smax = var(o,'smax');
   end
   if (nargin < 3)
      vmax = var(o,'vmax');
   end
   if (nargin < 4)
      amax = var(o,'amax');
   end
   if (nargin < 5)
      tj = var(o,'tj');
   end
   if (nargin < 6)
      algo = var(o,'algo');
   end
   if (nargin < 7)
      unit = var(o,'unit');
   end
   if (nargin < 8)
      infotext = var(o,'infotext');
   end
   
   tc = vmax/amax;                        % Characteristic time constant
   sc = vmax*tc;                          % characteristic distance
   
   tjv = sqrt(vmax/amax*tj);              % velocity limiting jerk time 
   tj = min([tj,tjv]);                    % actual jerk time
   
   sm0 = 0;  sx0 = 0;  sp0 = 0;  sa0 = 0;  sl0 = 0;
   
   if (tj == 0)
      sv0 = vmax^2/amax;                  % characteristic distance regarding velocity mode 
   elseif (algo == 0)
      sv0 = vmax*(vmax/amax*tj/tj+tj);    % characteristic distance regarding velocity mode 
      sa0 = 2*amax*tj^3/tj;               % characteristic distance regarding acceleration mode 
   elseif (algo == 1 | algo == 3)
      tjv = (tc+tj)/2 - sqrt((tc+tj)^2/4-vmax*tj/amax); 
      tj = min([tj,tjv]);                % actual jerk time regarding velocity limit (except jerk mode!)
      %sv0 = vmax*(vmax/amax*tj/tj+tj);   % characteristic distance regarding velocity mode 
      sv0 = vmax*(vmax/amax+tj);          % characteristic distance regarding velocity mode 
      sa0 = amax*tj^2;                    % characteristic distance regarding acceleration mode 
      %sx0 = CubeSolve([1,-3*sv0,3*sv0^2+vmax^3/amax*tj,-sv0^3],[0 sv0]);      
      %sp0 = vmax^2/amax; 
sp0 = sv0-vmax*tj;      
sz0 = sv0-vmax*tj;
      sm0 = max([sx0,sp0,sz0]);                 % characteristic distance regarding mixed mode 
      sl0 = amax*tj^2/4;                  % characteristic distance regarding low velocity mode
   elseif (algo == 2)
      sv0 = vmax*(vmax/amax*tj/tj+tj);   % characteristic distance regarding velocity mode 
      sa0 = amax*tj^2;                    % characteristic distance regarding acceleration mode 
      sx0 = CubeSolve([1,-3*sv0,3*sv0^2+vmax^3/amax*tj,-sv0^3],[0 sv0]);      
      sp0 = vmax^2/amax; 
      sm0 = max(sx0,sp0);                 % characteristic distance regarding mixed mode 
      sl0 = amax*tj^2/4;                  % characteristic distance regarding low velocity mode
   else
      error(sprintf('bad algo: %g',algo));
   end
   
   s0 = 1.5*max([sv0,sm0]);
   
   p = 100;
   s = s0 * (1:p).^2/p^2;
   
   for (i=1:length(s))
      [tmax,tsvaj,Tref] = motion(o,s(i),vmax,amax,[tj algo],unit,infotext);
         
      t = tsvaj(:,1);
      tref(i) = Tref;
      T(:,i) = t;
   end
   
   [m,n] = size(T);
   Tnorm = T-ones(m,1)*max(T)/2;
   tmax = T(m,:);
   
   idx = [1 10, 2 9, 3 8, 4 7, 5 6];
   colors = {'m','m', 'g','g','y','y' , 'r','r',  'b','b'};
   
   cls(o);
   axes;
   %corasim.motmenu({smax,vmax,amax,[tj algo],unit,infotext},'motion map');  % add motion menus
   
   for (i=1:length(idx))
      patch([0 s max(s)],[0 Tnorm(idx(i),:)*1000, 0],colors{i});
      hold on; % shg; pause;
   end
   
   plot(s,tj*1000,'k');             % plot line to sketch s-time as nominal extra time
   plot(s,(tmax-tref)*1000,'b');    % plot actual extra time
   plot(s,-(tref+tj)/2*1000,'b');   % plot actual extra time
   
   xlim = get(gca,'xlim');  ylim = get(gca,'ylim');
   
   %if (0 < sx0 & sx0 <= max(xlim)) plot([sx0 sx0],ylim,'k:'); end
   if (0 < sp0 & sp0 <= max(xlim)) plot([sp0 sp0],ylim,'g:'); end
   
   if (0 < sv0 & sv0 <= max(xlim)) plot([sv0 sv0],ylim,'b-'); end
   if (0 < sa0 & sa0 <= max(xlim)) plot([sa0 sa0],ylim,'r-'); end
   if (0 < sm0 & sm0 <= max(xlim)) plot([sm0 sm0],ylim,'g-'); end
   if (0 < sl0 & sl0 <= max(xlim)) plot([sl0 sl0],ylim,'m-'); end
   if (0 < sc  & sc  <= max(xlim)) plot([sc  sc], ylim,'k-'); end
   

   
   if (tj > 0 & algo == 1)
      t0 = min(tj/2,1/2*(s0/amax*tj)^(1/3));
      t = -t0:t0/50:t0;
      plot(abs(8*amax/tj*t.^3),t*1000,'k');
      plot([0,s0],tj/2*1000*[1 1],'k:',[0,s0],-tj/2*1000*[1 1],'k:');
   end
   
   critical = sprintf('  Characteristics: t_c=%g ms, s_c = %g, s_{l0}=%g, s_{a0}=%g, s_{m0}=%g, s_{v0}=%g',Rd(tc*1000),Rd(sc),Rd(sl0),Rd(sa0),Rd(sm0),Rd(sv0));
   
   title(sprintf('Motion Map (Algo %g):    v_{max}= %g %s/s, a_{max}= %g %s/s2, t_s= %g ms',algo,Rd(vmax),unit,Rd(amax),unit,Rd(tj*1000)));
   xlabel(sprintf('distance [%s] %s',unit,critical));
   ylabel(sprintf('motion time [ms] (symmetric plot)',unit));
   olist = {s,T};
end   
function MotionTest(o)                 % Test Emotion Method           
%
% MOTIONTEST test motion function; plot characteristic motion maps
%
   motion(o,[],1000,10000,0.03); text(10,150,'s_{a0} <= s_{x0} <= s_{m0} <= s_{v0}'); pause;
   motion(o,[],400,10000,0.03);  text(5,80,'s_{a0} <= s_{x0} <= s_{m0} <= s_{v0}'); pause;
   motion(o,[],300,10000,0.03);  text(2,60,'s_{m0} = s_{x0} = s_{a0} <= s_{v0}'); pause;
   motion(o,[],250,10000,0.03);  text(2,60,'s_{m0} <= s_{x0} <= s_{a0} <= s_{v0}'); pause;
   motion(o,[],100,10000,0.03);  text(5,80,'s_{m0} <= s_{x0} <= s_{v0} <= s_{a0}'); pause;
end
