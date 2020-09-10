function oo = gplot(o,mode,idx,az_el)
% 
% GPLOT   General plot routine for data analysis of a DANA object
%
%    Syntax:
%       Correction matrix X,Y:
%       plot(o,'pcorrx',idx)    % pickup x-correction surfplot
%       plot(o,'pcorry',idx)    % pickup y-correction surfplot
%       plot(o,'rcorrx',idx)    % residual x-correction surfplot
%       plot(o,'rcorry',idx)    % residual y-correction surfplot
% 
%       plot(o,'frcorrx',idx)   % filtered residual x-correction surfplot
%       plot(o,'frcorry',idx)   % filtered residual y-correction surfplot
%       plot(o,'rnoisex',idx)   % residual x-noise surfplot
%       plot(o,'rnoisey',idx)   % residual y-noise surfplot
% 
%       plot(o,'adatax',idx)    % axis data x-surfplot
%       plot(o,'adatay',idx)    % axis data y-surfplot
%       plot(o,'fadatax',idx)   % filtered axis data x-surfplot
%       plot(o,'fadatay',idx)   % filtered axis data y-surfplot
%       plot(o,'anoisex',idx)   % axis noise x-surfplot
%       plot(o,'anoisey',idx)   % axis noise y-surfplot
% 
%       plot(o,'sdriftx',{idx,iref})   % surfplot of drift x-data
%       plot(o,'sdrifty',{idx,iref})   % surfplot of drift y-data
%       plot(o,'rdriftx',{idx,iref})   % surfplot of residual drift x-data
%       plot(o,'rdrifty',{idx,iref})   % surfplot of residual drift y-data
% 
%       plot(o,'fdriftx',{idx,iref})   % surfplot of filtered drift x-data
%       plot(o,'fdrifty',{idx,iref})   % surfplot of filtered drift y-data
%       plot(o,'dnoisex',{idx,iref})   % surfplot of x-drift noise
%       plot(o,'dnoisey',{idx,iref})   % surfplot of y-drift noise
% 
%       plot(o,'ballplot',{idx,iref}) % ballplot of drift data
%       plot(o,'histogram',{idx,iref})% histogram plot of drift data
% 
%       plot(o,'tdriftx')       % time drift x
%       plot(o,'tdrifty')       % time drift y
%       plot(o,'tdriftr')       % time drift r
% 
%       plot(o,'temp',idx)      % temperature over time
%
%    See also   DANA, TDMOBJ, VIEW
%
   oo = current(o);                    % get current object
   
   bias = opt(oo,'mode.bias');      
   oo = opt(oo,'bias',bias);           % translate bias mode for COOK
   
   if (nargin < 4)
      [az,el] = view; 
      az_el = [az,el];                 % azimuth and elongation
   end
   
   oo = opt(oo,'view.azel',az_el);     % store in option

   switch mode
      case {'adatax','adatay','fadatax','fadatay','anoisex','anoisey'}
         Gplot1(oo,mode,idx);
      otherwise
         Gplot(oo,mode,idx,az_el);
   end
end

%==========================================================================
% Specific Plot Routines
%==========================================================================

function o = Gplot1(o,mode,idx)
%
% GPLOT1   General plot routine 1 which supports the following modes
%
%             'pcorrx'
%             'pcorry'
%             'rcorrx'
%             'rcorry'
%             'frcorrx'
%             'frcorry'
%             'rnoisex'
%             'rnoisey'
%             'adatax'
%             'adatay'
%             'fadatax'
%             'fadatay'
%             'anoisex'
%             'anoisey'
%             'vdriftx'
%             'vdrifty'
%             'vadriftx'
%             'vadrifty'
%
   is = @bazaar.is;                    % need some utility
   dat = data(o);

   az_el = opt(o,'view.azel');
   filter = opt(o,'filter');
   
   if nargin < 3
      idx = 1:length(dat.xy);
   end

   iref = 1;  filtermode = [];  % default
   if iscell(idx)
      if (length(idx) >= 2), iref = idx{2}; end
      if (length(idx) >= 3), filtermode = idx{3}; end
      if (length(idx) >= 4), calcmode = idx{4}; end
      idx = idx{1};
   end

      % calculate min and max z
      
   switch mode
      case {'vdriftx','vdrifty'}
         [Mx,My] = odata(o,{idx});
      case {'vadriftx','vadrifty'}
         co = 1;
         [Mx,My] = odata(o,{idx},filtermode,co);
      case {'pcorrx','pcorry'}
         [Mx,My] = cdata(o,{idx});
      case {'rcorrx','rcorry'}
         [Mx,My] = rdata(o,{idx});
         T = tqk(o,{idx});
      case {'frcorrx','frcorry'}
         [Rx,Ry] = rdata(o,{idx});
         Mx=cell(1,length(Rx)); My=cell(1,length(Rx));
         for i=1:length(Rx),
            Mx{i} = twodfilt(Rx{i},filtermode);
            My{i} = twodfilt(Ry{i},filtermode);
         end
         T = tqk(o,{idx});
      case {'rnoisex','rnoisey'}
         [Rx,Ry] = rdata(o,{idx});
         Mx=cell(1,length(Rx)); My=cell(1,length(Rx));
         for i=1:length(Rx),
            Mx{i} = Rx{i}-twodfilt(Rx{i},filtermode);
            My{i} = Ry{i}-twodfilt(Ry{i},filtermode);
         end
      case {'adatax','adatay'}
         o = opt(o,'bias','absolute');  % use absolute bias for COOK
         [Kx,Ky] = kdata(o,{idx});
         [Ax,Ay] = adata(o,{idx});
         Mx=cell(1,length(Ax)); My=cell(1,length(Ax));
         for i=1:length(Ax),
            ax = Ax{i};  ay = Ay{i};
            Mx{i} = ax-Kx{i}-ax(1,1);
            My{i} = ay-Ky{i}-ay(1,1);
         end
      case {'fadatax','fadatay'}
         [Kx,Ky] = kdata(o,{idx});

         if(calcmode==1)
            o = opt(o,'bias','absolute');  % use absolute bias for COOK
            filtmode = [filter.type filter.window];
            [Ax,Ay] = adata(o,{idx});
             for i=1:length(Ax),
               ax = Ax{i};  ay = Ay{i};
               Mx{i} = ax-Kx{i}-ax(1,1);
               My{i} = ay-Ky{i}-ay(1,1);
               Mx{i} = twodfilt(Mx{i},filtermode);
               My{i} = twodfilt(My{i},filtermode);
            end
         elseif(calcmode==2)
            [Acalcx,Acalcy] = acalc(o,{idx},calcmode,filtermode);
            Mx=cell(1,length(Acalcx)); My=cell(1,length(Acalcx));
            for i=1:length(Acalcx),
               ax = Acalcx{i};  ay = Acalcy{i};
               Mx{i} = ax-Kx{i}-ax(1,1);
               My{i} = ay-Ky{i}-ay(1,1);
            end
         end
      case {'anoisex','anoisey'}
         if(calcmode==1)
            o = opt(o,'bias','absolute');  % use absolute bias for COOK
            filtmode = [filter.type filter.window];
            [Ax,Ay] = adata(o,{idx});
            for i=1:length(Ax),
               Mx{i} = Ax{i}-twodfilt(Ax{i},filtmode);
               My{i} = Ay{i}-twodfilt(Ay{i},filtmode);
            end
         elseif(calcmode==2)
            [Acalcx,Acalcy] = acalc(o,{idx},calcmode,filtermode);
            Mx=cell(1,length(Acalcx)); My=cell(1,length(Acalcx));
            for i=1:length(Acalcx),
               Mx{i} = Acalcx{i}-twodfilt(Acalcx{i},filtermode);
               My{i} = Acalcy{i}-twodfilt(Acalcy{i},filtermode);
            end
         end
   end % switch

   mincx = inf; maxcx = -inf;
   mincy = inf; maxcy = -inf;
   for i=1:length(idx),
      mincx = min(mincx,min(min(Mx{i})));
      maxcx = max(maxcx,max(max(Mx{i})));
      mincy = min(mincy,min(min(My{i})));
      maxcy = max(maxcy,max(max(My{i})));
   end

   [Kx,Ky] = kdata(o,{idx});

   for i=1:length(idx),
      cls(o);
      hold off;
      switch mode
         case {'vdriftx','vadriftx'}
            surf(Mx{i});  tail = 'X';
            hold on
            line(0,0,mincx);  line(0,0,maxcx);
         case {'vdrifty','vadrifty'}
            surf(My{i});  tail = 'Y';
            hold on
            line(0,0,mincy);  line(0,0,maxcy);
         case {'pcorrx','rcorrx','frcorrx','rnoisex',...
                        'adatax','fadatax','anoisex'}
            surf(Kx{i}/1000,Ky{i}/1000,Mx{i});  tail = 'X';
            hold on
            line(0,0,mincx);  line(0,0,maxcx);
         case {'pcorry','rcorry','frcorry','rnoisey',...
                        'adatay','fadatay','anoisey'}
            surf(Kx{i}/1000,Ky{i}/1000,My{i});  tail = 'Y';
            hold on
            line(0,0,mincy);  line(0,0,maxcy);
         otherwise
            error('bad mode!');
      end

      if ( count(o) > 1 ), tail = sprintf([tail,'(%g)'],idx(i)); end

      if is(mode,{'vdriftx','vdrifty'})
         title(['Pickup Coordinates: Virtual Drift ',tail]);
      elseif is(mode,{'vadriftx','vadrifty'})
         title(['Axis Coordinates: Virtual Drift ',tail]);
      elseif is(mode,{'pcorrx','pcorry'})
         title(['Pickup Correction ',tail]);
      elseif is(mode,{'rcorrx','rcorry'})
         title(['Residual Correction ',tail]);
      elseif is(mode,{'fpcorrx','fpcorry'})
         title(['Filtered Pickup Correction ',tail]);
      elseif is(mode,{'rnoisex','rnoisey'})
         title(['Residual Noise ',tail]);
      elseif is(mode,{'adatax','adatay'})
         title(['Axis Data ',tail]);
      elseif is(mode,{'fadatax','fadatay'})
         title(['Filtered Axis Data ',tail]);
      elseif is(mode,{'anoisex','anoisey'})
         title(['Axis Noise ',tail]);
      end

      kx = Kx{i};  ky = Ky{i};
      pts = points(o);
      dst = distance(o);
      set(gca,'ydir','reverse');
      set(gca,'fontsize',8)
      if ( pts(1) <= 10 ), set(gca,'xtick',kx(1,:)/1000); end
      if ( pts(1) <= 10 ), set(gca,'ytick',ky(:,1)/1000); end
      xlabel(sprintf('X: %g points [%g mm]',pts(1),dst(1)/1000));
      ylabel(sprintf('Y: %g points [%g mm]',pts(2),dst(2)/1000));

      M = vset(Mx{i},My{i});
      if is(mode,{'pcorrx','pcorry','fpcorrx','fpcorry','offsetx','offsety'})
         NormalLegend('Deviations:',M)
      elseif is(mode,{'rcorrx','rcorry','frcorrx','frcorry'})
         ResidualLegend(o,M,T{i})
      elseif is(mode,{'rnoisex','rnoisey','anoisex','anoisey'})
         NormalLegend('Noise:',M)
      end

      %figure(danaFigure('danaMenuFigure')); % figure(gcf);   % shg
      shg;
      if length(idx) > 1
         pause
      end
   end
