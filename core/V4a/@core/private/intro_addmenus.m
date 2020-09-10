% intro_addmenus
figure(0815);
echo on;
%
% ADD SOME MENUS TO OUR PLAY SHELL
% ================================
%
% Let's add some menus to our play shell
%

   ob1 = mitem(gfo,{'Play'});  % seek menu item 'Play'
   setting('color','r');       % red color
   cb = 't=0:100; c = setting(''color''); plot(t,sin(t*pi/50),c)';
   ob2 = mitem(ob1,'Plot Sine Wave',cb);
%
