% intro_colorsetting
figure(0815);
echo on;
%
% ADD A MENU TO SELECT A COLOR
% ============================
%
% Let's add a menu to our play shell which allows to select a color
%
;; men = mount(gcfo,'Play');   % get handle for mounting at menu 'Play'

;; setting('color','r');       % red color as our default setting
%
;; itm = uimenu(men,'label','Color','userdata','color');
;; choice(itm,{{'Red','r'},{'Blue','b'}},CHCR);
%
