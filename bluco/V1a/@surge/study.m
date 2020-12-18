function oo = study(o,varargin)     % Do Some Studies                  
%
% STUDY   Several studies
%
%       oo = study(o,'Menu')     % setup study menu
%
%       oo = study(o,'Study1')   % raw signal
%       oo = study(o,'Study2')   % raw & filtered signal
%       oo = study(o,'Study3')   % filtered
%       oo = study(o,'Study4')   % signal noise
%
%    See also: SURGE, PLOT, ANALYSIS
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@Callback,...
                        @Study1,@Study2,@Study3,@Study4,@Study5,...
                        @Study6,@Study7,@Study8,@Study9,@Study10,...
                        @Tvs,@Cascade);
   oo = gamma(o);                   % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)
   oo = mitem(o,'Surge @ 0° - 550V TVS / 100 Ohm',{@Callback,'Study1'},[]);
   oo = mitem(o,'Surge @ 0° - 550V TVS / 47 Ohm',{@Callback,'Study2'},[]);
   oo = mitem(o,'Surge @ 0° - 550V TVS / 22 Ohm',{@Callback,'Study3'},[]);
   oo = mitem(o,'-');
   oo = mitem(o,'TVS 1.5SMC350CA',{@Callback,'Tvs'},'1.5SMC350CA');
   oo = mitem(o,'TVS 1.5SMC400CA',{@Callback,'Tvs'},'1.5SMC400CA');
   oo = mitem(o,'-');
   oo = CascadeMenu(o);
end
function oo = Callback(o)
   refresh(o,o);                       % remember to refresh here
   oo = current(o);                    % get current object
   cls(o);                             % clear screen
   study(oo);
end

%==========================================================================
% Show
%==========================================================================

function Show(o,phi,Ucl,R,Um,Im,T)
   title = sprintf('Surge @ %g° - %g V TVS @ %g Ohm',phi,Ucl,R);
   
   Pm = Um*Im;
   Pr = Im*Im*R;
   Wd = Um*Im*T/2;      % energy in diode
   Wr = Im*Im*R*T/3;    % energy in resistor
   
   comment = {};
   comment{end+1} = sprintf('TVS Diode: Uclamp = %g V',Ucl);
   comment{end+1} = sprintf('Resistor: R = %g Ohm',R);
   comment{end+1} = ' ';
   comment{end+1} = sprintf('max Voltage: Um = %g V',Um);
   comment{end+1} = sprintf('max Current: Im = %g A',Im);
   comment{end+1} = sprintf('Duration: T = %g us',T*1e6);
   comment{end+1} = ' ';
   comment{end+1} = sprintf('max Diode Power: Pm = Um*Im = %g W',Pm);
   comment{end+1} = sprintf('max Resistor Power: Pr = Im*Im*r = %g W',Pr);
   comment{end+1} = ' ';
   comment{end+1} = sprintf('Energy @ Diode: Wd = %g mJ',o.rd(1000*Wd,0));
   comment{end+1} = sprintf('Energy @ Resistor: Wr = %g mJ',o.rd(1000*Wr,0));
   
   message(o,title,comment);
end

%==========================================================================
% Studies
%==========================================================================

function o = Study1(o)                 % Surge @ 0° - 550V / 100 Ohm   
   phi = 0;                            % 0°
   Ucl = 550;                          % clamping voltage
   R = 100;                            % serial resistance [Ohm]
   Um = 1000;                          % max voltage [V]
   Im = 4.3;                           % max current [A]
   T = 40e-6;                          % duration [us] 
   
   Show(o,phi,Ucl,R,Um,Im,T);
end
function o = Study2(o)                 % Surge @ 0° - 550V / 47 Ohm    
   phi = 0;                            % 0°
   Ucl = 550;                          % clamping voltage
   R = 47;                             % serial resistance [Ohm]
   Um = 1000;                          % max voltage [V]
   Im = 15.2;                          % max current [A]
   T = 60e-6;                          % duration [us] 
   
   Show(o,phi,Ucl,R,Um,Im,T);
end
function o = Study3(o)                 % Surge @ 0° - 550V / 22 Ohm    
   phi = 0;                            % 0°
   Ucl = 550;                          % clamping voltage
   R = 22;                             % serial resistance [Ohm]
   Um = 1000;                          % max voltage [V]
   Im = 4.5;                           % max current [A]
   T = 45e-6;                          % duration [us] 
   
   Show(o,phi,Ucl,R,Um,Im,T);
end

%==========================================================================
% TVS Diodes
%==========================================================================

