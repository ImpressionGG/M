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
;; figure(0815); clf; 
;; set(gcf,'position',get(gcf,'position')+[20 -20 0 0]);
;; shell('play','title','Sine Demo - At a Glance')   % open a shell
%
% We start by definition of frequently used short hands
%
;; LB = 'label'; CB = 'callback'; UD = 'userdata'; RFR = 'refresh(gfo);';
;; CHCR = ['choice(gcbo);',RFR];  CHKR = ['check(gcbo);',RFR];
%
% Let's define and initialize two settings: 'color' and 'bullets' 
%
;; default('color','r');       % red color as our default setting
;; default('bullets',1);       % draw bullets as our default setting
%
% We need to setup a callback which plots the sine curve
%
;; cb = 'cls; c=setting(''color''); b=setting(''bullets'');';
;; cb = [cb,'t=0:25; y=sin(t*2*pi/max(t));plot(t,y,c);'];
;; cb = [cb,'if (b) hold on; plot(t,y,''k.''); end'];
;; cbsetup(gfo,cb)  
%
% Now we add a menu item as a child of 'Play' menu to plot the sine
%
;; men = mount(gfo,'Play');   % get handle for mounting at menu 'Play'
;; itm = uimenu(men,'label','Plot Sine Wave',CB,cb);
;; uimenu(men,LB,'--------------');
%
% We'd like to have choice for 'color' selection
%
;; itm = uimenu(men,LB,'Color',UD,'color');
;; choice(itm,{{'Red','r'},{'Blue','b'}},CHCR);
%
% And we'd like to toggle the 'bullets' setting
%
;; itm = uimenu(men,LB,'Bullets',CB,CHKR,UD,'bullets');
;; check(itm,setting('bullets'));
%
% We also want to see actual parameter setting based on menu click
%
;; uimenu(men,LB,'--------------');
;; uimenu(men,LB,'Display Settings',CB,'setting');
%
% Finally we want to see what kind of graphics our callback will produce
% Let's watch by invoking the refresh function
%
;; refresh(gfo);
%
% Have fun with experiencing the Sine Demo ...
%
[];