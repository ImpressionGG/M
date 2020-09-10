% intro_setting
figure(0815);                 % make 0815 figure our current figure
echo on;
%
% SHELL SETTINGS
% ==============
%
% Let's add some simple functionality to our 'Play Shell'! We want to in-
% troduce a SHELL setting for a plot color, where we identify this
% setting by identifier 'color'. A simple possibility to introduce a SHELL
% setting can be done by just defining its default value. We should be 
% aware that our 'Play Shell' has to be the active figure when we execute
% the next command(s) since SHELL settings 'belong' to SHELL figures, and
% when we want to access or manipulate settings of a SHELL figure then we
% have to make sure that the regarded figure is always the active figure.
%
;;default('color','r');  % introduce default value 'r' for 'color' setting
%
% This command introduces a SHELL setting 'color' by defining its de-
% fault value 'r' (red). We can check the current value by calling the 
% setting() function.
%
;;setting('color')
% As we can see the setting of 'color' has actually the value 'r'. It
% should be noted that further calls to default() addressing the same iden-
% tifier for the SHELL setting will have no effect, since the addressed
% SHELL setting has already a well defined value. Study the next commands:
%
;;default('color','g');  % no effect since 'color' setting already defined
;;setting('color')
%
% To change a SHELL setting we use function setting() with a slight modi-
% fied syntax:
%
;;setting('color','g');  % change 'color' setting to value 'g' (green)
;;setting('color')       % this command confirms that new value is 'g'
%
[];