end

%==========================================================================
% General Gplot Function - Handles Anything Else
%==========================================================================

function Gplot(o,mode,idx,az_el)       % General Plot Routine          
%
   is = @bazaar.is;                    % need some utility
   dat = o.data;

% set(gcf,'Name',machine(o));
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   while is(mode,{'sdriftxymovie','rdriftxymovie'})

      if strcmp(property(o,'kind'),'CAP')
           topic = 'Error';
      else
           topic = 'Drift';
      end

       iref = 1;  filtermode = [];  % default
       if iscell(idx)
          if (length(idx) >= 2), iref = idx{2}; end
          if (length(idx) >= 3), filtermode = idx{3}; end
          idx=1:count(o);    
       end

       [Kx,Ky] = bdata(o,{idx});
       [Dx,Dy] = ddata(o,{idx},iref);            


       %sets matrix size (global variables in matrix function)
       pts = points(o,count(o));
       matrix(pts([2 1]));

       view(2);

       R=cell(1,length(idx));
       for i=1:length(idx)
           clrscr;
           hold off;

           % drift
           Mx = Dx{i};  My = Dy{i};        

           if strcmp(mode,'rdriftxymovie')
           % residual drift
               R{i} = resi(vset(Kx{i},Ky{i}),vset(Dx{i},Dy{i}));          
               [Mx,My] = matrix(R{i});
           end

           %vectorplot mit skalierfactor 0.7
           quiver(Kx{i}/1000,Ky{i}/1000,Mx,My,0.0); 
           set(gca,'ydir','reverse');shg
   %         tail = 'XY';
   %         
   %         if count(o) > 1
   %             tail = sprintf([tail,'(%g)'],idx(i));
   %         end    

           %title
           if is(mode,{'sdriftxymovie'})
              title(sprintf([topic,' Matrix XY(%g)'],idx(i)));
           elseif is(mode,{'rdriftxymovie'})
              title(sprintf(['Residual ',topic,' Matrix XY(%g)'],idx(i)));
           end

           %xlabel,ylabel
         kx = Kx{i};  ky = Ky{i};
         pts = points(o);
         dst = distance(o);
         set(gca,'fontsize',8)
         if ( pts(1) <= 10 ), set(gca,'xtick',kx(1,:)/1000); end
         if ( pts(1) <= 10 ), set(gca,'ytick',ky(:,1)/1000); end
         xlabel(sprintf('X: %g points [%g mm]',pts(1),dst(1)/1000));
         ylabel(sprintf('Y: %g points [%g mm]',pts(2),dst(2)/1000));

           %legende
           M = vset(Mx,My);
           NormalLegend('Deviations:',M)

           figure(danaFigure('danaMenuFigure')); % figure(gcf);
           if length(idx) > 1
              pause(0.5)
           end
       end
       return
   end
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% vectorplots of drift and residual drift
   while is(mode,{'sdriftxy','rdriftxy'})

      if nargin < 3
           idx = 1:count(o);
      end

      if strcmp(property(o,'kind'),'CAP')
           topic = 'Error';
      else
           topic = 'Drift';
      end

       iref = 1;  filtermode = [];  % default
       if iscell(idx)
          if (length(idx) >= 2), iref = idx{2}; end
          if (length(idx) >= 3), filtermode = idx{3}; end
          idx = idx{1};
       end

       [Kx,Ky] = bdata(o,{idx});
       [Dx,Dy] = ddata(o,{idx},iref);

       %sets matrix size (global variables in matrix function)
       pts = points(o,count(o));
       matrix(pts([2 1]));

       view(2);

       R=cell(1,length(idx));
       for i=1:length(idx)
           clrscr;
           hold off;

           % drift
           Mx = Dx{i};  My = Dy{i};        

           if strcmp(mode,'rdriftxy')
           % residual drift
               R{i} = resi(vset(Kx{i},Ky{i}),vset(Dx{i},Dy{i}));          
               [Mx,My] = matrix(R{i});
           end

           %vectorplot mit skalierfactor 0.7
           quiver(Kx{i}/1000,Ky{i}/1000,Mx,My,0.0); 
           set(gca,'ydir','reverse');shg
           hold on
   %         tail = 'XY';
   %         
   %         if count(o) > 1
   %             tail = sprintf([tail,'(%g)'],idx(i));
   %         end    

           %title
           if is(mode,{'sdriftxy'})
              title(sprintf([topic,' Matrix XY(%g)'],idx(i)));
           elseif is(mode,{'rdriftxy'})
              title(sprintf(['Residual ',topic,' Matrix XY(%g)'],idx(i)));
           end

           %xlabel,ylabel
         kx = Kx{i};  ky = Ky{i};
         pts = points(o);
         dst = distance(o);
         set(gca,'fontsize',8)
         if ( pts(1) <= 10 ), set(gca,'xtick',kx(1,:)/1000); end
         if ( pts(1) <= 10 ), set(gca,'ytick',ky(:,1)/1000); end
         xlabel(sprintf('X: %g points [%g mm]',pts(1),dst(1)/1000));
         ylabel(sprintf('Y: %g points [%g mm]',pts(2),dst(2)/1000));

           %legende
           M = vset(Mx,My);
           NormalLegend('Deviations:',M)

           figure(danaFigure('danaMenuFigure')); % figure(gcf);
           if length(idx) > 1
              pause
           end
      end
      return
   end
   
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% vectorplots of pickup correction and residual correction
   while is(mode,{'pcorrxy','rcorrxy'})

      if nargin < 3
           idx = 1:length(dat.xy);
      end

       %den richtigen index setzen
      if iscell(idx)
           idx = idx{1};
      end

      if is(mode,{'pcorrxy'})
           %pickup correctur matrix
           [Mx,My] = cdata(o,{idx});    
      elseif is(mode,{'rcorrxy'})
           %residuale correctur matrix
           [Mx,My] = rdata(o,{idx});
      end

       [Kx,Ky] = kdata(o,{idx});    

      for i=1:length(idx),
           clrscr;
           hold off;

           %vectorplot mit skalierfactor 0.7
           quiver(Kx{i}/1000,Ky{i}/1000,Mx{i},My{i},0.7); 
           set(gca,'ydir','reverse');shg
           hold on
           tail = 'XY';

           if count(o) > 1
               tail = sprintf([tail,'(%g)'],idx(i));
           end    

           %title
           if is(mode,{'pcorrxy'})
              title(['Pickup Correction ',tail]);
           elseif is(mode,{'rcorrxy'})
              title(['Residual Correction ',tail]);             
           end

           %xlabel,ylabel
         kx = Kx{i};  ky = Ky{i};
         pts = points(o);
         dst = distance(o);
         set(gca,'fontsize',8)
         if ( pts(1) <= 10 ), set(gca,'xtick',kx(1,:)/1000); end
         if ( pts(1) <= 10 ), set(gca,'ytick',ky(:,1)/1000); end
         xlabel(sprintf('X: %g points [%g mm]',pts(1),dst(1)/1000));
         ylabel(sprintf('Y: %g points [%g mm]',pts(2),dst(2)/1000));

           %legende
           M = vset(Mx{i},My{i});
           NormalLegend('Deviations:',M)
      end
      return
   end
    
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% standard deviation of time residual of axis data, calculates residuum of filtered axis trajectories
   while is(mode,{'timres'})
      [rtx,rty]=restime(o);  %spalte beschreibt zeitl. verlauf eines punktes
      sx=std(rtx);
      sy=std(rty);
   	s=vset(sx,sy);
   
      sz = dim(o);
      [sxm,sym]=matrix(s, sz);
   
      if ( nargin < 4 ) 
         az_el = [30 30];
      end
     
		clrscr;
		subplot(2,1,1);
      
      txt1 = sprintf('smax: %3.2g [um]',max(sxm(:)));
      txt2 = sprintf('smin: %3.2g [um]',min(sxm(:)));
      txt3 = sprintf('smean: %3.2g [um]',mean(sxm(:)));
      
      surf(sxm);
      view(az_el);
		set(gca,'ydir','reverse');
		title('X Standard Deviation Of Time Residual [um]');	
		xlabel('X');
		ylabel('Y');
		textbox(txt1,txt2,txt3);
	      
		subplot(2,1,2);
      
		txt1 = sprintf('smax: %3.2g [um]',max(sym(:)));
      txt2 = sprintf('smin: %3.2g [um]',min(sym(:)));
      txt3 = sprintf('smean: %3.2g [um]',mean(sym(:)));
      
      surf(sym);
      view(az_el);
		set(gca,'ydir','reverse');
		title('Y Standard Deviation Of Time Residual [um]');	
		xlabel('X');
		ylabel('Y');
		textbox(txt1,txt2,txt3);
		shg;      
   	return
	end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Residuum of linear compensated axis coordinates over time
	while is(mode,{'vdriftxt','vdriftyt','vadriftxt','vadriftyt'})
   
	   if is(mode,{'vdriftxt','vdriftyt'})
         [ox,oy]=odata(o);		      
      elseif is(mode,{'vadriftxt','vadriftyt'})
         if (length(idx) >= 3), filter = idx{3}; end
         ix=1:count(o);
         co=1;
         [ox,oy]=odata(o,ix,filter,co);		      
      end
      
      [m,n]=size(ox{1});
     	tt=time(o);
      t=[];
      xlihi=NaN(1,count(o)); xrehi=NaN(1,count(o));
      xlivo=NaN(1,count(o)); xrevo=NaN(1,count(o));
      xmit=NaN(1,count(o));
      ylihi=NaN(1,count(o)); yrehi=NaN(1,count(o));
      ylivo=NaN(1,count(o)); yrevo=NaN(1,count(o));
      ymit=NaN(1,count(o));
      oxhelp=NaN(count(o),m*n); oyhelp=NaN(count(o),m*n);
      for i=1:count(o)
         t=[t,tt{i}];
         xlihi(i)=ox{i}(1,1);
         xrehi(i)=ox{i}(1,n);
         xlivo(i)=ox{i}(m,1);
         xrevo(i)=ox{i}(m,n);
         xmit(i)=ox{i}(floor(m/2),floor(n/2));
         ylihi(i)=oy{i}(1,1);
         yrehi(i)=oy{i}(1,n);
         ylivo(i)=oy{i}(m,1);
         yrevo(i)=oy{i}(m,n);
         ymit(i)=oy{i}(floor(m/2),floor(n/2));
         oxhelp(i,:)=ox{i}(:)';
         oyhelp(i,:)=oy{i}(:)';
      end
      
      t=t/60;
      
      clrscr;
      
		  if is(mode,{'vdriftxt','vadriftxt'})
