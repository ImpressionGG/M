function [specs,specw] = spec(o,sym,positive)
%
% SPEC  Fetch option based strong (specs) and weak (specw) spec limits 
%       related to a given symbol.
%
%          [specs,specw] = spec(o,sym) % get strong and weak spec limits
%          [specs,specw] = spec(o,sym) % get strong and weak spec limits
%
%       Return values are pairs of lower and uper spec limit
%
%          specs = [LSLs USLs]         % strong lower/upper spec limits
%          specw = [LSLw USLw]         % weak lower/upper spec limits
%
%       Return spec mode:_
%
%          mode = spec(o)              % return spec mode (0/1/2)
%
%       Alternatively plot spec limits according to option settings
%
%          spec(o,sym)                 % draw spec limits 
%          spec(o,sym,1)               % draw positive spec limits 
%
%       Options:
%          spec.mode                   % 0:off, 1:strong, 2:weak
%          spec.color                  % color of spec limits
%          spec.a                      % acceleration spec
%          spec.v                      % velocity spec
%          spec.s                      % elongation spec
%
%       Copyright(c): Bluenetics 2020
%
%       See also: CUTE, PLOT
%
   if (nargin == 1)                    % mode = spec(o)
      specs = opt(o,{'spec.mode',0});
      return
   elseif (nargin < 3)
      positive = 0;
   end
   
   o = opt(o,'positive',positive);     % we might need in Plot function
   o = opt(o,'circular',false);
   
      % dispatch symbol
   
   switch sym
      case {'a','ax','ay','az','ar','ax#','ay#','az#','Ax','Ay','Az','Ar',...
            'a1','a2','a3','A1','A2','A3','A'}
         spec = opt(o,'spec.a');
      case {'Axy','Axz','Ayz','Azy','AXY','AXZ','AYZ','AZY',...
            'A12','A13','A23','A31','A32'}
         spec = opt(o,'spec.a');
          o = opt(o,'circular',true);
          
      case {'v','vx','vy','vz','vr','vx#','vy#','vz#','Vx','Vy','Vz','Vr',...
            'V','V1','V2','V3'}
         spec = opt(o,'spec.v');
      case {'s','sx','sy','sz','s','sx#','sy#','sz#','Sx','Sy','Sz','Sr',...
            'S','S1','S2','S3'}
         spec = opt(o,'spec.s');
         
      case {'b','bx','by','bz','br','bx#','by#','bz#','Bx','By','Bz','Br'}
         spec = opt(o,'spec.b');
      case {'Bxy','Bxz','Byz','Bzy','BXY','BXZ','BYZ','BZY'}
          spec = opt(o,'spec.b');
          o = opt(o,'circular',true);
         
         
      case {'Vxy','Vxz','Vyz','Vzy','VXY', 'V12','V13','V23','V32'}
         spec = opt(o,'spec.v');
          o = opt(o,'circular',true);
          
      case {'Sxy','Sxz','Syz','Szy','SXY','S12','S21','S13','S23','S32'}
         spec = opt(o,'spec.s');
          o = opt(o,'circular',true);
      case {'Cr'}
         return                        % not supported
      otherwise
         error(['unsupported stream for Cpk calculation: ',sym]);
   end

   if isempty(spec)
      specs = 0;  specw = 0;
      return
   end
   
   specs = spec(1)*[-1 1];
   specw = spec(2)*[-1 1];
   
   if (nargout == 0)
      switch opt(o,{'spec.mode',0})
         case 0
            return
         case 1
            Plot(o,sym,specs);
         case 2
            Plot(o,sym,specs,specw);
         otherwise
            error('internal');
      end
   end
end

%==========================================================================
% Plot Situation of Cpk Calculation
%==========================================================================
 
function Plot(o,sym,specs,specw)
   if opt(o,{'circular',0})
      if (nargin == 3)
         CircPlot(o,sym,specs);
      else
         CircPlot(o,sym,specs,specw);
      end
   else
      if (nargin == 3)
         TimePlot(o,sym,specs);
      else
         TimePlot(o,sym,specs,specw);
      end
   end
   return
   
   function TimePlot(o,sym,specs,specw)     %                          
      lw = opt(o,{'spec.linewidth',1});
      
      oo = corazon(o);
      col = opt(o,{'spec.color','c'});
      positive = opt(o,'positive');

      xlim = get(gca,'xlim');

      hold on
      hdl = plot(oo,xlim,specs(2)*[1 1],[col,'-.']);
      set(hdl,'LineWidth',lw);

      if ~positive
         hdl = plot(oo,xlim,specs(1)*[1 1],[col,'-.']);
         set(hdl,'LineWidth',lw);
      end

      ylim = get(gca,'Ylim');  lim = 6/5*specs;
      ylim = [min(ylim(1),lim(1)), max(ylim(2),lim(2))]; 
      if (positive)
         ylim(1) = 0;
      end
      set(gca,'ylim',ylim);

      if (nargin == 4)
         hdl = plot(oo,xlim,specw(2)*[1 1],[col,'-.']);
         set(hdl,'LineWidth',lw);

         if ~positive
            hdl = plot(oo,xlim,specw(1)*[1 1],[col,'-.']);
            set(hdl,'LineWidth',lw);
         end

         ylim = get(gca,'Ylim');  lim = 6/5*specw;
         if (positive)
            ylim = [0, max(ylim(2),lim(2))]; 
         else
            ylim = [min(ylim(1),lim(1)), max(ylim(2),lim(2))]; 
         end
         set(gca,'ylim',ylim);
      end
   end
   function CircPlot(o,sym,specs,specw)     %                          
      oo = corazon(o);
      col = opt(o,{'spec.color','c'});

      rs = specs(2);  
      phi = 0:pi/100:2*pi;
      
      
      hold on
      hdl = plot(oo,rs*cos(phi),rs*sin(phi),[col,'-.']);
      set(hdl,'LineWidth',0.1);


      if (nargin == 4)
         rw = specw(2);
         hdl = plot(oo,rw*cos(phi),rw*sin(phi),[col,'-.']);
         set(hdl,'LineWidth',0.1);
      end
   end
end
