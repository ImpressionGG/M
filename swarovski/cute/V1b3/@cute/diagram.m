function oo = diagram(o,mode,x,y,sub,heading)                          
%
% DIAGRAM Draw Diagram in given subplot
%
%            diagram(o,mode,x,y,sub)
%            diagram(o,'Ax',t,ax,[2 1 1])
%
%         with mode:
%            'Ax','Ay','Az'  acceleration x,y,z
%            'Vx','Vy','Vz'  velocity     x,y,z
%            'Sx','Sy','Sz'  elongation   x,y,z
%
%            'Axy'           acceleration x/y plot
%            'Vxy'           velocity x/y plot
%            'Sxy'           elongation x/y plot
%
%            'Ar'            acceleration magnitude
%            'Vr'            velocity magnitude
%            'Sr'            elongation magnitude
%
%        Options:
%
%           metrics:         show metrics on title (default true)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CUTE, PLOT, ANALYSE
%
   lw = opt(o,{'style.linewidth',1});
   epilog = opt(o,'facette');
   specs = [];                         % no specs by default
   
   tit = '';  xlab = ''; ylab = '';  col = '';  xyz = 0;  
   kind = '';  cat = 0;  specs=[]; 

   o = Dispatch(o,mode);               % dispatch plot parameters 
   if (nargin >= 6)
      tit = heading;                   % overwrite
   end
   
   Plot(o);                            % actual plotting
   spec(o,mode,all(y>=0));             % draw spec limits
   Labels(o);                          % Provide Labels                
   
   oo = var(o,'hax',gca);
   idle(o);
   return
   
   function o = Dispatch(o,mode)       % Dispatch Plot Parameters      
      metrics = opt(o,{'metrics',1});
      switch mode
         
            % Kappl acceleration
            
         case 'Ax'
            tit = 'Kappl Acceleration X';  ylab = 'ax [g]';  col = 'rry';
            xyz = 0;  kind = 'a';  cat = 1;  specs = opt(o,{'specs.a',[]});
         case 'Ay'
            tit = 'Kappl Acceleration Y';  ylab = 'ay [g]';  col = 'rry'; 
            xyz = 0;  kind = 'a';  cat = 1;  specs = opt(o,{'specs.a',[]});
         case 'Az'
            tit = 'Kappl Acceleration Z';  ylab = 'az [g]';  col = 'rry';
            xyz = 0;  kind = 'a';  cat = 1;  specs = opt(o,{'specs.a',[]});
         case 'Ar'
            tit = sprintf('Kappl Acceleration Magnitude (amax = %g g)',round(max(y)));    
            ylab = 'ar [g]';  col = 'rm'; xyz = 0;  kind = 'a';  cat = 1;
            specs = opt(o,{'specs.a',[]});

         case 'A1'
            tit = 'Cutting Acceleration 1';  ylab = 'a1 [g]';  col = 'r';
            xyz = 0;  kind = 'a';  cat = 1;  specs = opt(o,{'specs.a',[]});
         case 'A2'
            tit = 'Cross Acceleration 2';  ylab = 'a2 [g]';  col = 'r'; 
            xyz = 0;  kind = 'a';  cat = 1;  specs = opt(o,{'specs.a',[]});
         case 'A3'
            tit = 'Normal Acceleration 3';  ylab = 'a3 [g]';  col = 'r';
            xyz = 0;  kind = 'a';  cat = 1;  specs = opt(o,{'specs.a',[]});
         case 'A'
            if (metrics)
               tit = sprintf('Process Acceleration Magnitude (amax = %g g)',round(max(y)));  
            else
               tit = sprintf('Process Acceleration Magnitude');  
            end
            ylab = 'a [g]';  col = 'r'; xyz = 0;  kind = 'a';  cat = 1;
            specs = opt(o,{'specs.a',[]});
             
            % Kolben acceleration
            
         case 'Bx'
            tit = 'Kolben Acceleration X';  ylab = 'bx [g]';  col = 'rrky';
            xyz = 0;  kind = 'b';  cat = 1;  specs = opt(o,{'specs.b',[]});
         case 'By'
            tit = 'Kolben Acceleration Y';  ylab = 'by [g]';  col = 'rrky'; 
            xyz = 0;  kind = 'b';  cat = 1;  specs = opt(o,{'specs.b',[]});
         case 'Bz'
            tit = 'Kolben Acceleration Z';  ylab = 'bz [g]';  col = 'rrky';
            xyz = 0;  kind = 'b';  cat = 1;  specs = opt(o,{'specs.b',[]});
         case 'Br'
            tit = sprintf('Kolben Acceleration Magnitude (amax = %g g)',round(max(y)));    
            ylab = 'b [g]';  col = 'rrk'; xyz = 0;  kind = 'b';  cat = 1;

         
         case 'Cr'
            tit = sprintf('Correlation of Kolben-Kappl Acceleration Magnitudes',round(max(y)));    
            ylab = 'b [g]';  col = 'rrk'; xyz = 0;  kind = 'b';  cat = 1;


         case 'Vx'
            tit = 'Kappl Velocity X';      ylab = 'vx [mm/s]';  col = 'b';
            xyz = 0;  kind = 'v';  cat = 3;
         case 'Vy'
            tit = 'Kappl Velocity Y';      ylab = 'vy [mm/s]';  col = 'b';
            xyz = 0;  kind = 'v';  cat = 3;
         case 'Vz'
            tit = 'Kappl Velocity Z';      ylab = 'vz [mm/s]';  col = 'b';
            xyz = 0;  kind = 'v';  cat = 3;
         case 'Vr'
            tit = sprintf('Kappl Velocity Magnitude (vmax = %g mm/s)',round(max(y)));    
            ylab = 'v [mm/s]';  col = 'b'; xyz = 0;  kind = 'v';  cat = 3;
            
         case 'V1'
            tit = 'Cutting Velocity 1';  ylab = 'v1 [mm/s]';  col = 'b';
            xyz = 0;  kind = 'v';  cat = 1;  specs = opt(o,{'specs.v',[]});
         case 'V2'
            tit = 'Normal Velocity 2';  ylab = 'v2 [mm/s]';  col = 'b';
            xyz = 0;  kind = 'v';  cat = 1;  specs = opt(o,{'specs.v',[]});
         case 'V3'
            tit = 'Normal Velocity 3';  ylab = 'v3 [mm/s]';  col = 'b';
            xyz = 0;  kind = 'v';  cat = 1;  specs = opt(o,{'specs.v',[]});
         case 'V'
            tit = sprintf('Process Velocity Magnitude (vmax = %g mm/s)',round(max(y)));    
            ylab = 'v [mm/s]';  col = 'b'; xyz = 0;  kind = 'v';  cat = 3;
            specs = opt(o,{'specs.v',[]});
            
            
         case 'Sx'
            tit = 'Kapp Elongation X';    ylab = 'sx [um]';  col = 'g';
            xyz = 0;  kind = 's';  cat = 5;
         case 'Sy'
            tit = 'Kappl Elongation Y';    ylab = 'sy [um]';  col = 'g';
            xyz = 0;  kind = 's';  cat = 5;
         case 'Sz'
            tit = 'Kappl Elongation Z';    ylab = 'sz [um]';  col = 'g';
            xyz = 0;  kind = 's';  cat = 5;
         case 'Sr'
            tit = sprintf('Kappl Elongation Magnitude (smax = %g um)',round(max(y)));    
            ylab = 's [um]';  col = 'g'; xyz = 0;  kind = 's';  cat = 5;

            
         case 'S1'
            tit = 'Cutting Elongation 1';  ylab = 's1 [um]';  col = 'g';
            xyz = 0;  kind = 's';  cat = 5;  specs = opt(o,{'specs.s',[]});
         case 'S2'
            tit = 'Normal Elongation 2';  ylab = 's2 [um]';  col = 'g';
            xyz = 0;  kind = 's';  cat = 5;  specs = opt(o,{'specs.s',[]});
         case 'S3'
            tit = 'Normal Elongation 3';  ylab = 's3 [um]';  col = 'g';
            xyz = 0;  kind = 's';  cat = 5;  specs = opt(o,{'specs.s',[]});
         case 'S'
            tit = sprintf('Process Elongation Magnitude (smax = %g um)',round(max(y)));    
            ylab = 's [um]';  col = 'b'; xyz = 0;  kind = 's';  cat = 5;
            specs = opt(o,{'specs.s',[]});
              
            
         case 'Axy'
            tit = 'Kappl Acceleration X/Y-Orbit'; 
            xlab = 'ax [g]';     ylab = 'ay [g]';     col = 'rry';
            xyz = 1;  kind = 'A';  cat = 1;
         case 'Axz'
            tit = 'Kappl Acceleration X/Z-Orbit'; 
            xlab = 'ax [g]';     ylab = 'az [g]';     col = 'rry';
            xyz = 1;  kind = 'A';  cat = 1;
         case 'Azy'
            tit = 'Kappl Acceleration Z/Y-Orbit'; 
            xlab = 'az [g]';     ylab = 'ay [g]';     col = 'rry';
            xyz = 1;  kind = 'A';  cat = 1;

         case 'Bxy'
            tit = 'Kolben Acceleration X/Y-Orbit'; 
            xlab = 'bx [g]';     ylab = 'by [g]';     col = 'rrky';
            xyz = 1;  kind = 'B';  cat = 1;
         case 'Bxz'
            tit = 'Kolben Acceleration X/Z-Orbit'; 
            xlab = 'bx [g]';     ylab = 'bz [g]';     col = 'rrky';
            xyz = 1;  kind = 'B';  cat = 1;
         case 'Bzy'
            tit = 'Kolben Acceleration Z/Y-Orbit'; 
            xlab = 'bz [g]';     ylab = 'by [g]';     col = 'rrky';
            xyz = 1;  kind = 'B';  cat = 1;
            
            
         case 'A12'
            tit = 'Cut-Cross Acceleration 1-2 Orbit'; 
            xlab = 'a1 [g]';     ylab = 'a2 [g]';     col = 'r';
            xyz = 1;  kind = 'A';  cat = 1;
         case 'A13'
            tit = 'Cut-Normal Acceleration 1-3 Orbit'; 
            xlab = 'a1 [g]';     ylab = 'a3 [g]';     col = 'r';
            xyz = 1;  kind = 'A';  cat = 1;
         case 'A23'
            tit = 'Normal-Cross Acceleration 3-1 Orbit'; 
            xlab = 'a2 [g]';     ylab = 'a3 [g]';     col = 'r';
            xyz = 1;  kind = 'A';  cat = 1;
         case 'A31'
            tit = 'Normal-Cross Acceleration 3-1 Orbit'; 
            xlab = 'a3 [g]';     ylab = 'a1 [g]';     col = 'r';
            xyz = 1;  kind = 'A';  cat = 1;
         case 'A32'
            tit = 'Normal-Cross Acceleration 3-2 Orbit'; 
            xlab = 'a3 [g]';     ylab = 'a2 [g]';     col = 'r';
            xyz = 1;  kind = 'A';  cat = 1;
            
            
         case 'AXY'
            x0 = mean(x);  y0 = mean(y);
            amax = round(sqrt(max((x-x0).^2+(y-y0).^2)));
            tit = o.iif(sub(3)==1,epilog,sprintf('amax = %g g',amax)); 
            epilog = '';
            xlab = 'ax [g]';     ylab = 'ay [g]';     col = 'r';
            xyz = 1;  kind = 'A';  cat = 1;

         case 'Vxy'
            tit = 'Kappl Velocity X/Y-Orbit'; 
            xlab = 'vx [mm/s]';  ylab = 'vy [mm/s]';  col = 'b';
            xyz = 1;  kind = 'V';  cat = 3;
         case 'Vxz'
            tit = 'Kappl Velocity X/Z-Orbit'; 
            xlab = 'vx [mm/s]';  ylab = 'vz [mm/s]';  col = 'b';
            xyz = 1;  kind = 'V';  cat = 3;
         case 'Vzy'
            tit = 'Kappl Velocity Z/Y-Orbit'; 
            xlab = 'vz [mm/s]';  ylab = 'vy [mm/s]';  col = 'b';
            xyz = 1;  kind = 'V';  cat = 3;

         case 'V12'
            tit = 'Process Velocity 1/2-Orbit'; 
            xlab = 'v1 [mm/s]';  ylab = 'v2 [mm/s]';  col = 'b';
            xyz = 1;  kind = 'V';  cat = 3;
         case 'V13'
            tit = 'Process Velocity 1/3-Orbit'; 
            xlab = 'v1 [mm/s]';  ylab = 'v3 [mm/s]';  col = 'b';
            xyz = 1;  kind = 'V';  cat = 3;
         case 'V23'
            tit = 'Process Velocity 2/3-Orbit'; 
            xlab = 'v2 [mm/s]';  ylab = 'v3 [mm/s]';  col = 'b';
            xyz = 1;  kind = 'V';  cat = 3;
         case 'V32'
            tit = 'Process Velocity 3/2-Orbit'; 
            xlab = 'v3 [mm/s]';  ylab = 'v2 [mm/s]';  col = 'b';
            xyz = 1;  kind = 'V';  cat = 3;
            
            
            
         case 'VXY'
            x0 = mean(x);  y0 = mean(y);
            vmax = round(sqrt(max((x-x0).^2+(y-y0).^2)));
            tit = o.iif(sub(3)==1,epilog,sprintf('vmax = %g mm/s',vmax)); 
            epilog = '';
            xlab = 'vx [mm/s]';  ylab = 'vy [mm/s]';  col = 'b';
            xyz = 1;  kind = 'V';  cat = 3;

         case 'Sxy'
            tit = 'Kappl Elongation Orbit'; 
            xlab = 'sx [um]';    ylab = 'sy [um]';    col = 'g';
            xyz = 1;  kind = 'S';  cat = 5;
         case 'SXY'
            x0 = mean(x);  y0 = mean(y);
            smax = round(sqrt(max((x-x0).^2+(y-y0).^2)));
            tit = o.iif(sub(3)==1,epilog,sprintf('smax = %g um',smax)); 
            epilog = '';
            xlab = 'sx [um]';    ylab = 'sy [um]';    col = 'g';
            xyz = 1;  kind = 'S';  cat = 5;
            
         case 'S12'
            tit = 'Process Elongation Orbit'; 
            xlab = 's1 [um]';    ylab = 's2 [um]';    col = 'g';
            xyz = 1;  kind = 'S';  cat = 5;            
         case 'S13'
            tit = 'Process Elongation Orbit'; 
            xlab = 's1 [um]';    ylab = 's3 [um]';    col = 'g';
            xyz = 1;  kind = 'S';  cat = 5;            
         case 'S23'
            tit = 'Process Elongation Orbit'; 
            xlab = 's2 [um]';    ylab = 's3 [um]';    col = 'g';
            xyz = 1;  kind = 'S';  cat = 5;            
         case 'S32'
            tit = 'Process Elongation Orbit'; 
            xlab = 's3 [um]';    ylab = 's2 [um]';    col = 'g';
            xyz = 1;  kind = 'S';  cat = 5;            

      end
      o = opt(o,'kind',kind);
   end
   function Plot(o)                    % Actual Plotting               
      is = @isequal;                   % short hand
      fm = opt(o,{'ffilter.mode','raw'});
      subplot(sub(1),sub(2),sub(3));
      
         % plot normal signal
         
      if is(fm,'raw') || is(fm,'both')
         o.color(plot(x,y),col,lw);
         hold on;
      end
      
         % eventually plot facette filtered signal

      if is(fm,'filter') || is(fm,'both')
         of = with(o,'ffilter');       % unpack filter options
         yf = filter(of,abs(y),x);
         plot(x,yf,'c');
      end
     
         % set background color and grid

      set(gca,'color',o.iif(dark(o),0,1)*[1 1 1]);
      grid(o);
      dark(o,'Axes');
   end
   function Labels(o)                  % Provide Labels                
      metrics = opt(o,{'metrics',1});
      
      dot = o.iif(dark(o),'k.','w.');  % dot color
      mini = min(min(x),min(y));
      maxi = max(max(x),max(y));
      lim = max(abs(mini),abs(maxi));

      if (xyz)
         xlabel(xlab);
         set(gca,'DataAspectratio',[1 1 1]);
         maxi = max(max(abs(x)),max(abs(y)))+0.1;
         hold on;
         plot(maxi*[-1 1],maxi*[-1 1],dot);

         xlim = get(gca,'xlim');  ylim = get(gca,'ylim');
         lim = max(max(abs(xlim)),max(abs(ylim)));
         set(gca,'xlim',[-lim lim],'ylim',[-lim lim]);
      else
         set(gca,'xlim',[min(x),max(x)]);
      end
      ylabel(ylab);
  
         % epilog

      epilog = '';
      if metrics && isequal(kind,'a')
         [cpks,cpkw,mgrs,mgrw] = cpk(o,kind);
         if (opt(o,{'spec.mode',1}) <= 1)
            Cpk = cpks;  Mgr = mgrs;
         else
            Cpk = cpkw;  Mgr = mgrw;
         end

         epilog = sprintf(' (Mgr = %g, Cpk = %g)',o.rd(Mgr,2), o.rd(Cpk,2));
      end

      if ~isempty(epilog)
         title([tit,' ',epilog]);
      else
         title(tit);
      end
   end
end
