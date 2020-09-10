function oo = object(o,varargin)
% 
% OBJECT   Create a sample CIGARILLO object
%
%    A sample CIGARILLO object or derived CIGARILLO object provided with
%    sample stream data, depending on mode
%      
%       o = object(cigarillo);         % default sample object
%       object(cigarillo);             % launch menu shell
%
%    The sample object creation depends on following options
%       'format'   format of DANA object
%       'corner'   corner to start processing, like 'TopRight' or 'BotLeft'
%       'method'   processing method, like 'RowSawtooth' or 'ColMeander'
%       'm'        number of rows
%       'n'        number of columns
%       'r'        number of repeats
%       'sigma'    standard deviation of noise
%
%    See also: CIGARILLO
%
   fprintf('*** Warning: calling CIGARILLO/OBJECT might be inappropriate!\n');
   o = Construct(o);
   
   if (nargout==0)
      launch(o);
   else
      oo = o;
   end
   return
end

%==========================================================================
% Sample Object Construction 
%==========================================================================

function oo = Construct(o)             % actual object construction    
%
   m = opt(o,{'m',4});                 % row size = 4
   n = opt(o,{'n',5});                 % col size = 5
   r = opt(o,{'r',10});                % repeats = 5
   zigzag = opt(o,{'zigzag','seq'});   % sequential by default
   
   fmt = opt(o,{'format','#TKP02'});   % DANA object's format
   gantry = opt(o,{'gantry',0});       % DANA object's format
   
   sigma = opt(o,{'sigma',0.2});       % sigma = 0.2
   meth = opt(o,{'method','tlrs'});    % TopLeftRowSawtooth
   
   dphi = opt(o,{'dphi',0})*pi/180;    % rotation 
   drift = opt(o,{'drift',0});         % drift
   scale = opt(o,{'scale',0});         % scaling
   lambda = opt(o,{'lambda',0})+1e-10; % lambda (speed of drift)
   
   %sizes = [m n r];
   
   ix = 1:n;  iy = (m:-1:1);
   dx = -(n-1)/2:1:(n-1)/2;  dx = dx(ix) / max(abs(dx)) * scale;
   dy = -(m-1)/2:1:(m-1)/2;  dy = dy(iy) / max(abs(dy)) * scale;
   
   assert(length(ix)==length(dx) && length(iy)==length(dy));
   
   fx = ix + 10*sin(ix);
   fy = iy + 10*cos(iy);
   
   [Ax,Ay] = meshgrid(fx,fy);
   [Qx,Qy] = meshgrid(ix,iy);
   [Dx,Dy] = meshgrid(dx,dy);
%   
% Qx, Qy, Dx and Dy are now established (mxn matrices). The tricky part
% is the system vector, since it defines the actual zig-zag order.
%
%
% ok - major challenges already mastered. continue with straight forward
% stuff
%
   t = [];  dx = [];  dy = [];  qx = [];  qy = [];  
   ax = [];  ay = [];  sys = [];
   tr = 0;  dt = 0.5;
   
   
   for (i=1:r)
      
      sysi = gantry + zeros(1,m*n);       % default: system info vector
      if (gantry == 0)                    % dual gantry?
         sysi = System(o,m,n,zigzag);     % compose a proper system vector
      end
   
         % calculate indices with respecting system vector. Function
         % 'method' does all the magic ...
   
      [idx,Idx] = method(o,meth,m,n,sysi); % do the magic ...
      Sys = sysi(Idx);
      
      t = [t, tr + dt*(0:length(idx)-1)];
      tr = max(t) + dt;
      
      nx = sigma*randn(size(idx));     % axis noise x
      ny = sigma*randn(size(idx));     % axis noise y
      
      d = [Dx(idx); Dy(idx)] * (1-exp(-i*lambda/r));
      
         % make a linear transformation
      
      R = [cos(i*dphi) -sin(i*dphi);  sin(i*dphi) cos(i*dphi)];
      d = R*d + i*drift/r;
      
      dx = [dx, d(1,:)+nx];
      dy = [dy, d(2,:)+ny];

      ax = [ax, Ax(idx)];
      ay = [ay, Ay(idx)];
      
      qx = [qx, Qx(idx)];
      qy = [qy, Qy(idx)];
      
      sys = [sys, Sys(idx)];
      assert(all(sysi==Sys(idx)));
   end
%
% from here 'o' will be a newly constructed DANA object
%
   o = opt(caramel('dana'),opt(o));
   o = set(o,'title',[o.now,' Sample DANA object']);
   o = set(o,'comment',{['Created by: object(dana,''tlrs'')']});
   o = set(o,'sizes',[m n r]);
   o = set(o,'method',meth);
   o = set(o,'format',fmt);
   o = set(o,'distance',[1000 1000]);
   
   o = data(o,'time',t,'dx',dx,'dy',dy);
   o = data(o,'ax',ax,'ay',ay,'qx',qx,'qy',qy,'sys',sys);
   
   o = Config(o);                     % Provide some object info
   oo = launch(o,'shell');
   return
end

function o = Config(o)                 % Configurate plotting          
%
   o = config(o,'ax',{0,'r',1});
   o = config(o,'ay',{0,'b',1});
   o = config(o,'dx',{1,'r',1});
   o = config(o,'dy',{2,'b',1});
   o = config(o,'px',{0,'r',1});
   o = config(o,'py',{0,'b',1});
   o = config(o,'qx',{0,'r',1});
   o = config(o,'qy',{0,'b',1});
   
   o = subplot(o,'layout',1);
   o = category(o,1,[0 0],[0 0],'µ');
   return
end

function sys = System(o,m,n,zigzag)    % Compose System Vector         
%
% SYSTEM   Compose proper system vector
%
%    The whole procedure is fairly tricky, I don't make the trial to ex-
%    plain it to everybody.
%
   'take a beer before you change somethinh here!';
%   
% Let's start with simple things - the creation of the system-number 
% matrix. Independently of the actual method we create the 'Sys' matrix by
% assuming 'blcs' method, where the first half of the time sequence is 
% done by the left system (1) and the second half is done by the right
% system (2).
%
   k = round(m*n/2);                % middle index
   sys1 = 1*ones(1,k);
   sys2 = 2*ones(1,m*n-k);
   sys = [sys1,sys2];
   assert(length(sys)==m*n);
%   
% Now, as we have the system matrix (see how it looks!) we can definitely
% forget the way how we created it. Now we have to incorporate the zig-zag
% mode
%
   'take another beer!';
%
% In sequential zigzag mode we assume that in the first phase only system 1
% is working and system 2 is idle. After that system 2 is working and sys-
% tem 1 is idle. Easy to create the system vector.
%
   switch zigzag
      case 'seq'                       % sequential mode
         sys = [sys1,sys2];            % go with current 'sys'
      case 'alt'
         sys0 = [1;2]*ones(1,m*n,1);
         sys0 = sys0(:)';
         sys = sys0(1:m*n);            % alternating sequence
      case 'rand'
         sys = [];
         while(~isempty(sys1) && ~isempty(sys2))
            if (rand >= 0.5)
               sys(1,end+1) = 1;  sys1(1) = [];
            else
               sys(1,end+1) = 2;  sys2(1) = [];
            end
         end
         sys = [sys,sys1,sys2];
      otherwise
         error('bad zigzag mode!');
   end
end

