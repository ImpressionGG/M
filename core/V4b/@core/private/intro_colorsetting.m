% intro_colorsetting
figure(0815);
echo on;
%
% ADD A MENU TO SELECT A COLOR
% ============================
%
% Let's add a menu to our play shell which allows to select a color
%
   ob1 = mitem(gfo,'Play');    % add a rolldown menu header item 'Play'

   setting('color','r');       % red color as our default setting
%
   ob2 = mitem(ob1,'Color','','color');
   choice(ob2,{{'Red','r'},{'Blue','b'}},'refresh(gfo)');
%
