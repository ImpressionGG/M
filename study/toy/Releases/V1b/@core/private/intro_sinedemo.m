% intro_sinedemo
echo on;
%
% THE SINE DEMO
% =============
%
% Let's study our first demo, the Sine Demo. It is not the shortest one
% but as a benefit we can get in touch with some essential power of the
% CHAMELEON toolbox and it's SHELL class. Utilizing the SHELL class we get the
% capability of quick and dirty construction of SHELL functionality like
% choice of parameter options, toggling of boolean settings as well as
% automatic refreshment of graphics with regards to change of settings.
%
% And, as we will see, the SHELL class supports the powerful feature of 
% figure cloning, where the actual graphics and all parameter settings will
% be cloned (inherited) to a copy of the actual figure. Let's just study
% the demo from a user aspect, later on we will jump into details how this
% demo exactly works.
%
   figure(0815);        % open new figure with unique handle
   set(gcf,'position',get(gcf,'position')+[20 -20 0 0]);

   obj = core('play');                                 % construct a CORE
   obj = set(obj,'title','Sine Demo - At a Glance');   % provide title
   menu(obj);                                          % launch a menu
%
% Let's define and initialize two settings: 'color' and 'bullets' 
%
   default('color','r');       % red color as our default setting
   default('bullets',1);       % draw bullets as our default setting
%
% We need to setup a callback which plots the sine curve
%
   cb = 'cls; c=setting(''color''); b=setting(''bullets'');';
   cb = [cb,'t=0:25; y=sin(t*2*pi/max(t));plot(t,y,c);'];
   cb = [cb,'if (b) hold on; plot(t,y,''k.''); end'];
   refresh(gfo,cb,{})  
%
% Now we add a menu item as a child of 'Play' menu to plot the sine
%
   ob1 = mitem(gfo,'Play');   % get handle for mounting at menu 'Play'
   ob2 = mitem(ob1,'Plot Sine Wave',cb,[]);
   mitem(ob1,'-');
%
% We'd like to have choice for 'color' selection
%
   ob2 = mitem(ob1,'Color','','color');
   choice(ob2,{{'Red','r'},{'Blue','b'}},'refresh(gfo)');
%
% And we'd like to toggle the 'bullets' setting
%
   ob2 = mitem(ob1,'Bullets','','bullets');
   check(ob2,'refresh(gfo)');
%
% We also want to see actual parameter setting based on menu click
%
   mitem(ob1,'-');
   mitem(ob1,'Display Settings','setting','');
%
% Let's add an Info menu
%
   menu(obj,'Info');
%
% Finally we want to see what kind of graphics our callback will produce
% Let's watch by invoking the refresh function
%
   refresh(gfo);
%
% Have fun with experiencing the Sine Demo ...
%
[];