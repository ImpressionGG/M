function oo = plot(o,varargin)         % GLASS Plot Method
%
% PLOT   Cappuccino plot method
%
%           plot(o,'StreamX')          % stream plot X
%           plot(o,'StreamY')          % stream plot Y
%           plot(o,'Scatter')          % scatter plot
%           plot(o,'Show')             % show object
%           plot(o,'Animation')        % animation of object
%
   [gamma,oo] = manage(o,varargin,@Drehzahl,@Setup,@Aenderung);
   oo = gamma(oo);
end

function oo = Setup(o)                 % Setup Plot Menu               
   setting(o,{'plot.Tf'},1.0);

   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = mitem(oo,'Drehzahl -> Durchmesser (Absolut)',{@Drehzahl});
   ooo = mitem(oo,'Drehzahl -> Durchmesser (Änderung)',{@Aenderung});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Parameter');
   oooo = mitem(ooo,'Filter Time Constant',{},'plot.Tf');
   choice(oooo,{{'0.5s',0.5},{'1.0s',1.0},{'2.0s',2.0}},{});
end

%==========================================================================
% Drehzahl
%==========================================================================

function o = Drehzahl(o)
   refresh(o,{@plot,'Drehzahl'});
   list = basket(o);
   for (i=1:length(list))
      oo = list{i};
      DrehzahlDurchmesser(oo);
   end
end
function o = DrehzahlDurchmesser(o)
   t = data(o,'t');
   n = data(o,'n');
   d1 = data(o,'d1');
   d2 = data(o,'d2');
   cls(o);
   
   subplot(311);
   plot(t,d2,'g');
   title('Durchmesser d2 (Messstelle oben)');
   ylabel('d2 (µ)');

   subplot(312);
   plot(t,d1,'r');
   title('Durchmesser d1 (Messstelle unten)');
   ylabel('d1 (µ)');
   
   subplot(313);
   plot(t,n,'b');
   title('Drehzahl');
   ylabel('n (1/s)');
end

%==========================================================================
% Änderung
%==========================================================================

function o = Aenderung(o)
   refresh(o,{@plot,'Aenderung'});
   list = basket(o);
   for (i=1:length(list))
      oo = list{i};
      AenderungDrehzahlDurchmesser(oo);
   end
end

function o = AenderungDrehzahlDurchmesser(o)
   t = data(o,'t');
   n = delta(o,'n');    
   d1 = delta(o,'d1');  
   d2 = delta(o,'d2'); 

   Tf = opt(o,{'plot.Tf',1.0});
   %Gs = trf(-300,[0.3 1]);
   Gs = trf([-252.8 -0.6748],[1 0.9014 2.968e-5]);

   fn = filter(o,'n',Tf);
   fd1 = filter(o,'d1',Tf);
   fd2 = filter(o,'d2',Tf);

   cls(o);
   
   subplot(311);
   plot(t,d2,'g');
   title('Änderung Durchmesser d2 (Messstelle oben)');
   ylabel('d2 (µ)');
   hold on;
   plot(t,filter(o,'d2',Tf),'k');   
   
   subplot(312);
   plot(t,d1,'r');
   title('Änderung Durchmesser d1 (Messstelle unten)');
   ylabel('d1 (µ)');
   hold on;
   plot(t,fd1,'k');
   
   d_1 = rsp(Gs,fn,t); 
   plot(t,d_1,'m');

   subplot(313);
   plot(t,n,'c');
   title('Änderung Drehzahl');
   ylabel('n (1/s)');
   hold on;
   plot(t,fn,'k');
end