function PlotTvs(o)                    % 
   tvs = get(o,'tvs');

   u = -tvs.Uclamp:tvs.Uclamp/200:tvs.Uclamp;
   i = tvsdiode(o,u);
   
   Ibmin = tvsdiode(o,tvs.Ubmin);
   Ibmax = tvsdiode(o,tvs.Ubmax);
   
   plot(u,i,'r');
   hold on;
   
   plot([0 0],get(gca,'ylim'),'k');
   plot(get(gca,'xlim'),[0 0],'k');

   hdl = plot(u,i,'r');
   set(hdl,'LineWidth',3);
   
   plot(tvsdiode(o,{i}),i,'y:');   % inverse function test
   
   plot(tvs.Ubmin,Ibmin,'ko', -tvs.Ubmin,-Ibmin,'ko');
   plot(tvs.Ubmax,Ibmax,'ko', -tvs.Ubmax,-Ibmax,'ko');
   
   hdl = text(tvs.Ubmin,Ibmin-0.5,sprintf('Ubmin = %g V',o.rd(tvs.Ubmin,0)));
   set(hdl,'HorizontalAlignment','Right');
  
   hdl = text(tvs.Ubmin,Ibmin-1.0,sprintf('Ibmin = %g uA',o.rd(Ibmin*1e6,1)));
   set(hdl,'HorizontalAlignment','Right');

   hdl = text(tvs.Ubmax,Ibmax+0.5,sprintf('Ubmax = %g V',o.rd(tvs.Ubmax,0)));
   set(hdl,'HorizontalAlignment','Right');
  
   hdl = text(tvs.Ubmax,Ibmax+1.0,sprintf('Ibmax = %g uA',o.rd(Ibmax*1e6,1)));
   set(hdl,'HorizontalAlignment','Right');

   hdl = text(-tvs.Uclamp+50,-tvs.Ipp,sprintf('Pmax = %g W',o.rd(tvs.Pmax,0)));
   set(hdl,'HorizontalAlignment','Left');

   plot(tvs.Uclamp,tvs.Ipp,'ko');
   plot(-tvs.Uclamp,-tvs.Ipp,'ko');
   
   hdl = text(tvs.Uclamp-50,tvs.Ipp, sprintf('Uclamp = %g V, Ipp = %g A',...
              o.rd(tvs.Uclamp,0),o.rd(tvs.Ipp,1)));
   set(hdl,'HorizontalAlignment','Right');
   
   title(sprintf('%s TVS Diode Characteristics',tvs.name));
   ylabel('Current I [A]');
   xlabel('Voltage U [V]');
   grid on
end
function o = Tvs(o)                    % 
   number = arg(o,1);
   o = tvsdiode(o,number);
   PlotTvs(o);
end

%==========================================================================
% Cascade Study
%==========================================================================

function oo = CascadeMenu(o)           % 
   setting(o,{'cascade.Umax'},1333);
   setting(o,{'cascade.Ulow'},650);
   setting(o,{'cascade.Uhigh'},1000);
   setting(o,{'cascade.Rlow'},10);
   setting(o,{'cascade.Rhigh'},10);
   
   oo = mitem(o,'Cascade Study');
   ooo = mitem(oo,'Analyse',{@Callback,'Cascade'});
end
function o = Cascade(o)                % 
   oo = with(o,'cascade');
   Umax = opt(oo,'Umax');
   Uhigh = opt(oo,'Uhigh');
   Ulow = opt(oo,'Ulow');
   Rlow = opt(oo,'Rlow');
   Rhigh = opt(oo,'Rhigh');
   
   plot([0 1],[Umax,Uhigh],'r');
   hold on;
   plot([1 2],[Uhigh,Ulow],'m');
   plot([2 3],[Ulow,0],'b');
   plot([1 1],[0 Uhigh],'k');
   plot([2 2],[0 Ulow],'k');
   
      % voltages & currents
      
   U1 = Umax-Uhigh;
   I1 = U1/Rhigh;
   P1 = U1*I1;
   
   U2 = Uhigh-Ulow;
   I2 = U2/Rlow;
   P2 = U2*I2;
   
   o = text(o,'',[1/6,0.5],10,'center','mid');
   o = text(o,sprintf('I1 = %g A',o.rd(I1,1)));
   o = text(o,sprintf('P1 = %g W',o.rd(P1,0)));

   o = text(o,'',[3/6,0.5],10,'center','mid');
   o = text(o,sprintf('I2 = %g A',o.rd(I2,1)));
   o = text(o,sprintf('P2 = %g W',o.rd(P2,0)));

   o = text(o,'',[5/6,0.5],10,'center','mid');
   o = text(o,sprintf('U2 = %g V',o.rd(Ulow,0)));
end

