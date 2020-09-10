function [d,df,sym] = cook(o,sym,mode) % The Data Cook                 
%
% COOK   The data cook
%
%    Cook up data according to selected cook mode and bias mode options
%
%       [d,df,sym] = cook(o,idx)       % get cooked data by config index
%       x = cook(o,'x')                % get cooked x-data by symbol
%
%       t = cook(o,':')                % get cooked data by 'time symbol'
%       s = cook(o,'#')                % get cooked system number info
%
%       rx = cook(o,'!x')              % get cooked main x-coordinates
%       ry = cook(o,'!y')              % get cooked main y-coordinates
%
%       rx = cook(o,'$x')              % get cooked reference x-coordinates
%       ry = cook(o,'$y')              % get cooked reference y-coordinates
%
%    The cook mode can be also directly passed
%
%       x = cook(o,'x','overlay')           % explicite 'cook' mode option
%       x = cook(o,'x','overlay','drift')   % explicite 'drift' bias option
%       x = cook(o,'x',mode,bias,scope)     % explicite 'drift' bias option
%
%    Specific signals for CUT objects
%
%       oo = cook(o)                   % preprocess object
%
%       ax = cook(oo,'ax','stream')    % acceleration x
%       ay = cook(oo,'ay','stream')    % acceleration y
%       az = cook(oo,'az','stream')    % acceleration y
%       
%       vx = cook(oo,'vx','stream')    % velocity x
%       vy = cook(oo,'vy','stream')    % velocity y
%       vz = cook(oo,'vz','stream')    % velocity y
%
%       sx = cook(oo,'sx','stream')    % elongation x
%       sy = cook(oo,'sy','stream')    % elongation y
%       sz = cook(oo,'sz','stream')    % elongation y
%
%    COOK incorporates the following options:
%
%       opt(o,'cook')
%          'stream'                    % return a data stream
%          'fftlin'                    % return FFT
%          'fftlog'                    % return FFT (same)
%
%       opt(o,'bias')
%          'drift'                     % drift mode
%          'absolute'                  % absolute mode
%          'abs1000'                   % absolute * 1000 mode
%          'deviation'                 % deviation mode
%
%       opt(o,'overlays')
%          'index'                     % index mode
%          'time'                      % time mode
%
%       opt(o,'facette')
%         -1                           % plot compact facette bursts
%          0                           % plot all
%          1                           % facette 1
%
   if ~isequal(type(o),'cul')
      d = [];  df = [];  sym = '';
      return
   end
   
   if (nargin == 1 && nargout == 1)
      d = PreProcess(o);
      return
   end

   if (nargin < 3)
      mode = 'stream';
   end
   
      % pre-process (if already pre-processed then this call is ignored!)
      
   o = PreProcess(o); 
      
   if isequal(sym,'bx') || isequal(sym,'by') || isequal(sym,'bz')
      sym0 = sym;
   elseif (length(sym) == 2)
      sym0 = [sym(1),'_',sym(2)];
   else
      sym0 = sym;
   end
   
   o0 = cast(o,'cordoba');
   if (nargin == 2)
       [d,df,sym] = cook(o0,sym0);
   elseif (nargin == 3)
       [d,df,sym] = cook(o0,sym0,'stream');
   end
   
      % select by crowd indices

   if isequal(sym,':')
      [~,cdx,d] = crowd(o);
   else
      [~,cdx] = crowd(o);
      d = d(cdx);             % select unfiltered signal by crowd indices
      if ~isempty(df)
         df = df(cdx);        % select filtered signal by crowd indices
      end
   end

      % eventual Fourier transform
      
   switch mode
      case 'stream'
         'all done!';
      case {'fftlin','fftlog'}
         if o.is(sym,':')
            [d,~] = fft(o,d,[]);
         else
            [~,d] = fft(o,[],d); 
         end
   end
end

%==========================================================================
% preprocessing
%==========================================================================

function oo = PreProcess(o)
   if ~isempty(data(o,'s_x'))       % object alrerady pre-processed?
      oo = o;
      return                        % all done
   end
   
   [vx,sx,ax] = velocity(o,o.data.ax,o.data.t);
   [vy,sy,ay] = velocity(o,o.data.ay,o.data.t);
   [vz,sz,az] = velocity(o,o.data.az,o.data.t);
   
   %o.data.Ax = ax;
   %o.data.Ay = ay;
   %o.data.Az = az;

   o.data.vx = vx;
   o.data.vy = vy;
   o.data.vz = vz;

   o.data.sx = sx;
   o.data.sy = sy;
   o.data.sz = sz;
   
   oo = Rotate(o);
end

%==========================================================================
% rotate by facette angle
%==========================================================================

function o = Rotate(o)
%
% ROTATE  Rotate x/y coordinates by negative facette angle
%
%            o = Rotate(o)              % rotate all
%
   rotate = opt(o,{'select.rotate',0});
   
   a = sqrt(o.data.ax.^2+o.data.ay.^2);
   idx = crowd(o,a);

   o.data.a_x = o.data.ax;
   o.data.a_y = o.data.ay;
   o.data.a_z = o.data.az;

   o.data.v_x = o.data.vx;
   o.data.v_y = o.data.vy;
   o.data.v_z = o.data.vz;
   
   o.data.s_x = o.data.sx;
   o.data.s_y = o.data.sy;
   o.data.s_z = o.data.sz;
   
   for (i=1:size(idx,1))
      phi = facette(o,i);
      if ~isnan(phi)
         if rotate
            S = sin(phi*pi/180);
            C = cos(phi*pi/180);
         else
            C = 1;  S = 0;
         end

         cdx = idx(i,1):idx(i,2);
         ax = C*o.data.ax(cdx) - S*o.data.ay(cdx);
         ay = S*o.data.ax(cdx) + C*o.data.ay(cdx);

         o.data.a_x(cdx) = ax;
         o.data.a_y(cdx) = ay;

         vx = C*o.data.vx(cdx) - S*o.data.vy(cdx);
         vy = S*o.data.vx(cdx) + C*o.data.vy(cdx);

         o.data.v_x(cdx) = vx;
         o.data.v_y(cdx) = vy;

         sx = C*o.data.sx(cdx) - S*o.data.sy(cdx);
         sy = S*o.data.sx(cdx) + C*o.data.sy(cdx);

         o.data.s_x(cdx) = sx;
         o.data.s_y(cdx) = sy;      
      end
   end
end
