function oo = brew(o,varargin)         % Brew Data                     
%
% BREW    Brew data and store results in cache
%
%            oo = brew(o,'Brew')       % brew all to be brewed
%            oo = brew(o)              % same as above
%
%         Remark: brew(o,'Brew') will skipped if brew cache is up-to-date
%
%         Specific brewing for CUL-typed objects:
%
%            oo = brew(o,'Basis')      % fetch raw data and brew basis data
%            oo = brew(o,'Cluster');   % calculate cluster indices & time
%            oo = brew(o,'Rotate')     % calculate 'rotated'  data
% 
%         Specific brewing for PKG-typed objects:
%
%            oo = brew(o,'Spec')       % Spec specifics
%            oo = brew(o,'Package')    % condensed package data
%
   if container(o)
      error('brewing not supported for container objects!');
   end
   
   [gamma,oo] = manage(o,varargin,@Brew,@Raw,@Rotate,@Cluster,...
                                  @Package,@Spec);
   oo = gamma(oo);
end

%==========================================================================
% Brew All
%==========================================================================

function oo = Brew(o)                  % Brew All (If Not Yet Done)    
   bag = cache(o,{'brew'});            % is brew cache segment up-to-date
   if isempty(bag)                     % if brew segment not up-to-date
      Message(o,'Brewing data ...');
      pause(0.1);
      
      oo = Basis(o);                   % provide cache basis data
      oo = Cluster(oo);                % estimate cluster indices and time
      oo = Rotate(oo);
   else
      oo = o;                          % cache already brewed
   end
end

%==========================================================================
% Provide Cache Basis Data (Acceleration/Velocity/Elongation)
%==========================================================================

function oo = Basis(o)                 % Provide Cache Basis Data      
   %if ~isempty(data(o,'s_x'))       % object alrerady pre-processed?
   %   oo = o;  return               % all done
   %end
   
   %Message(o,'Brewing basis data ...');
   %Gs = filter(corazon,'Integrator');

   t = o.data.t;

   ax = o.data.ax;
   ay = o.data.ay;
   az = o.data.az;

   bx = o.data.bx;
   by = o.data.by;
   bz = o.data.bz;
   
   %vx = filter(Gs,ax,t); 
   %vy = filter(Gs,ay,t); 
   %vz = filter(Gs,az,t); 
   
   %sx = filter(Gs,vx,t); 
   %sy = filter(Gs,vy,t); 
   %sz = filter(Gs,vz,t); 
   
   [vx,sx] = velocity(o,o.data.ax,o.data.t);
   [vy,sy] = velocity(o,o.data.ay,o.data.t);
   [vz,sz] = velocity(o,o.data.az,o.data.t);
   
      % construct bag to be stored in brew cache
      
   bag.ax = ax;
   bag.ay = ay;
   bag.az = az;

   bag.bx = bx;
   bag.by = by;
   bag.bz = bz;

   bag.vx = vx;
   bag.vy = vy;
   bag.vz = vz;

   bag.sx = sx;
   bag.sy = sy;
   bag.sz = sz;
   
   oo = cache(o,{'brew','Brew'},bag);  % set brew cache segment
end

%==========================================================================
% Rotate by Facette Angle
%==========================================================================