%          plot(t,drift(ox));
%          hold on;
%          plot(t,drift(xlihi),'b','linewidth',3);
%          plot(t,drift(xlivo),'g','linewidth',3);
%          plot(t,drift(xrehi),'r','linewidth',3);
%          plot(t,drift(xrevo),'y','linewidth',3);
%          plot(t,drift(xmit),'k','linewidth',3);
%          hold off; 

            plot(t,oxhelp);
            hold on;
            plot(t,xlihi,'b','linewidth',3);
            plot(t,xlivo,'g','linewidth',3);
            plot(t,xrehi,'r','linewidth',3);
            plot(t,xrevo,'y','linewidth',3);
            plot(t,xmit,'k','linewidth',3);
            hold off; 




         if is(mode,{'vdriftxt'})
            title('Pickup Coordinates: Virtual X-Drift over time');
         else
            title('Axis Coordinates: Virtual X-Drift over time');
         end
         
         xlabel('time [min]');
         ylabel('Virtual X-Drift [um]');
         textbox('b...lihi','g...livo','r...rehi','y...revo','k...mitte',-1);
         shg
      elseif is(mode,{'vdriftyt','vadriftyt'})
%          plot(t,drift(oy));
%          hold on;
%          plot(t,drift(ylihi),'b','linewidth',3);
%          plot(t,drift(ylivo),'g','linewidth',3);
%          plot(t,drift(yrehi),'r','linewidth',3);
%          plot(t,drift(yrevo),'y','linewidth',3);
%          plot(t,drift(ymit),'k','linewidth',3);
%          hold off;         
         
            plot(t,oyhelp);
            hold on;
            plot(t,ylihi,'b','linewidth',3);
            plot(t,ylivo,'g','linewidth',3);
            plot(t,yrehi,'r','linewidth',3);
            plot(t,yrevo,'y','linewidth',3);
            plot(t,ymit,'k','linewidth',3);
            hold off; 
         
         
         if is(mode,{'vdriftyt'})
            title('Pickup Coordinates: Virtual Y-Drift over time');
         else
            title('Axis Coordinates: Virtual Y-Drift over time');
         end
            
         xlabel('time [min]');
         ylabel('Virtual Y-Drift [um]');
         textbox('b...lihi','g...livo','r...rehi','y...revo','k...mitte',-1);
         shg;
      end
   	return;
	end

   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Residuum of linear compensated axis coordinates over time
   while is(mode,{'chcomp'})
      [kx,ky,sh,alfa,sx,sy,rx,ry,Trafo,qx,qy,aax,aay,t]=deformation(o);
      
		%vier ecken und mitte gesondert
		mn=dim(o,1);
      anzahl = count(o);
      
		m=mn(1);
		n=mn(2);
      pq=cell(1,anzahl); pa=cell(1,anzahl);
      for i=1:anzahl
         pq{i}=[qx(:,i)';qy(:,i)'];
         pa{i}=[aax(:,i)';aay(:,i)'];
      end
      
		xmit=NaN(anzahl,1); % xmit=[];
		ymit=NaN(anzahl,1); % ymit=[];

      ax=cell(1,anzahl); ay=cell(1,anzahl);
      x=cell(1,anzahl); y=cell(1,anzahl);
		for i=1:anzahl
         [ax{i},ay{i}]=matrix(pa{i},[m n]);
   		[x{i},y{i}]=matrix(pq{i},[m n]);
	   	xmit(i)=ax{i}(floor(m/2),floor(n/2))-x{i}(floor(m/2),floor(n/2));
   		ymit(i)=ay{i}(floor(m/2),floor(n/2))-y{i}(floor(m/2),floor(n/2));
		end
      
      
      subplot(2,1,1);
      
      plot(t,aax'-qx');
      hold on;
      plot(t,xmit,'k','linewidth',3);
      hold off;
      title('Residuum of linear compensated axis coordinates');
      xlabel('time [min]');
      ylabel('X [um]');
      shg
   
      subplot(2,1,2);
      
      plot(t,aay'-qy');
      hold on;
		plot(t,ymit,'k','linewidth',3);
		hold off;      
      title('Residuum of linear compensated axis coordinates');
      xlabel('time [min]');
      ylabel('Y [um]');
      shg
      
      return;
   end
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% classification numbers (linear and nonlinear deformation) of axis coordinates (menu characteristics)
	while is(mode,{'chdef'})
      [kx,ky,sh,alfa,sx,sy,rx,ry,Trafo,qx,qy,aax,aay,t]=deformation(o);
      
      subplot(2,1,1);
      
      plot(t,kx,'r-o',t,ky,'g-o',t,sh,'b-o',t,alfa,'k-o');
      title('Linear Deformation Numbers Over Time');
      xlabel('time [min]');
      ylabel('scale and shear [um/dm]');
      legend('scalex','scaley','shear','rotation',0);
      shg
   
      subplot(2,1,2);
      
      plot(t,sx,'r-o',t,sy,'g-o',t,rx,'b-o',t,ry,'k-o');
      title('Nonlinear Deformation Numbers Over Time');
      xlabel('time [min]');
      ylabel('standard deviation and range [um]');
      legend('stdx','stdy','rx','ry',0);
      shg
   
		return;   
	end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%	nonlinear classification numbers of residual drift
	while is(mode,{'nlinsx','nlinsy','nlinrx','nlinry'})
        [sx,sy,rx,ry]=nonlinnumbers(o);
      
     	tt=time(o);
        t=[];
        for i=1:count(o)
            t=[t,tt{i}];
        end
      
        t=t/60;
      
        clrscr;
      
        if is(mode,{'nlinsx'})
            plot(t,sx,'-o');
            xlabel('time [min]');
            ylabel('Sigma X [um]');
            title('Standard Deviation of residual X-drift');
            shg;
        elseif  is(mode,{'nlinsy'})
            plot(t,sy,'-o');
            xlabel('time [min]');
            ylabel('Sigma Y [um]');
            title('Standard Deviation of residual Y-drift');
            shg;
        elseif is(mode,{'nlinrx'})
            plot(t,rx,'-o');
            xlabel('time [min]');
            ylabel('Range X [um]');
            title('Range of residual X-drift');
            shg;
        elseif is(mode,{'nlinry'})
            plot(t,ry,'-o');
            xlabel('time [min]');
            ylabel('Range Y [um]');
            title('Range of residual Y-drift');
            shg;
        end
      
   	return;
	end

 
   
