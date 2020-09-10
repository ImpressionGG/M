function oo = simple(o,varargin) % simple shell(v1c/@espresso/simple.m)
   [func,oo] = manage(o,varargin,@Shell,@File,@Play,@Plot);
   oo = func(oo);                % dispatch to local function
end
%======================================================================
% Shell Setup
%======================================================================
function o = Shell(o)                  % Shell Setup                   
   o = Init(o);                        % initialize object
   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   oo = Play(o);                       % add Play menu
   o = menu(o,'End');                  % end menu setup
end
function o = Init(o)                   % Object Initializing           
   o = dynamic(o,false);               % provide as a static shell
   o = launch(o,mfilename);            % setup launch function
   o = provide(o,'par.title','Simple Shell');
   o = provide(o,'par.comment',{'A simple shell to play'});
   o = refresh(o,{@menu,'About'});     % provide refresh callback
end
%======================================================================
% File Menu
%======================================================================
function oo = File(o)                  % File Menu                     
   oo = menu(o,'File');                % add File menu
end
%======================================================================
% Play Menu
%======================================================================
function oo = Play(o)                  % Play Menu
   setting(o,{'play.grid'},false);     % no grid by default
   setting(o,{'play.color'},'r');      % default setting for color

   oo = mhead(o,'Play');               % add Play menu header
   ooo = mitem(oo,'Sin',{@Plot,'sin'});% add Sin menu item
   ooo = mitem(oo,'Cos',{@Plot,'cos'});% add Cos menu item
   ooo = mitem(oo,'-');                % add separator
   ooo = mitem(oo,'Grid',{},'play.grid');
   check(ooo,{});                      % add check functionality
   ooo = mitem(oo,'Color',{},'play.color');
   choices = {{'Red','r'},{'Green','g'},{'Blue','b'}};
   choice(ooo,choices,{});             % add choice functionality
end
function o = Plot(o)                   % Plot Callback 
   mode = arg(o,1);                    % 1st arg: plot mode
   refresh(o,{@Plot,mode});            % update refresh callback 
   col = opt(o,{'play.color','k'});    % get color option (default 'k')
   cls(o);                             % clear screen
   fct = eval(['@',mode]);             % make function handle
   plot(0:0.1:10,fct(0:0.1:10),col);   % plot sin or cos curve
   if opt(o,{'play.grid',0})           % grid option set? 
      grid on;                         % show grid
   end
end
