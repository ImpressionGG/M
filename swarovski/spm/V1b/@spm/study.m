function oo = study(o,varargin)     % Do Some Studies
%
% STUDY   Several studies
%
%       oo = analysis(o,'Menu')     % setup study menu
%
%       oo = analysis(o,'Sum')      % surface plot
%       oo = analysis(o,'Diff')     % display histogram
%
%    See also: SPM, PLOT, ANALYSIS
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@Callback,...
                        @Study1,@Study2,@Study3,@Study4,@Study5,@Study5a,...
                        @Study6,@Study7,@Study8,@Study9,@Study10);
   oo = gamma(o);                   % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)
   oo = mitem(o,'Raw',{@Callback,'Study1'},[]);
   oo = mitem(o,'Raw & Filtered',{@Callback,'Study2'},[]);
   oo = mitem(o,'Filtered',{@Callback,'Study3'},[]);
   oo = mitem(o,'Noise',{@Callback,'Study4'},[]);
   oo = mitem(o,'-');
   oo = MenuSinWithStatic(o);

   oo = mitem(o,'Study6',{@Callback,'Study6'},[]);
   oo = mitem(o,'Study7',{@Callback,'Study7'},[]);
   oo = mitem(o,'Study8',{@Callback,'Study8'},[]);
   oo = mitem(o,'Study9',{@Callback,'Study9'},[]);
   oo = mitem(o,'Study10',{@Callback,'Study10'},[]);
end

function oo = MenuSinWithStatic(o)
   setting(o,{'sws.f'},50);
   setting(o,{'sws.noise'},0.1);
   setting(o,{'sws.grid'},1);
   setting(o,{'sws.color'},'r');
   
   oo = mitem(o,'SIN with Static');
   ooo = mitem(oo,'Display',{@Callback,'Study5a'},'Display');
   ooo = mitem(oo,'Plot',{@Callback,'Study5a'},'Plot');
   ooo = mitem(oo,'Paste',{@Callback,'Study5a'},'Paste');
   ooo = mitem(oo,'-');

   ooo = mitem(oo,'Parameter');
   oooo = mitem(ooo,'Frequency',{},'sws.f');
          choice(oooo,[25,50,100],{}); % empty callback for refresh after change of parameter
   oooo = mitem(ooo,'Noise',{},'sws.noise');
          charm(oooo,{});              % empty callback for refresh ...
   oooo = mitem(ooo,'Grid',{},'sws.grid');
          check(oooo,{});              % empty callback for refresh ...
   oooo = mitem(ooo,'Color',{},'sws.color');
          choice(oooo,{{'Red','r'},{'Green','g'},{'Blue','b'}},{});
end

function oo = Callback(o)
   refresh(o,o);                       % remember to refresh here
   oo = current(o);                    % get current object
   cls(o);                             % clear screen
   study(oo);
end

%==========================================================================
% Studies
%==========================================================================

function o = Study1(o)                 % Study 1: Raw Signal
   t = cook(o,':');
   x = cook(o,'x');
   y = cook(o,'y');

   subplot(211);
   plot(with(corazon(o),'style'),t,x,'r');
   title('Raw Signal X');
   xlabel('t');

   subplot(212);
   plot(with(corazon(o),'style'),t,y,'b');
   title('Raw Signal Y');
   xlabel('t');
end
function o = Study2(o)                 % Study 2: Raw & Filtered Signal
   t = cook(o,':');
   [x,xf] = cook(o,'x');
   [y,yf] = cook(o,'y');

   subplot(211);
   plot(t,x,'r');  hold on;
   plot(with(corazon(o),'style'),t,xf,'k');
   title('Raw & Filtered Signal X');
   xlabel('t');

   subplot(212);
   plot(t,y,'r');  hold on;
   plot(with(corazon(o),'style'),t,yf,'k');
   title('Raw & Filtered Signal Y');
   xlabel('t');
end
function o = Study3(o)                 % Study 3: Filtered Signal
   t = cook(o,':');
   [~,xf] = cook(o,'x');
   [~,yf] = cook(o,'y');

   subplot(211);
   plot(with(corazon(o),'style'),t,xf,'r');
   title('Filtered Signal X');
   xlabel('t');

   subplot(212);
   plot(with(corazon(o),'style'),t,yf,'b');
   title('Filtered Signal Y');
   xlabel('t');
end
function o = Study4(o)                 % Study 4: Noise
   t = cook(o,':');
   [x,xf] = cook(o,'x');
   [y,yf] = cook(o,'y');

   subplot(211);
   plot(with(corazon(o),'style'),t,x-xf,'r');
   title('Noise Signal X');
   xlabel('t');

   subplot(212);
   plot(with(corazon(o),'style'),t,y-yf,'b');
   title('Noise Signal Y');
   xlabel('t');
end
function o = Study5(o)                 % Study 5
   message(o,'Study 5');
end
function o = Study5a(o)                 % Study 5
      % usually the first statement is a refresh(o,o) statement which 
      % indicates that the current function should be invoked for refresh
      % in the next future

   %refresh(o,o); % refresh this callback from now on
   
      % but in this context the call refresh(o,o) is redundat, since
      % we have a general Callback() function which executes refresh(o,o)
      % at a central location
      
   mode = arg(o,1);
   
      % we could get parameter settings as shown below:
      %
      %    f = setting(o,'sws.f');
      %    noise = setting(o,'sws.noise');
      %    grd = setting(o,'sws.grid');
      %    color = setting(o,'sws.color');
      %
      % the better style is to use options, also providing defaults ...
      
   f = opt(o,{'sws.f',50});
   noise = opt(o,{'sws.noise',0.1});
   grd = opt(o,{'sws.grid',1});
   color = opt(o,{'sws.color','k'});
   
   text1 = sprintf('Frequency = %g Hz',f);
   text2 = sprintf('Noise = %g',noise);   

   t = 0:1/f/1000:1/25;
   x = sin(2*pi*f*t) + noise*randn(size(t));
   y = cos(2*pi*f*t) + noise*randn(size(t));
 
   switch mode
      case 'Display'
         message(o,'Display SIN with Static',{text1,text2});
      case 'Plot'
         cls(o);
         
         subplot(211);
         plot(t,x,[color,'-']);
         set(gca,'xlim',[min(t),max(t)]);
         title(sprintf('%s | %s',text1,text2));
         xlabel('time / s');
         ylabel('x');
         if grd
            grid on;
         end
         
         subplot(212);
         plot(t,y,[color,'-']);
         set(gca,'xlim',[min(t),max(t)]);
         title(sprintf('%s | %s',text1,text2));
         xlabel('time / s');
         ylabel('y');
         if grd
            grid on;
         end

         shg;
      case 'Paste'
         oo = spm('smp');
         oo.data.t = t;
         oo.data.x = x;
         oo.data.y = y;
         
         refresh(o,{});   % clear refresh function, to prevent come again
         paste(oo);
   end
end
 
function o = Study6(o)                 % Study 6
   message(o,'Study 6');
end
function o = Study7(o)                 % Study 7
   message(o,'Study 7');
end
function o = Study8(o)                 % Study 8
   message(o,'Study 8');
end
function o = Study9(o)                 % Study 9
   message(o,'Study 9');
end
function o = Study10(o)                % Study 10
   message(o,'Study 10');
end
