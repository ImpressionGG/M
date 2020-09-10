function [avg,sig] = analyse(o,kind,type,N,Tf,Kp)
%
% ANALYSE   Analyse Cpk distribution of filter settings
%
%              analyse(o,kind,type,N,Tf,Kp,ref)
%              analyse(o,kind,[1 det ref],N,Tf,Kp,ref)
%
%           2nd arg 'kind' is a string describing the kind of filter.
%           3rd arg 'type' is either integer or a cell aray: {type,det,ref}
%
%           See also: FITO, STUDY
%
   rd = @carabull.rd;                  % short hand
   
   Nx  = eval('Nx','0');
   N  = eval('N','5');
   if (N >= 50)
      Tf = eval('Tf','[0.1 0.25:0.25:4]');
      Kp = eval('Kp','[-0.1 0.0 0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1]');
   elseif (N >= 15)
      Tf = eval('Tf','[0.1 0.5:0.5:4]');
      Kp = eval('Kp','[-0.1 0.0 0.1,0.2,0.3,0.4,0.6,0.9,1]');
   else
      Tf = eval('Tf','[0.1 0.5:0.5:4]');
      Kp = eval('Kp','[-0.1 0.0 0.1,0.3,0.6,0.9,1]');
   end
   cols = {'r','g','b','m','c','y','r','g','b','m','c','y','r','g','b','m','c','y'};

   if iscell(type)
      typ = type{1};
      type{2} = 0;    % stochastic mode !
      eval('ref = type{3};','');
      Nx = eval('ref.Nx','Nx');
   end
   Type = type;   % save original argument value

   extra = o.iif(Nx>0,sprintf('.%g',Nx),'');
   Kind = upper(kind);
   
   cls(o);
   o = opt(o,'put',false);             % don't put object into shell object
   
   subplot(221);
   cmd = ['simu(o,''',kind,''',type)'];
   [cpk,t,r,w,y,tf,f] = eval(cmd);
   plot(t,0*t,'k');  hold on;
   hdl = plot(t,r,'b',  t,r,'k.');
   H = [];
   for (k=1:length(t))
       hdl = plot(t(k)*[1 1], [0 w(k)],'g');  H = [H;hdl(:)];
   end
   hdl = plot(t,w,'go', tf,f,'r', tf,f,'r.');  H = [H;hdl(:)];
   set(gca,'xlim',[min(t),max(t)], 'ylim',get(gca,'ylim'));
   xlabel('Time t [min]');
   if (iscell(type))
       det = eval('type{2}','');
       ref = eval('type{3}','');
       ylabel(refcmd(ref));
       type = type{1};
   end       
   
   subplot(222);
   plot([-0.11,max(Kp)],[0 0],'k');  hold on;
   %plot([0 0],[0,max(Tf)],'k'); 
   set(gca,'xlim',[-0.11,max(Kp)],'ylim',[0,max(Tf)]);
   title(sprintf([Kind,' Filter (%g',extra,') Parameter Space (Tf,Kp)'],type));
   xlabel('Kalman Parameter Kp');
   ylabel('Filter Time Constant Tf');

   subplot(223);
   plot([0,max(Tf)],[0 0],'k');  hold on;
   set(gca,'xlim',[0,max(Tf)],'ylim',[0 4]);
   title('Filter Cpk (Kp fixed)');
   xlabel('Filter Time Constant Tf');
   ylabel(sprintf('Filter Cpk  (%g trials)',N));

   subplot(224);
   plot([0,max(Kp)],[0 0],'k');  hold on;
   set(gca,'xlim',[-0.11,1],'ylim',[0 4]);
   title('Optimal Filter Cpk');
   xlabel('Kalman Parameter Kp');
   ylabel(sprintf('%g runs per parameter set',N));

   drawnow
   
   avg = [];  sig = [];
   acpk = -inf;  lcpk = -inf;  iopt = 0;  jopt = 0;
   eTf = 0.06; eKp = eTf/4;
   
   for (i=1:length(Kp))
       subplot(224);  colo = [cols{i},'o'];  colp = [cols{i},'+'];  coll = [cols{i},'-'];  cold = [cols{i},':'];
       plot(Kp(i)*[1 1],get(gca,'ylim'),cold);
       drawnow
       for (j = 1:length(Tf))
          cpk = [];
          if (rem(N,200) == 0)  % then N=100, 200, 500, 1000, ...
              kmax = N/200;
          else
              kmax = 1;
          end
          for (k=1:kmax)   % for (k = 1:N)
             %[Cpk,t,r,w,y,f] = simu(kind,Type,Tf(j),Kp(i));
             [Cpk,t,r,w,y,tf,f,Kind] = simu(o,kind,Type,Tf(j),Kp(i),N/kmax);
             cpk = [cpk,Cpk];
             if(1)  % if (mod(k,min(10,N))==0)
                subplot(221);
                delete(H);  H = [];
                for (l=1:length(t))
                   hdl = plot(t(l)*[1 1], [0 w(l)],'g');  H = [H;hdl(:)];
                end
                hdl = plot(t,w,'go', t,r,'b',  t,r,'k.', tf,f,'r', tf,f,'r.');  H = [H;hdl(:)];
                title(sprintf(['Current Filtering (k = %2g): Tf = %g, Kp = %g  =>  Cpk = %g'],k,Tf(j),Kp(i),rd(mean(Cpk))));

                subplot(222);
                phi = 0:pi/25:21*pi;  R = 0.03;     % R = 0.05;
                hdl = plot(Kp(i)+R*cos(phi),Tf(j)+R*sin(phi)*6,'k');  H = [H;hdl(:)];
                set(hdl,'LineWidth',6);
                title(sprintf([Kind,'(%g',extra,') Filter Parameter Space (Tf,Kp)'],type));
                drawnow;
             end
          end
          avg(i,j) = mean(cpk);
          sig(i,j) = std(cpk);
          subplot(223);  colo = [cols{i},'o'];  colp = [cols{i},'+'];  coll = [cols{i},'-'];  cold = [cols{i},':'];
          plot(Tf(j),avg(i,j),colo, Tf(j),avg(i,j)-3*sig(i,j),colp,Tf(j),avg(i,j)+3*sig(i,j),colp);
          drawnow;
          
       end
       subplot(223);   colo = [cols{i},'o'];  colp = [cols{i},'+'];  coll = [cols{i},'-'];  cold = [cols{i},':'];
       plot(Tf,avg(i,:),coll, Tf,avg(i,:)-3*sig(i,:),cold, Tf,avg(i,:)+3*sig(i,:),cold);

       low = avg-3*sig;
       opti = max(low')';
       j = find(low(i,:) == opti(i));  j = j(1);

       if (low(i,j) > lcpk)
           iopt = i;  jopt = j;
           acpk = avg(i,j);  lcpk = low(i,j);
       end
       
       plot(Tf(j)*[1 1],get(gca,'ylim'),cold);
       cl = avg(i,j)-3*sig(i,j); cu = avg(i,j)+3*sig(i,j);  cm = (cl+cu)/2;  e = eTf;
       hdl = plot(Tf(j)+[0 e 0 -e 0],[cl cm cu cm cl],cols{i});
       set(hdl,'LineWidth',2);
       
       subplot(224);
       plot(Kp(i),avg(i,j),colo, Kp(i),avg(i,j)-3*sig(i,j),colp, Kp(i),avg(i,j)+3*sig(i,j),colp);
       
       cl = avg(i,j)-3*sig(i,j); cu = avg(i,j)+3*sig(i,j);  cm = (cl+cu)/2;  e = eKp; 
       hdl = plot(Kp(i)+[0 e 0 -e 0],[cl,cm,cu,cm,cl],cols{i});
       set(hdl,'LineWidth',2);
       
       nsigma = lcpk*3;
       title(sprintf('Optimal Filter: Tf = %g, Kp = %g (Avg/Least Cpk = %g/%g) => %g Sigma',Tf(jopt),Kp(iopt),rd(acpk),rd(lcpk),rd(nsigma,1)));

       subplot(222);
       plot(Kp(i),Tf(j),colo, Kp(i),Tf(j),[cols{i},'.']);

       KpOpt(i) = Kp(i);  TfOpt(i) = Tf(j);
   end

   low = avg-3*sig;
   opti = max(low')';
    
   for (i=1:length(Kp))
       j = find(low(i,:) == opti(i));  j = j(1);
       subplot(224);  colo = [cols{i},'o'];  colp = [cols{i},'+'];  coll = [cols{i},'-'];  cold = [cols{i},':'];  colb = [cols{i},'.'];
       Lower(i) = avg(i,j)-3*sig(i,j);  Upper(i) = avg(i,j)+3*sig(i,j);
       plot(Kp,avg(:,j),coll, Kp,Lower(i),cold, Kp,Upper(i),cold);
   end
   
      % connect all upper, average and lower levels in the Kp-chart
      
   hdl = plot(Kp,Lower,'k--',Kp,Upper,'k--',Kp,(Lower+Upper)/2,'k');
   set(hdl,'LineWidth',3);
   
   col = [cols{i},'.'];
   plot(Kp(iopt),avg(iopt,jopt),'k.', Kp(iopt),avg(iopt,jopt)-3*sig(iopt,jopt),'k.', Kp(iopt),avg(iopt,jopt)+3*sig(iopt,jopt),'k.');

      % now mark optimal Kp-parameter
   
   cl = avg(iopt,jopt)-3*sig(iopt,jopt); cu = avg(iopt,jopt)+3*sig(iopt,jopt);  cm = (cl+cu)/2;  e = eKp;
   hdl = plot(Kp(iopt)+[0 e 0 -e 0],[cl,cm,cu,cm,cl],'k');
   set(hdl,'LineWidth',6);
   hdl = plot(Kp(iopt)+[0 e 0 -e 0],[cl,cm,cu,cm,cl],cols{iopt});
   set(hdl,'LineWidth',2);
   
   hdl = plot(get(gca,'xlim'),[avg(iopt,jopt)-3*sig(iopt,jopt)]*[1 1],'k-');
   
      % now mark optimal Tf-parameter
      
   subplot(223); e = eTf;
   hdl = plot(Tf(jopt)+[0 e 0 -e 0],[cl cm cu cm cl],'k');
   set(hdl,'LineWidth',6);
   hdl = plot(Tf(jopt)+[0 e 0 -e 0],[cl cm cu cm cl],cols{iopt});
   set(hdl,'LineWidth',2);
       
      % final filtering with optimal parameters
      
   subplot(221);
   delete(H);
   [cpk,t,r,w,y,tf,f] = simu(o,kind,Type,Tf(jopt),Kp(iopt));
   hold off;
   plot(t,0*t,'k');  hold on;
   for (k=1:length(t))
       plot(t(k)*[1 1], [0 w(k)],'g');
   end
   plot(t,w,'go', t,r,'b',  t,r,'k.', tf,f,'r', tf,f,'r.');  hold on;
   set(gca,'xlim',[min(t),max(t)]);
   xlabel('Time t [min]');
   title(sprintf(['Optimal ',Kind,'(%g',extra,') Parameters: Tf = %g, Kp = %g  =>  Cpk = %g'],typ,Tf(jopt),Kp(iopt),rd(cpk)));
   if (iscell(type))
       ref = eval('type{3}','');
       ylabel(ref);
   end       

      % Now update Tf-Kp-Chart
      
   subplot(222);
   hdl = plot(KpOpt,TfOpt,'k');
   set(hdl,'LineWidth',3);
   
   for (i=1:length(TfOpt))
       hdl = plot(KpOpt(i),TfOpt(i),[cols{i},'o'], KpOpt(i),TfOpt(i),[cols{i},'.']);
       set(hdl,'LineWidth',3);
       hdl = plot(KpOpt(i),TfOpt(i),'ko');

       phi = 0:pi/25:21*pi;  Rmax = max(0.1,Lower(i)-1)/5;     % R = 0.05;
       if (i == iopt)
          hdl = plot(KpOpt(i)+Rmax*cos(phi), TfOpt(i)+6*Rmax*sin(phi),'k');
          set(hdl,'LineWidth',3);
          hdl = plot(KpOpt(i)+Rmax*cos(phi), TfOpt(i)+6*Rmax*sin(phi),cols{i});
       end
       for (R=0.01:0.01:Rmax)
          hdl = plot(KpOpt(i)+R*cos(phi), TfOpt(i)+6*R*sin(phi),cols{i});
       end
   end
   nsigma = Lower(iopt)*3;  % n-sigma value
   title(sprintf([Kind,' Filter (%g',extra,') Parameter Space (Tf,Kp) => %g Sigma'],type,rd(nsigma,1)));
   
   
   return

%==========================================================================

function str = refcmd(ref)
%
% REFCMD    Generate a string showing the reference command
%
   if (isstr(ref))
       str = ref;
       return
   end
   
   str = sprintf('reference(%g,[%g %g %g])',ref.mode,ref.V,ref.T,ref.T1);
   return
   
% eof