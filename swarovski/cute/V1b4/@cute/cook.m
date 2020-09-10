function [d,df,sym] = cook(o,sym,mode) % The Data Cook                 
%
% COOK   The data cook
%
%    Cook up data according to selected cook mode and bias mode options
%
%       t = cook(o,sym,stream')        % get cooked stream given by symbol
%       t = cook(o,sym)                % same as above
%
%    Stream Examples
%
%       t = cook(o,'t')                % get cooked time
%       t = cook(o,':')                % get cooked time (equivalent)
%       ax_ = cook(o,'ax#')            % get acceleration raw data x
%       a2 = cook(o,'a2')              % get process (cross) acceleration 2
%
%    Package Data and Spec Examples
%
%       bag = cook(o,'spec')           % get cached spec data
%
%       bag = cook(o,'package')        % get cached package data
%       cpk = bag.cpks;                % pick strong cpk values
%      
%
%    Supported Data Streams (given by symbol 'sym')
%
%       1) Kappl sensor raw data:
%
%          ax#     Kappl acceleration x raw data
%          ay#     Kappl acceleration y raw data
%          az#     Kappl acceleration z raw data
%
%       2) Kappl sensor related data derived from raw data
%          
%          ar#     Kappl radial acceleration based on ax#,ay#,az#
%                  => should match a = sqrt(a1^2 + a2^2 + a3^2)
%
%       3) Kappl sensor processed data (consistent with velocity/elongation):
%
%          ax      Kappl acceleration x
%          ay      Kappl acceleration y
%          az      Kappl acceleration z
%
%          vx      Kappl velocity x
%          vy      Kappl velocity y
%          vz      Kappl velocity z
%
%          sx      Kappl elongation x
%          sy      Kappl elongation y
%          sz      Kappl elongation z
%
%       4) Radial Kappl sensor acc./velocity/elongation (calc'ed from raw)
%
%          ar#     Kappl raw radial sensor acceler.
%          vr#     Kappl raw radial sensor velocity
%          sr#     Kappl raw radial sensor elongation
%
%       5) Radial Kappl sensor acceleration/velocity/elongation (calculated)
%
%          ar      Kappl radial sensor acceleration
%          vr      Kappl radial sensor velocity
%          sr      Kappl radial sensor elongation
%
%       6) Cutting Coordinates
%
%          a1      process acceleration (cutting direction)
%          a2      process acceleration (cross direction)
%          a3      process acceleration (normal direction)
%
%          v1      process velocity     (cutting direction)
%          v2      process velocity     (cross direction)
%          v3      process velocity     (normal direction)
%
%          s1      process elongation   (cutting direction)
%          s2      process elongation   (cross direction)
%          s3      process elongation   (normal direction)
%
%       7) Calculated Quantities
%
%          fcut    cutoff frequency
%          cpk     process capability coefficient
%          mgr     magnitude reserve
%          chk     harmonic capability coefficient
%
%       8) Cached Package Data
%
%          spec    get full structure of cached spec parameters
%          package get full structure of cached package data
%
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
%          k                           % facette k (k=1...kmax)
%
%    Copyright(c): Bluenetics 2020
%
%    See also: CUTE, PLOT, ANALYSE
%
   if (nargin < 3)
      mode = 'stream';
   end
   
      % object type check/dispatch
      
   if o.is(sym,{'package','spec'})
      [d,df,sym] = GeneralData(o,sym);
      return
   elseif ~type(o,{'cut'})   
      d = [];  df = [];  sym = '';
      return
   end
   
      % hard refresh brew cache        % also hard refreshes cluster cache
      
   [o,bag,rf] = cache(o,o,'brew');     % refresh brew cache segment (hard)

      % dispatch on signal symbol
            
   switch sym
      case {'t',':'}                   % time vector
         sym = ':';                    % get time data later
         
      case 'ax#'                       % kappl x-acceleration raw data
         d = o.data.ax;
      case 'ay#'                       % kappl y-acceleration raw data
         d = o.data.ay;
      case 'az#'                       % kappl z-acceleration raw data
         d = o.data.az;
         
      case 'ar#'                       % kappl radial raw acceleration
         ax = o.data.ax;
         ay = o.data.ay;
         az = o.data.az;
         d = sqrt(ax.*ax + ay.*ay + az.*az);
         
      case 'bx#'                       % kolben x-acceleration raw data 
         d = o.data.bx;
      case 'by#'                       % kolben y-acceleration raw data
         d = o.data.by;
      case 'bz#'                       % kolben z-acceleration raw data
         d = o.data.bz;
      case 'br#'                       % kolben radial raw acceleration
         bx = o.data.bx;
         by = o.data.by;
         bz = o.data.bz;
         d = sqrt(bx.*bx + by.*by + bz.*bz);
                
      case 'ax'                        % kappl x-acceleration
         d = bag.ax;
      case 'ay'                        % kappl y-acceleration
         d = bag.ay;
      case 'az'                        % kappl z-acceleration
         d = bag.az;
      case 'ar'                        % kappl radial acceleration
         ax = bag.ax;
         ay = bag.ay;
         az = bag.az;
         d = sqrt(ax.*ax + ay.*ay + az.*az);

      case 'bx'                        % kolben x-acceleration
         d = bag.bx;
      case 'by'                        % kolben y-acceleration
         d = bag.by;
      case 'bz'                        % kolben z-acceleration
         d = bag.bz;
      case 'br'                        % kolben radial acceleration
         bx = bag.bx;
         by = bag.by;
         bz = bag.bz;
         d = sqrt(bx.*bx + by.*by + bz.*bz);
          
      case 'vx'                        % kappl x-velocity
         d = bag.vx;
      case 'vy'                        % kappl y-velocity
         d = bag.vy;
      case 'vz'                        % kappl z-velocity
         d = bag.vz;
      case {'v','vr'}                  % kappl radial velocity
         vx = bag.vx;
         vy = bag.vy;
         vz = bag.vz;
         d = sqrt(vx.*vx + vy.*vy + vz.*vz);
         
      case 'sx'                        % kappl x-elongation
         d = bag.sx;
      case 'sy'                        % kappl y-elongation
         d = bag.sy;
      case 'sz'                        % kappl z-elongation
         d = bag.sz;
      case {'s','sr'}                  % kappl radial elongation
         sx = bag.sx;
         sy = bag.sy;
         sz = bag.sz;
         d = sqrt(sx.*sx + sy.*sy + sz.*sz);

      case 'a1'                        % cutting acceleration 1 (cut)
         d = bag.a1;
      case 'a2'                        % cutting acceleration 2 (cross)
         d = bag.a2;
      case 'a3'                        % cutting acceleration 3 (normal)
         d = bag.a3;
      case 'a'                         % cutting radial acceleration
         a1 = bag.a1;
         a2 = bag.a2;
         a3 = bag.a3;
         d = sqrt(a1.*a1 + a2.*a2 + a3.*a3);

      case 'v1'                        % cutting velocity 1 (cut)
         d = bag.v1;
      case 'v2'                        % cutting velocity 2 (cross)
         d = bag.v2;
      case 'v3'                        % cutting velocity 3 (normal)
         d = bag.v3;
      case 'v'                         % cutting radial velocity
         v1 = bag.v1;
         v2 = bag.v2;
         v3 = bag.v3;
         d = sqrt(v1.*v1 + v2.*v2 + v3.*v3);
         
      case 's1'                        % cutting elongation 1 (cut)
         d = bag.s1;
      case 's2'                        % cutting elongation 2 (cross)
         d = bag.s2;
      case 's3'                        % cutting elongation 3 (normal)
         d = bag.s3;
      case 's'                         % cutting radial elongation
         s1 = bag.s1;
         s2 = bag.s2;
         s3 = bag.s3;
         d = sqrt(s1.*s1 + s2.*s2 + s3.*s3);
         
         % calculated quantities
         
      case 'fcut'
         d = bag.fcut;
         return
      case 'cpk'
         d = o.iif(spec(o)<=1,bag.cpks,bag.cpkw);
         return
      case 'mgr'
         d = o.iif(spec(o)<=1,bag.mgrs,bag.mgrw);
         return
      case 'chk'
         d = bag.chk;
         return
         
     otherwise
         error(['unsupported symbol: ',sym]);
   end
      
      % filtering: TBD        
         
   %o0 = cast(o,'corazon');
   
   %if (nargin == 2)
   %    [d,df,sym] = cook(o0,sym0);
   %elseif (nargin == 3)
   %    [d,df,sym] = cook(o0,sym0,'stream');
   %end

      % post processing: assign time or select by cluster indices

   [idx,t] = cluster(o);
   
   if isequal(sym,':')
      d = t;
   else
      d = d(idx);              % select signal by cluster indices
      df = [];
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
% General Data
%==========================================================================

function  [bag,dummy1,dummy2] = GeneralData(o,sym)    % General Data   
   dummy1 = [];
   dummy2 = [];
   
   switch sym
      case 'package'
         if type(o,{'pkg'})
            [~,bag] = cache(o,'package');   % soft refresh & get bag
         else
            bag = [];
         end
         
      case 'spec'
         [~,bag] = cache(o,'spec');         % soft refresh & get bag
         
       otherwise
         error(['unsupported symbol: ',sym]);
   end
   
end