% linear classification numbers of residual drift
	while is(mode,{'linscalex','linscaley','linshear'})
		[kx,ky,s]=linnumbers(o);    
     
        tt=time(o);
        t=[];
        for i=1:count(o)
            t=[t,tt{i}];
        end
      
        t=t/60;
      
  		clrscr;
        if is(mode,{'linscalex'})
            plot(t,kx,'-o');
            xlabel('time [min]');
            ylabel('Scale X [um/dm]');
            title('X scale of residual drift');
            shg;
        elseif  is(mode,{'linscaley'})
            plot(t,ky,'-o');
            xlabel('time [min]');
            ylabel('Scale Y [um/dm]');
            title('Y scale of residual drift');
            shg;
        else
            plot(t,s,'-o');
            xlabel('time [min]');
            ylabel('Shear [um/dm]');
            title('Shear of residual drift');
            shg;
        end
      return;
   end

   
	%%%%% evaluierung der drift %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   while is(mode,{'evdrift','evdriftmean','evdriftstd'})
      if ( nargin < 4 ) 
         az_el = [30 30];
      end
      
      d=evdrift(o);      
      
   	anzahl=count(o);
		n=floor(anzahl/2);
      
		%die 5 driften (pro zeile drift aller punkte)
		dx=NaN(n,size(d{1},2)); % dx=[];
		dy=NaN(n,size(d{1},2)); % dy=[];
		for i=1:n
   		dx(i,:)=d{i}(1,:);
   		dy(i,:)=d{i}(2,:);
		end

		%standardabweichung der drift f�r jeden punkt des kontrollaufes
		sdx=std(dx);
		sdy=std(dy);
   
   	sd=[sdx;sdy];
   	[sdxm, sdym]=matrix(sd,dim(o,1));
   
		%mittelwert der drift f�r jeden punkt des kontrollaufes
		mdx=mean(dx);
		mdy=mean(dy);
   
   	md=[mdx;mdy];
   	[mdxm, mdym]=matrix(md,dim(o,1));
   
		%spezifizierter 3sigma-wert f�r die temperaturdrift
		delta=4;
		cmkx=(delta-abs(mdx)) ./(3*sdx);
		cmky=(delta-abs(mdy)) ./(3*sdy);

		%cmk's als 2d-vektorset
		cmk=[cmkx;cmky];

		%cmk's als matrizen
      [cmkx,cmky]=matrix(cmk,dim(o,1));
      
		clrscr;
      subplot(2,1,1);
      
      if is(mode,{'evdrift'})
	      txt1 = sprintf('max: %3.2g [um]',max(cmkx(:)));
   	   txt2 = sprintf('min: %3.2g [um]',min(cmkx(:)));
      	txt3 = sprintf('mean: %3.2g [um]',mean(cmkx(:)));
         
         surf(cmkx);
         view(az_el);
			set(gca,'ydir','reverse');
			title('Cmk of X-Drifts');	
			xlabel('X');
      	ylabel('Y');
      	zlabel('Cmk X');
         textbox(txt1,txt2,txt3);
         
			subplot(2,1,2);
	      txt1 = sprintf('max: %3.2g',max(cmky(:)));
   	   txt2 = sprintf('min: %3.2g',min(cmky(:)));
      	txt3 = sprintf('mean: %3.2g',mean(cmky(:)));
      
         surf(cmky);
         view(az_el);
			set(gca,'ydir','reverse');
			title('Cmk of Y-Drifts');	
			xlabel('X');
      	ylabel('Y');
         zlabel('Cmk Y');
         textbox(txt1,txt2,txt3);
         
      elseif is(mode,{'evdriftmean'})
	      txt1 = sprintf('max: %3.2g [um]',max(mdxm(:)));
   	   txt2 = sprintf('min: %3.2g [um]',min(mdxm(:)));
      	txt3 = sprintf('mean: %3.2g [um]',mean(mdxm(:)));
         
         surf(mdxm);
         view(az_el);
			set(gca,'ydir','reverse');
			title('Mean Value of X-Drifts');	
			xlabel('X');
      	ylabel('Y');
      	zlabel('Mean X [um]');
         textbox(txt1,txt2,txt3);
         
			subplot(2,1,2);
	      txt1 = sprintf('max: %3.2g [um]',max(mdym(:)));
   	   txt2 = sprintf('min: %3.2g [um]',min(mdym(:)));
      	txt3 = sprintf('mean: %3.2g [um]',mean(mdym(:)));
      
         surf(mdym);
         view(az_el);
			set(gca,'ydir','reverse');
			title('Mean Value of Y-Drift');	
			xlabel('X');
      	ylabel('Y');
         zlabel('Mean Y [um]');
         textbox(txt1,txt2,txt3);
      elseif is(mode,{'evdriftstd'})
  	      txt1 = sprintf('max: %3.2g [um]',max(sdxm(:)));
   	   txt2 = sprintf('min: %3.2g [um]',min(sdxm(:)));
      	txt3 = sprintf('mean: %3.2g [um]',mean(sdxm(:)));

			surf(sdxm);
         view(az_el);
			set(gca,'ydir','reverse');
			title('Standard Deviation of X-Drifts');	
			xlabel('X');
      	ylabel('Y');
      	zlabel('Standard Dev X [um]');
         textbox(txt1,txt2,txt3);
	      
			subplot(2,1,2);
	      txt1 = sprintf('max: %3.2g [um]',max(sdym(:)));
   	   txt2 = sprintf('min: %3.2g [um]',min(sdym(:)));
      	txt3 = sprintf('mean: %3.2g [um]',mean(sdym(:)));
      
         surf(sdym);
         view(az_el);
			set(gca,'ydir','reverse');
			title('Standard Deviation of Y-Drifts');	
			xlabel('X');
      	ylabel('Y');
         zlabel('Standard Dev Y [um]');
         textbox(txt1,txt2,txt3);
      end
      
		shg;      
		return;      
   end
   
   %%%%% evaluierung der Wiederholgenauigkeit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   while is(mode,{'evrepeat'})
      if ( nargin < 4 ) 
         az_el = [30 30];
      end

      % where to calculate the repeatability: end of warmup or end of
      % cooldown
      flag = getud(12); 
      [sax,say] = evrepeat(o, flag);      
      
		clrscr;
		subplot(2,1,1);
      
      txt1 = sprintf('smax: %3.2g [um]',max(sax(:)));
      txt2 = sprintf('smin: %3.2g [um]',min(sax(:)));
      txt3 = sprintf('smean: %3.2g [um]',mean(sax(:)));
      
      surf(sax);
      view(az_el);
		set(gca,'ydir','reverse');
		title('X-Standardabweichungen [um]');	
		xlabel('X');
		ylabel('Y');
		textbox(txt1,txt2,txt3);
	      
		subplot(2,1,2);
      
		txt1 = sprintf('smax: %3.2g [um]',max(say(:)));
      txt2 = sprintf('smin: %3.2g [um]',min(say(:)));
      txt3 = sprintf('smean: %3.2g [um]',mean(say(:)));
      
      surf(say);
      view(az_el);
		set(gca,'ydir','reverse');
		title('Y-Standardabweichungen [um]');	
		xlabel('X');
		ylabel('Y');
		textbox(txt1,txt2,txt3);
		shg;      
		return;      
   end
   
   %%%%% zyklische drift der achkoordinaten ( = drift der achskoordinaten von kontrolllauf zu kontrolllauf) %%%%%%
   while is(mode,{'cycdrift'})
       
		da=dachs(o);
      nPointCount=size(da{1},2);
   
   	    dax=NaN(count(o)-1,nPointCount); % dax=[];
		    day=NaN(count(o)-1,nPointCount); % day=[];
        tim=[];
        timehelp=0;
   	    anzahl=count(o);
     
		for i=1:anzahl-1
   		    dax(i,:)=da{i+1}(1,:)-da{i}(1,:);
            day(i,:)=da{i+1}(2,:)-da{i}(2,:);
            
            %abszisse (=zeit in minuten) relativ zum ersten lauf
            tim1=o.data.time{i}(1:5);            
            tim2=o.data.time{i+1}(1:5);
            hrs1=str2num(tim1(1:2));
            hrs2=str2num(tim2(1:2));
            if hrs2<hrs1
                hrs2=hrs2+24;
            end
            min1help=str2num(tim1(4:5));
            min2help=str2num(tim2(4:5));            
            
            min1=hrs1*60+min1help;
            min2=hrs2*60+min2help;            
 
            timehelp=timehelp+min2-min1;
            tim=[tim;timehelp];
