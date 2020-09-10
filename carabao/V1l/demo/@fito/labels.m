function oo = labels(o)                % Labels Method
%
% LABELS   Draw labels:
%
%             oo = labels(o)
%
%          If object type equals 'fito' then provide specific labeling
%          Otherwise use CARAMEL labeling
%
%          See also: FITO, PLOT
%
   if isequal(o.type,'fito')
      oo = Labels(o);
   else
      co = cast(o,'caramel');
      oo = labels(co);
   end
end

function oo = Labels(o,sub)            % Draw FITO specific labels     
   mode = opt(o,{'mode.signal','All'});
   switch mode
      case 'All'
         subplot(211);
         Labeling(o,1);
         subplot(212)
         Labeling(o,2);
      case 'Signals'
         Labeling(o,1);
      case 'Errors'
         Labeling(o,2);
   end
   oo = o;
end
function oo = Labeling(o,sub)          % draw FITO specific labels     
   rd = @carabull.rd;                  % short hand
   oo = o;
   c = get(o,'context');
   
   [std0,std1,std2] = get(o,'std0','std1','std2');
   [avg0,avg1,avg2] = get(o,'avg0','avg1','avg2');
   [cpk0,cpk1,cpk2] = get(o,'cpk0','cpk1','cpk2');
   sz = get(o,'sizes');  Ns = sz(3);   % repeats 
   
   mcpk0 = mean(cpk0);   lcpk0 = mcpk0 - 3*std(cpk0);
   mcpk1 = mean(cpk1);   lcpk1 = mcpk1 - 3*std(cpk1);
   mcpk2 = mean(cpk2);   lcpk2 = mcpk2 - 3*std(cpk2);

   mavg0 = mean(avg0);   mstd0 = mean(std0);
   mavg1 = mean(avg1);   mstd1 = mean(std1);
   mavg2 = mean(avg2);   mstd2 = mean(std2);

   nsigma = lcpk2*3;
   extra = o.iif(c.Nx>0,sprintf('.%g',c.Nx),'');
   Kind = upper(c.F2.kind);

   switch sub
      case 1
%        subplot(2,1,1);
      %  plot(t,0*t,'k-',  t,r(:,1),'k',  t,y(:,1),'g',  tf,yf0(:,1),'b',  tf,yf1(:,1),'r',  tf,yf2(:,1),'k',  tf,yf2(:,1),'k.')
         xlabel('time t [min]');
         if (Ns == 1)
            title(sprintf([Kind,' (%g',extra,...
               ') Filter Demo - Tf = %g,  Kp = %g,  Noise: std = %g'],...
               c.type,c.Tf,c.Kp,rd(c.stdw(1))));
            ylabel('1 simulation per parameter set');
         else
            title(sprintf([Kind,' (%g',extra,...
               ') Filter Demo - Tf = %g,  Kp = %g,  Noise: std = %g,  => %g Sigma'],...
               c.type,c.Tf,c.Kp,rd(c.stdw(1)),rd(nsigma,1)));
            ylabel(sprintf('%g simulations per parameter set',Ns));
         end

      case 2
%        subplot(2,1,2);
      %  y0 = 0;
         if (Ns > 1)
            title(sprintf(['ORFI(0',extra,') Filter - Cpk = %g (%g/%g), TWIN(1',...
                  extra,') Filter - Cpk = %g (%g/%g), ',Kind,'(%g',extra,...
                  ') Filter - Cpk = %g (%g/%g)'],...
                  rd(cpk0(1)),rd(mcpk0),rd(lcpk0),  rd(cpk1(1)),rd(mcpk1),...
                  rd(lcpk1), c.type,rd(cpk2(1)),rd(mcpk2),rd(lcpk2)));
            xlabel(sprintf(['ORFI(0) Filter - Avg/Std = %g/%g, TWIN(1) Filter - Avg/Std = %g/%g, ',...
                  Kind,'(%g) Filter - Avg/Std = %g/%g'],...
                  rd(avg0(1)),rd(std0(1)),rd(avg1(1)),rd(std1(1)),c.type,...
                  rd(avg2(1)),rd(std2(1))));
         else
            tit = sprintf(['ORFI(0',extra,') Filter - Cpk = %g, TWIN(1',...
               extra,') Filter - Cpk = %g, ',Kind,'(%g',extra,...
               ') Filter - Cpk = %g'],rd(cpk0(1)),rd(cpk1(1)),...
               c.type,rd(cpk2(1)));
            title(tit);
            xlabel(sprintf(['ORFI(0) Filter - Avg/Std = %g/%g, TWIN(1) Filter - Avg/Std = %g/%g',...
                Kind,'(%g) Filter - Avg/Std = %g/%g'],...
                rd(avg0(1)),rd(std0(1)),rd(avg1(1)),rd(std1(1)),c.type,rd(avg2(1)),rd(std2(1))));
         end
         ylabel(sprintf(['ORFI(0): blue,  TWIN(1): blue,  ',upper(c.F2.kind),'(%g): black'],c.type));
         set(gca,'ylim',[-4,4]);
   end
   shg
end