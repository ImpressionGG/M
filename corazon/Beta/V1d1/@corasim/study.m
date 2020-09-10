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
%    See also: CORASIM, PLOT, ANALYSIS
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@Callback,...
                        @Study1,@Study2,@Study3,@Study4,@Study5,...
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
   oo = mitem(o,'Study5',{@Callback,'Study5'},[]);
   oo = mitem(o,'Study6',{@Callback,'Study6'},[]);
   oo = mitem(o,'Study7',{@Callback,'Study7'},[]);
   oo = mitem(o,'Study8',{@Callback,'Study8'},[]);
   oo = mitem(o,'Study9',{@Callback,'Study9'},[]);
   oo = mitem(o,'Study10',{@Callback,'Study10'},[]);
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