%            tim(i)=min2-min1;
		end
       
		dta=data(o);

        %maxima und minima fuer plotlegende
        m=size(dax,1);
        maxx=max(max(dax(floor(m/2):end,:)));
        minx=min(min(dax(floor(m/2):end,:)));
        rangex=maxx-minx;
        xtxtmax=sprintf('max: %3.2f um',maxx);
        xtxtmin=sprintf('min: %3.2f um',minx);
        xtxtrange=sprintf('rg: %3.2f um',rangex);
        
        maxy=max(max(day(floor(m/2):end,:)));
        miny=min(min(day(floor(m/2):end,:)));
        rangey=maxy-miny;
        ytxtmax=sprintf('max: %3.2f um',maxy);
        ytxtmin=sprintf('min: %3.2f um',miny);
        ytxtrange=sprintf('rg: %3.2f um',rangey);
        
		clrscr;
		subplot(2,1,1);
		plot(tim,dax,'linewidth',1);
		title(dta.title);
		xlabel('Time [min]');
        ylabel('Cyclic X-Drift Axiscoord. [um]');
        textbox(xtxtmax,xtxtmin,xtxtrange,-1);        

        subplot(2,1,2);
		plot(tim,day,'linewidth',1);
		title(dta.title);
		xlabel('time[min]');
        ylabel('Cyclic Y-Drift Axisoord. [um]');
        textbox(ytxtmax,ytxtmin,ytxtrange,-1);                
        
      return;
   end
      
   
   %%%%% zyklische drift der achkoordinaten ( = drift der achskoordinaten von kontrolllauf zu kontrolllauf) %%%%%%
   while is(mode,{'cycNdrift'})
      nn=2;	% Offset zwischen Messlaeufen, bei cycdrift ist nn=1.
      
		da=dachs(o);
      nPointCount=size(da{1},2);

   	    dax=NaN(count(o)-nn,nPointCount); % dax=[];
		    day=NaN(count(o)-nn,nPointCount); % day=[];
        tim=[];
        timehelp=0;
   	    anzahl=count(o);
     
		for i=1:anzahl-nn
   		    dax(i,:)=da{i+nn}(1,:)-da{i}(1,:);
            day(i,:)=da{i+nn}(2,:)-da{i}(2,:);
            
            %abszisse (=zeit in minuten) relativ zum ersten lauf
            tim1=o.data.time{i}(1:5);            
            tim2=o.data.time{i+nn}(1:5);
            hrs1=str2num(tim1(1:2));
            hrs2=str2num(tim2(1:2));
            if hrs2<hrs1
                hrs2=hrs2+24;
            end
            min1help=str2num(tim1(4:5));
            min2help=str2num(tim2(4:5));            
            
            min1=hrs1*60+min1help;
            min2=hrs2*60+min2help;            
 
            timehelp=timehelp+min2-min1;
            tim=[tim;timehelp];
