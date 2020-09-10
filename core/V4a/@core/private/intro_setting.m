% intro_setting
figure(0815);                 % make 0815 figure our current figure
echo on;
%
% CONTEXT SETTINGS
% ================
%
% Let's add some simple functionality to our 'Play Shell'! We want to in-
% troduce a context setting for a plot color, where we identify this
% setting by identifier 'color'. A simple possibility to introduce a
% context setting can be done by just defining its default value. We should
% be aware that our 'Play Shell' has to be the active figure when we exe-
% cute the next command(s) since context settings 'belong' to  figures,
% and when we want to access or manipulate settings of a figure then 
% we have to make sure that the regarded figure is always the active one.
%
   default('color','r');  % introduce default value 'r' for 'color' setting
%
% This command introduces a context setting 'color' by defining its de-
% fault value 'r' (red). We can check the current value by calling the 
% SETTING function.
%
   setting('color')
%
% As we can see the setting of 'color' has actually the value 'r'. It
% should be noted that further calls to DEFAULT addressing the same iden-
% tifier for the context setting will have no effect, since the addressed
% setting has already a well defined value. Study the next commands:
%
   default('color','g');  % no effect since 'color' setting already defined
   setting('color')
%
% To change a context setting we use function SETTING with a slightly modi-
% fied syntax:
%
   setting('color','g');  % change 'color' setting to value 'g' (green)
   setting('color')       % this command confirms that new value is 'g'
%
[];