function oo = Rotate(o)                % Rotate By Facette Angle       
%
% ROTATE  Rotate x/y coordinates by negative facette angle
%
%            o = Rotate(o)              % rotate all
%
   %Message(o,'Brewing data: Rotation ...');
   rotate = opt(o,{'brew.rotate',0});
   
      % let's check if brewed data is up-to-date in brew cache segment
      % if not then brew basis data and cluster data 
      
   bag = cache(o,{'brew'});
   if isempty(bag)
      o = Basis(o);                     % brew basis cache
      o = Cluster(o);                   % brew cluster cache
   end
   
      % finally we retrieve cached data from brew cache segment
      
   bag = cache(o,{'brew'});   
   itab = cache(o,'cluster.itab');
   
      % since we trust that all data are available we assert on
      % bag (brew) and index (cluster)
      
   if (isempty(bag) || isempty(itab))
      assert(~isempty(bag) && ~isempty(itab));
   end

      % init data of 1-2-3 coordinate system
      
   bag.a1 = bag.ay;  bag.v1 = bag.vy;  bag.s1 = bag.sy;
   bag.a2 = bag.ax;  bag.v2 = bag.vx;  bag.s2 = bag.sx;
   bag.a3 = bag.az;  bag.v3 = bag.vz;  bag.s3 = bag.sz;
    
      % ok - cached data (presented in bag) is now ready
      
   switch rotate
      case 0
         'nothing to do!';
      case 1
         bag = Rotate1(o,bag);
      case 2
         bag = Rotate2(o,bag);
      otherwise
         error('bad rotation selector');
   end
   
      % that's it -  store bag back into brew cache segment
      
   oo = cache(o,'brew',bag);
   
   function bag = Rotate1(o,bag)     
      for (i=1:size(itab,1))
         phi = facette(o,i);
         if (isnan(phi) || ~rotate)
            continue
         end
         cdx = itab(i,1):itab(i,2);       % i-th cluster infdices

         S = sin(phi*pi/180);
         C = cos(phi*pi/180);

            % rotate accelerations

         bag.a2(cdx) = C*bag.ax(cdx) - S*bag.ay(cdx);   % was ax
         bag.a1(cdx) = S*bag.ax(cdx) + C*bag.ay(cdx);   % was ay

            % rotate velocities

         bag.v2(cdx) = C*bag.vx(cdx) - S*bag.vy(cdx);
         bag.v1(cdx) = S*bag.vx(cdx) + C*bag.vy(cdx);

            % rotate elongations

         bag.s2(cdx) = C*bag.sx(cdx) - S*bag.sy(cdx);
         bag.s1(cdx) = S*bag.sx(cdx) + C*bag.sy(cdx);
      end
   end
   function bag = Rotate2(o,bag)     
      
      theta = get(o,{'angle',90});

      S2 = sin(theta*pi/180);  C2 = cos(theta*pi/180);
      
      T2 = [0 1 0; -S2 0 C2; C2 0 S2]; % transformation matrix 2
      
      av = bag.a1;
      for (i=1:size(itab,1))
         phi = facette(o,i);
         if (isnan(phi) || ~rotate)
            continue
         end
         cdx = itab(i,1):itab(i,2);       % i-th cluster infdices

         S1 = sin(phi*pi/180);  C1 = cos(phi*pi/180);
      
         T1 = [C1 -S1 0; S1 C1 0; 0 0 1];
         
            % rotate accelerations

         if(0)
            bag.a2(cdx) = C1*bag.ax(cdx) - S1*bag.ay(cdx);   % was ax
            av(cdx)     = S1*bag.ax(cdx) + C1*bag.ay(cdx);   % was ay

            bag.a3(cdx) = C2*bag.az(cdx) - S2*av(cdx);
            bag.a1(cdx) = S2*bag.az(cdx) + C2*av(cdx);

               % rotate velocities

            bag.v2(cdx) = C1*bag.vx(cdx) - S1*bag.vy(cdx);
            bag.v1(cdx) = S1*bag.vx(cdx) + C1*bag.vy(cdx);

               % rotate elongations

            bag.s2(cdx) = C1*bag.sx(cdx) - S1*bag.sy(cdx);
            bag.s1(cdx) = S1*bag.sx(cdx) + C1*bag.sy(cdx);
         end
         
         T = T2*T1;                    % total rotation matrix
         
         A = [bag.ax(cdx); bag.ay(cdx); bag.az(cdx)];
         bag.a1(cdx) = T(1,:)*A;
         bag.a2(cdx) = T(2,:)*A;
         bag.a3(cdx) = T(3,:)*A;

         V = [bag.vx(cdx); bag.vy(cdx); bag.vz(cdx)];
         bag.v1(cdx) = T(1,:)*V;
         bag.v2(cdx) = T(2,:)*V;
         bag.v3(cdx) = T(3,:)*V;

         S = [bag.sx(cdx); bag.sy(cdx); bag.sz(cdx)];
         bag.s1(cdx) = T(1,:)*S;
         bag.s2(cdx) = T(2,:)*S;
         bag.s3(cdx) = T(3,:)*S;
      end
   end
end

%==========================================================================
% Estimate Cluster Indices And Updated Time Vector
%==========================================================================

function oo = Cluster(o)               % Estimate Cluster Index & Time 
%
% Cluster  Estimate cluster indices and updated time vector
%
%            o = Rotate(o)              % rotate all
%
   %Message(o,'Brewing cluster data ...');
   oo = cluster(o,'Brew');
end

%==========================================================================
% Spec
%==========================================================================

function o = Spec(o)
%
% SPEC   Brew spec - main reason is to invoke Packafe brewing if spec
%        changes
%
   fprintf('brewing spec ...\n');

   bag = opt(o,'spec');
   o = cache(o,'spec',bag); 
   
      % here comes the main reason for spec brewing: brew Package!
      
   o = Package(o);                     % main reason for spec brewing
end

%==========================================================================
% Package Data
%==========================================================================