%            tim(i)=min2-min1;
		end
       
		dta=data(o);
      
        %maxima und minima fuer plotlegende
        m=size(dax,1);
        maxx=max(max(dax(floor(m/2):end,:)));
        minx=min(min(dax(floor(m/2):end,:)));
        rangex=maxx-minx;
        xtxtmax=sprintf('max: %3.2f um',maxx);
        xtxtmin=sprintf('min: %3.2f um',minx);
        xtxtrange=sprintf('rg: %3.2f um',rangex);
        
        maxy=max(max(day(floor(m/2):end,:)));
        miny=min(min(day(floor(m/2):end,:)));
        rangey=maxy-miny;
        ytxtmax=sprintf('max: %3.2f um',maxy);
        ytxtmin=sprintf('min: %3.2f um',miny);
        ytxtrange=sprintf('rg: %3.2f um',rangey);
        
		clrscr;
		subplot(2,1,1);
		plot(tim,dax,'linewidth',1);
		title(dta.title);
		xlabel('Time [min]');
        ylabel(sprintf('Cyclic%d X-Drift Axiscoord. [um]',nn));
        textbox(xtxtmax,xtxtmin,xtxtrange,-1);                

        subplot(2,1,2);
		plot(tim,day,'linewidth',1);
		title(dta.title);
		xlabel('time[min]');
        ylabel(sprintf('Cyclic%d Y-Drift Axisoord. [um]',nn));
        textbox(ytxtmax,ytxtmin,ytxtrange,-1);                
        
      return;
   end
      
   
   %%%%% drift der achskordinaten %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   while is(mode,{'daxis'})
		da=dachs(o);
      nPointCount=size(da{1},2);
   
      dax=NaN(count(o),nPointCount); % dax=[];
		day=NaN(count(o),nPointCount); % day=[];
      tim=[];
   
   	anzahl=count(o);
     
		for i=1:anzahl
         dax(i,:)=da{i}(1,:);
         day(i,:)=da{i}(2,:);
         tim=[tim;o.data.time{i}(1:5)];
		end
      
		%vier ecken und mitte gesondert
		mn=dim(o,1);

		m=mn(1);
		n=mn(2);

		dxlihi=NaN(anzahl,1); % dxlihi=[];
		dxrehi=NaN(anzahl,1); % dxrehi=[];
		dxlivo=NaN(anzahl,1); % dxlivo=[];
		dxrevo=NaN(anzahl,1); % dxrevo=[];
		dxmit=NaN(anzahl,1); % dxmit=[];
		dylihi=NaN(anzahl,1); % dylihi=[];
		dyrehi=NaN(anzahl,1); % dyrehi=[];
		dylivo=NaN(anzahl,1); % dylivo=[];
		dyrevo=NaN(anzahl,1); % dyrevo=[];
		dymit=NaN(anzahl,1); % dymit=[];

      ddx=cell(1,anzahl); ddy=cell(1,anzahl);
		for i=1:anzahl
         [ddx{i},ddy{i}]=matrix(da{i},[m n]);
         dxlihi(i)=ddx{i}(1,1); % dxlihi=[dxlihi;ddx{i}(1,1)];
         dxrehi(i)=ddx{i}(1,n); % dxrehi=[dxrehi;ddx{i}(1,n)];
         dxlivo(i)=ddx{i}(m,1); % dxlivo=[dxlivo;ddx{i}(m,1)];
         dxrevo(i)=ddx{i}(m,n); % dxrevo=[dxrevo;ddx{i}(m,n)];
         dxmit(i)=ddx{i}(floor(m/2),floor(n/2)); % dxmit=[dxmit;ddx{i}(floor(m/2),floor(n/2))];

         dylihi(i)=ddy{i}(1,1); % dylihi=[dylihi;ddy{i}(1,1)];
         dyrehi(i)=ddy{i}(1,n); % dyrehi=[dyrehi;ddy{i}(1,n)];
         dylivo(i)=ddy{i}(m,1); % dylivo=[dylivo;ddy{i}(m,1)];
         dyrevo(i)=ddy{i}(m,n); % dyrevo=[dyrevo;ddy{i}(m,n)];
         dymit(i)=ddy{i}(floor(m/2),floor(n/2)); % dymit=[dymit;ddy{i}(floor(m/2),floor(n/2))];
		end

		dta=data(o);
      
      t=1:anzahl;
		clrscr;
		subplot(2,1,1);
      
      if anzahl < 11
         v=1:2:anzahl;
      else
         v=1:floor(anzahl/10):anzahl;
      end
      
		plot(t,dax,'linewidth',1);
		hold on;
		plot(t,dxlihi,'b','linewidth',3);
		plot(t,dxlivo,'g','linewidth',6);
		plot(t,dxrehi,'r','linewidth',3);
		plot(t,dxrevo,'y','linewidth',3);
		plot(t,dxmit,'k','linewidth',3);

		textbox('b...lihi','g...livo','r...rehi','y...revo','k...mitte',-1);
		title(dta.title);
		xlabel('Zeit');
      ylabel('X-Drift Achskoord. [um]');
      set(gca,'xtick',t(v));
      set(gca,'XTickLabel',tim(v,:));      
		shg

		subplot(2,1,2);

		plot(t,day);
		hold on;
		plot(t,dylihi,'b','linewidth',3);
		plot(t,dylivo,'g','linewidth',6);
		plot(t,dyrehi,'r','linewidth',3);
		plot(t,dyrevo,'y','linewidth',3);
		plot(t,dymit,'k','linewidth',3);
		textbox('b...lihi','g...livo','r...rehi','y...revo','k...mitte',-1);
		title(dta.title);
		xlabel('Zeit');
      ylabel('Y-Drift Achskoord. [um]');
      set(gca,'xtick',t(v));
      set(gca,'XTickLabel',tim(v,:));      
		shg

		hold off;
		return;
  	end
   
   
   %%%%% kalibrierpunkte %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   while is(mode,{'calib','fcalib'})
      if ( nargin < 4 ) 
         [az,el] = view; az_el = [az el];
      end
      if nargin < 3
         idx = 1:length(dat.xy);
      end
      
      iref = 1;  filtermode = [];  % default
      if iscell(idx)
         if (length(idx) >= 2), iref = idx{2}; end
         if (length(idx) >= 3), filtermode = idx{3}; end
         idx = idx{1};
      end
      
      [calbx,calby]=calib(o,{idx});
      
      Mx=cell(1,length(calbx));
      for i=1:length(calbx),
         %relativ zum ersten wert rechnen
         row1x=calbx{i}(1,:);
         m=size(calbx{i},1);
         one=ones(m,1)*row1x;
         Mx{i}=calbx{i}-one;
      end
      
      My=cell(1,length(calby));
      for i=1:length(calby),
         row1y=calby{i}(1,:);
         m=size(calby{i},1);
         one=ones(m,1)*row1y;
         My{i}=calby{i}-one;
      end
      
      Mxf=cell(1,length(idx)); Myf=cell(1,length(idx));
      for i=1:length(idx),
         clrscr;
         hold off;
         
         if is(mode,{'calib'})
            subplot(2,1,1);
            plot(Mx{i});
            title('X-Drift der Kalibrierpunkte');
            txt1 = sprintf('li hi mx/sx: %0.1g/%0.1g um',mean(Mx{i}(:,1)), std(Mx{i}(:,1)));
		      txt2 = sprintf('re hi mx/sx: %0.1g/%0.1g um',mean(Mx{i}(:,2)), std(Mx{i}(:,2)));
            txt3 = sprintf('re vo mx/sx: %0.1g/%0.1g um',mean(Mx{i}(:,3)), std(Mx{i}(:,3)));
		      txt4 = sprintf('li vo mx/sx: %0.1g/%0.1g um',mean(Mx{i}(:,4)), std(Mx{i}(:,4)));

            legend(txt1,txt2,txt3,txt4,-1);
            
            subplot(2,1,2);
            plot(My{i});
            title('Y-Drift der Kalibrierpunkte');
            txt1 = sprintf('li hi my/sy: %0.1g/%0.1g um',mean(My{i}(:,1)), std(My{i}(:,1)));
		      txt2 = sprintf('re hi my/sy: %0.1g/%0.1g um',mean(My{i}(:,2)), std(My{i}(:,2)));
            txt3 = sprintf('re vo my/sy: %0.1g/%0.1g um',mean(My{i}(:,3)), std(My{i}(:,3)));
		      txt4 = sprintf('li vo my/sy: %0.1g/%0.1g um',mean(My{i}(:,4)), std(My{i}(:,4)));

            legend(txt1,txt2,txt3,txt4,-1);
         end
         
         if is(mode,{'fcalib'})
            Mxf{i}=onedfilt(Mx{i},filtermode);
            Myf{i}=onedfilt(My{i},filtermode);
            
            subplot(2,1,1);
            plot(Mxf{i});
            legend('links hinten','rechts hinten','rechts vorne','links vorne',-1);
            hold on;
            plot(Mx{i},'o');
            title('X-Drift der Kalibrierpunkte');
            
            
            subplot(2,1,2);
            plot(Myf{i});
            legend('links hinten','rechts hinten','rechts vorne','links vorne',-1);
            hold on;
            plot(My{i},'o');
            title('Y-Drift der Kalibrierpunkte');
            hold off;
         end
         
         
         figure(danaFigure('danaMenuFigure')); % figure(gcf);   % shg
         if length(idx) > 1
            pause
         end
      end
      return
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% surface drift

   while is(mode,{'sdriftx','sdrifty','rdriftx','rdrifty',...
                     'fdriftx','fdrifty','dnoisex','dnoisey',...
                     'frdriftx','frdrifty','rdnoisex','rdnoisey'})
      if ( nargin < 4 ) 
         [az,el] = view; az_el = [az el];
      end
      if nargin < 3
         idx = 1:count(o);
      end
      
      if strcmp(property(o,'kind'),'CAP')
         topic = 'Error';
      else
         topic = 'Drift';
      end
      
      iref = 1;  filtermode = [];  % default
      if iscell(idx)
         if (length(idx) >= 2), iref = idx{2}; end
         if (length(idx) >= 3), filtermode = idx{3}; end
         idx = idx{1};
      end
      
         % calculate min and max z

      [Dx,Dy] = ddata(o,{1:count(o)},iref);

      mindx = inf; maxdx = -inf;
      mindy = inf; maxdy = -inf;
      for i=1:count(o),
         mindx = min(mindx,min(min(Dx{i})));
         maxdx = max(maxdx,max(max(Dx{i})));
         mindy = min(mindy,min(min(Dy{i})));
         maxdy = max(maxdy,max(max(Dy{i})));
      end

      [Kx,Ky] = bdata(o,{idx});
      [Dx,Dy] = ddata(o,{idx},iref);
      
      pts = points(o,count(o));
      matrix(pts([2 1]));
      R=cell(1,length(idx));
      for i=1:length(idx),
         clrscr;

         R{i} = resi(vset(Kx{i},Ky{i}),vset(Dx{i},Dy{i}));   % residual drift

         hold off;
         if strcmp(mode,'sdriftx')
            Mx = Dx{i};  My = Dy{i};
            surf(Kx{i}/1000,Ky{i}/1000,Mx); 
            hold on
            line(0,0,mindx);  line(0,0,maxdx);
            title(sprintf([topic,' Matrix X(%g)'],idx(i)));
         elseif strcmp(mode,'sdrifty')
            Mx = Dx{i};  My = Dy{i};
            surf(Kx{i}/1000,Ky{i}/1000,My); 
            hold on
            line(0,0,mindy);  line(0,0,maxdy);
            title(sprintf([topic,' Matrix Y(%g)'],idx(i)));
         elseif strcmp(mode,'rdriftx')
            [Mx,My] = matrix(R{i});
            surf(Kx{i}/1000,Ky{i}/1000,Mx); 
            hold on
            %line(0,0,mindx);  line(0,0,maxdx);
            title(sprintf(['Residual ',topic,' Matrix X(%g)'],idx(i)));
         elseif strcmp(mode,'rdrifty')
            [Mx,My] = matrix(R{i});
            surf(Kx{i}/1000,Ky{i}/1000,My); 
            hold on
            %line(0,0,mindy);  line(0,0,maxdy);
            title(sprintf(['Residual ',topic,' Matrix Y(%g)'],idx(i)));
         elseif strcmp(mode,'fdriftx')
            Mx = twodfilt(Dx{i},filtermode);
            My = twodfilt(Dy{i},filtermode);
            surf(Kx{i}/1000,Ky{i}/1000,Mx); 
            hold on
            %line(0,0,mindx);  line(0,0,maxdx);
            title(sprintf(['Filtered ',topic,' Matrix X(%g)'],idx(i)));
         elseif strcmp(mode,'fdrifty')
            Mx = twodfilt(Dx{i},filtermode);
            My = twodfilt(Dy{i},filtermode);
            surf(Kx{i}/1000,Ky{i}/1000,My); 
            hold on
            %line(0,0,mindy);  line(0,0,maxdy);
            title(sprintf(['Filtered ',topic,' Matrix Y(%g)'],idx(i)));
         elseif strcmp(mode,'dnoisex')
            Mx = Dx{i} - twodfilt(Dx{i},filtermode);
            My = Dy{i} - twodfilt(Dy{i},filtermode);
            surf(Kx{i}/1000,Ky{i}/1000,Mx); 
            hold on
            %line(0,0,mindx);  line(0,0,maxdx);
            title(sprintf([topic,' Noise X(%g)'],idx(i)));
         elseif strcmp(mode,'dnoisey')
            Mx = Dx{i} - twodfilt(Dx{i},filtermode);
            My = Dy{i} - twodfilt(Dy{i},filtermode);
            surf(Kx{i}/1000,Ky{i}/1000,My); 
            hold on
            %line(0,0,mindy);  line(0,0,maxdy);
            title(sprintf([topic,' Noise Y(%g)'],idx(i)));
         elseif strcmp(mode,'frdriftx')
            [Mx,My] = matrix(R{i});
            Mx = twodfilt(Mx,filtermode);
            My = twodfilt(My,filtermode);
            surf(Kx{i}/1000,Ky{i}/1000,Mx); 
            hold on
            %line(0,0,mindx);  line(0,0,maxdx);
            title(sprintf(['Filtered Residual ',topic,' Matrix X(%g)'],idx(i)));
         elseif strcmp(mode,'frdrifty')
            [Mx,My] = matrix(R{i});
            Mx = twodfilt(Mx,filtermode);
            My = twodfilt(My,filtermode);
            surf(Kx{i}/1000,Ky{i}/1000,My); 
            hold on
            %line(0,0,mindy);  line(0,0,maxdy);
            title(sprintf(['Filtered Residual ',topic,' Matrix Y(%g)'],idx(i)));
         elseif strcmp(mode,'rdnoisex')
            [Mx,My] = matrix(R{i});
            Mx = Mx - twodfilt(Mx,filtermode);
            My = My - twodfilt(My,filtermode);
            surf(Kx{i}/1000,Ky{i}/1000,Mx); 
            hold on
            %line(0,0,mindx);  line(0,0,maxdx);
            title(sprintf(['Residual ',topic,' Noise X(%g)'],idx(i)));
         elseif strcmp(mode,'rdnoisey')
            [Mx,My] = matrix(R{i});
            Mx = Mx - twodfilt(Mx,filtermode);
            My = My - twodfilt(My,filtermode);
            surf(Kx{i}/1000,Ky{i}/1000,My); 
            hold on
            %line(0,0,mindy);  line(0,0,maxdy);
            title(sprintf(['Residual ',topic,' Noise Y(%g)'],idx(i)));
         end
         
         kx = Kx{i};  ky = Ky{i};
         pts = points(o);
         dst = distance(o);
         set(gca,'ydir','reverse');
         set(gca,'fontsize',8)
         if ( pts(1) <= 10 ), set(gca,'xtick',kx(1,:)/1000); end
         if ( pts(1) <= 10 ), set(gca,'ytick',ky(:,1)/1000); end
         xlabel(sprintf('X: %g points [%g mm]',pts(1),dst(1)/1000));
         ylabel(sprintf('Y: %g points [%g mm]',pts(2),dst(2)/1000));
         
         if is(mode,{'sdriftx','sdrifty','fdriftx','fdrifty'})
            NormalLegend('Deviations:',vset(Mx,My));
         elseif is(mode,{'rdriftx','rdrifty','frdriftx','frdrifty'})
				NormalLegend('Deviations:',vset(Mx,My))
