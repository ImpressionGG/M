% intro_addmenus
figure(0815);
echo on;
%
% ADD SOME MENUS TO OUR PLAY SHELL
% ================================
%
% Let's add some menus to our play shell
%

;; men = mount(gfo,'Play');    % get handle for mounting at menu 'Play'
;; setting('color','r');       % red color
;; cb = 't=0:100; c = setting(''color''); plot(t,sin(t*pi/50),c)';
;; itm = uimenu(men,'label','Plot Sine Wave','callback',cb);
%