function oo = Package(oo)              % Brew Package Data             
%
% PACKAGE  Brew package data:
%
%             oo = Package(oo)
%
%          Package parameters to be brewed
%
%             objects     list of object titles
%             files       list of object filenames
%
%          Package data to be brewqed:
%
%             facettes    number of detected facettes
%             cpks        strong Cpk's
%             cpkw        weak   Cpk's
%             mgrs        strong magnitude reserve
%             mgrw        weak magnitude reserve
%             mgn         magnitudes
%             sig         sigmas
%             thdr        total harmonic dustortion RMS
%
   is = @isequal;                      % short hand
   if ~is(oo.type,'pkg')
      error('package type (pkg) expected');
   end
   
      % get list of 'cut'-objects belonging to package
      
   package = get(oo,{'package',''}); 
   o = pull(oo);                       % pull shell object
   list = Basket(o,'package',package); 
   
      % process list of objects if package not up-to-date
      
   if ~PackageCheck(oo,list)
      oo = PackageBrew(oo,list);       % brew package data
   end
      
      % update package cache
      
   oo = PackageRefresh(oo);            % soft refresh package cache
   
      % if package object matches current object then we also do
      % a hard refresh of current object
      
   [co,idx] = current(o);              % get current object
   if is(co.type,'pkg') && is(get(co,{'package','?*?'}),package)
      o.data{idx} = oo;
      push(o);
   end
end
function ok = PackageCheck(o,list)     % Is Package Up-To-Date         
   assert(isequal(o.type,'pkg'));
   ok = false;                         % false per default

   titles = data(o,{'titles',{}});
   if (length(titles) ~= length(list))
      return                           % return false
   end
   
   for (i=1:length(list))
      oo = list{i};
      title = get(oo,{'title',''});
      if ~isequal(title,titles{i})
         return                        % return false
      end
   end
   ok = true;
end
function o = PackageBrew(o,list)       % Brew Package Data             
   assert(isequal(o.type,'pkg'));
   
   files = {};  objects = {};  
   cpks = [];  cpkw = [];  mgrs = [];  mgrw = [];  
   mgn = [];   sig = [];
   
   for (i=1:length(list))
      oo = inherit(list{i},o);
      
      objects{end+1} = get(oo,{'title',''});
      files{end+1} = get(oo,{'file',''});
      
      [oo,bag,rfr] = cache(oo,'brew'); % get brew bag from cache
      
      [cpks(i),cpkw(i),mgrs(i),mgrw(i),mgn(i),sig(i)] = cpk(oo,'a');
      
      thd(i) = thdr(oo,'a');           % total harmonic distortion
      
      facettes(i) = cluster(oo,inf);
   end
   
   o = set(o,'objects',objects);
   o = set(o,'files',files);
   
   o = data(o,'facettes,cpks,cpkw,mgrs,mgrw,mgn,sig',...
               facettes,cpks,cpkw,mgrs,mgrw,mgn,sig);
   o = data(o,'thdr',thd);
end
function o = PackageRefresh(o)         % Soft Refresh Package Cache    
   bag.objects = get(o,{'objects',{}});
   bag.files = get(o,{'files',{}});
   
   bag = Refresh(o,bag,'facettes',[]);
   bag = Refresh(o,bag,'cpks',[]);
   bag = Refresh(o,bag,'cpkw',[]);
   bag = Refresh(o,bag,'mgrs',[]);
   bag = Refresh(o,bag,'mgrw',[]);
   bag = Refresh(o,bag,'mgn',[]);
   bag = Refresh(o,bag,'sig',[]);
   bag = Refresh(o,bag,'thdr',[]);

   USL = opt(o,{'spec.thdr',0.05});
   bag.chk = USL./bag.thdr;
   o = cache(o,'package',bag);         % store bag in cache
   
   function bag = Refresh(o,bag,tag,default)
      value = data(o,{tag,default});
      bag.(tag) = value;
   end
end
function [list,idx] = Basket(o,tag,val)% Get Basket List               
   list = {}; idx = [];
   for (i=1:length(o.data))
      oo = o.data{i};      
      if type(oo,{'cut'}) 
         if isequal(get(oo,{tag,''}),val)
            list{end+1} = oo;          % put into list
            idx(end+1) = i;            % remember index
         end
      end
   end   
end

%==========================================================================
% Helper
%==========================================================================

function o = Message(o,title,comment)  % Show Message & Wait a Bit     
   if ~opt(o,{'verbose',0})
      fprintf('%s\n',title);
      return
   end
   
   if (nargin == 1)
      message(o);
   elseif (nargin == 2)
      message(o,title);
   else
      message(o,title,comment);
   end
   pause(0.1);
end