%             K = vset(Kx{i},Ky{i});
%             D = vset(Dx{i},Dy{i});
%             [R,T] = resi(K,K+D);           % residual drift
%             ResidualLegend(o,R,T);
         elseif is(mode,{'dnoisex','dnoisey','rdnoisex','rdnoisey'})
            NormalLegend('Noise:',vset(Mx,My))
         end
         
         figure(danaFigure('danaMenuFigure')); % figure(gcf);   % shg
         if length(idx) > 1
            pause
         end
      end
      return
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ball plot

   while is(mode,{'ballplot'})
      if ( nargin < 4 ), az_el = 1; end
      kind = az_el;
      sp = specs(o);
      
      clrscr;
      if nargin < 3
         idx = 1:count(o);
      end
      
      iref = 1;   % default
      if iscell(idx)
         if (length(idx) >= 2), iref = idx{2}; end
         idx = idx{1};
      end

      if ( kind == 0 )
         tit = 'Capability Analysis';
      elseif ( kind == 1 )
         tit = 'Drift analysis versus optimum compensation';
      elseif ( kind == -2 )
         tit = 'Drift analysis versus 2 point compensation';
      elseif ( kind == -3 )
         tit = 'Drift analysis versus 3 point compensation';
      elseif ( kind == -4 )
         tit = 'Drift analysis versus 4 point compensation';
      elseif ( kind == -5 )
         tit = 'Drift analysis versus 5 point compensation';
      else
         error('Ballplot: bad mode!');
      end
      
      K = kdata(o,{idx});
      D = ddata(o,{idx},iref);
      Dref = ddata(o, iref);

      for i=1:length(idx),
         clrscr;
         
         spc = sp;
         if (size(spc,2)>=2) 
            spc = spc(:,1:2);
         end
         
         switch kind
         case 0
            capxyb(D{i},sp);         
         otherwise
            if iref > 1
                gana(K{i},D{i}-Dref,kind,spc);         
            else
                gana(K{i},D{i},kind,spc);         
            end
         end
         
         if (count(o) == 1)
            title(tit);
         else
            title(sprintf([tit,' (%g)'],idx(i)));
         end
         xlabel(info(o));
         figure(danaFigure('danaMenuFigure')); % figure(gcf);   % shg
         if length(idx) > 1
            pause
         end
      end
      return
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   while is(mode,{'histogram'})
      sp = specs(o);
      
      clrscr;
      if nargin < 3
         idx = 1:count(o);
      end
      
      iref = 1;   % default
      if iscell(idx)
         if (length(idx) >= 2), iref = idx{2}; end
         idx = idx{1};
      end
      
      K = kdata(o,{idx});
      D = ddata(o,{idx},iref);

      for i=1:length(idx),
         clrscr;
         capxyh(D{i},sp);         
         if (count(o) == 1)
            title('Capability Analysis');
         else
            title(sprintf('Capability Analysis (%g)',idx(i)));
         end
         %xlabel(info(o));
         figure(danaFigure('danaMenuFigure')); % figure(gcf);   % shg
         if length(idx) > 1
            pause
         end
      end
      return
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% time drift

   while strcmp(mode,'tdriftx')
      clrscr;
      [Dx,Dy] = drift(o);
      t = time(o,[])/60;
      if (length(t) ~= size(Dx,1))
         t = (1:size(Dx,1))';
      end
      hold off
      plot(t,Dx);
      hold on
      plot(t,Dx,'o');
      title('X-Drift over time')
      xlabel('t [min]');
      return
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   while strcmp(mode,'tdrifty')
      clrscr;
      [Dx,Dy] = drift(o);
      t = time(o,[]);
      if (length(t) ~= size(Dy,1))
         t = (1:size(Dy,1))';
      end
      hold off
      plot(t,Dy);
      hold on
      plot(t,Dy,'o');
      title('Y-Drift over time')
      xlabel('t [min]');
      return
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   while strcmp(mode,'tdriftr')
      clrscr;
      Dr = drift(o);
      t = time(o,[])/60;
      if (length(t) ~= size(Dr,1))
         t = (1:size(Dr,1))';
      end
      hold off
      plot(t,Dr);
      hold on
      plot(t,Dr,'o');
      title('Radial Drift over time')
      xlabel('t [min]');
      return
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% temperature over time

   while strcmp(mode,'temp')
      clrscr;
      T = temp(o);
      t = time(o,[])/60;
      hold off
      plot(t,T);

      hold on
      ylim = get(gca,'ylim');

      evs = events(o)/60;
      for ev=evs(:)',
         plot(ev*[1 1],ylim,'k');      
      end

      dat = data(o);
      labs = dat.eventlabels;
      y = mean(get(gca,'ylim'));
      for i=1:length(labs),
         h = text(evs(i),y,labs{i});
         set(h,'rotation',90);
         set(h,'horizontalalignment','center');
         set(h,'verticalalignment','top');
      end


      hold off

      title('Temperature over Time')
      xlabel('t [min]');
      return
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   error(['bad mode for TDMOBJ-method plot: ',mode]);
   return
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function NormalLegend(text,M)          % Provide Normal Legend         
   devs = devi(M);

   %@@@6 change roundiing behaviour
   mt = round(100*devs(1))/100;
   mx = round(100*devs(2))/100;
   my = round(100*devs(3))/100;
   st = round(100*devs(5))/100;
   sx = round(100*devs(6))/100;
   sy = round(100*devs(7))/100;
   rt = round(100*devs(13))/100;
   rx = round(100*devs(14))/100;
   ry = round(100*devs(15))/100;
   %@@@6 change roundiing behaviour

   txt0 = text;
   txt1 = sprintf('MX: %g um',mx);
   txt2 = sprintf('MY: %g um',my);
   txt3 = sprintf('SX: %g um',sx);
   txt4 = sprintf('SY: %g um',sy);
   txt5 = sprintf('RX: %g um',rx);
   txt6 = sprintf('RY: %g um',ry);

   txt7 = 'Total:';
   txt8 = sprintf('MT: %g um',mt);
   txt9 = sprintf('ST: %g um',st);
   txt10 = sprintf('RT: %g um',rt);

   textbox(txt0,'',txt1,txt2,txt3,txt4,txt5,txt6,'',txt7,'',txt8,txt9,txt10);
end
      
function ResidualLegend(o,M,T)         % Provide Residual legend       
   %@@@7 change roundiing behaviour
   par = hskr(T);
   ro = round(100*par(1)/deg*1000)/100;
   kx = round(100*(par(2)-1)*1e5)/100;
   ky = round(100*(par(3)-1)*1e5)/100;
   sh = round(100*par(4)*1e5)/100;
   x0 = round(100*par(5))/100;
   y0 = round(100*par(6))/100;

   devs = devi(M);
   sx = round(100*devs(6))/100;
   sy = round(100*devs(7))/100;
   rx = round(100*devs(14))/100;
   ry = round(100*devs(15))/100;
   %@@@7 change roundiing behaviour

   [satx,saty]=sattel(o);

   txt0 = 'Principal:';
   txta = sprintf('X0: %g um',x0);
   txtb = sprintf('Y0: %g um',y0);
   txt1 = sprintf('RO: %g um',ro);
   txt2 = sprintf('KX: %g um/dm',kx);
   txt3 = sprintf('KY: %g um/dm',ky);
   txt4 = sprintf('SH:  %g um/dm',sh);

   txt5 = 'Residual:';
   txt6 = sprintf('SX: %g um',sx);
   txt7 = sprintf('SY: %g um',sy);
   txt8 = sprintf('RX: %g um',rx);
   txt9 = sprintf('RY: %g um',ry);

   txt10= sprintf('SadX: %g ',satx);
   txt11= sprintf('SadY: %g ',saty);

   textbox(txt5,'',txt6,txt7,txt8,txt9,'',txt0,'',txta,txtb,txt1,txt2,txt3,txt4,'',txt10,txt11);
end

