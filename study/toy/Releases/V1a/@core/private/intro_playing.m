% intro_playing
echo on;
%
% PLAYING WITH SINE DEMO
% ===========================
%
% Perform the following actions:
%
%    1) Select the 'Play/Display Settings' menu item. It shows 3 settings
%    which initially look:
%
%       shell: [1x1 struct]
%       color: 'r'
%       bullets: 1
%
%    We don't care about the first setting (shell) which is used internally
%    by the SHELL class. The other two settings 'color' and 'bullets' are
%    defined by ourself (user defined), and we can watch the values
%    changing whenever we select menu items 'Play/Color' or 'Play/Bullets'.
%
%    2) Select a color (Play/Color). You will see that the check mark, which is initial-
%    ly with menu item 'Red', moves to the selected color
%
%    3) Toggle the 'Bullets' menu entry. You will see that the check mark
%    in the menu entry alternatively disappears and reappears.
%
%    4) Select 'Play/Plot Sine Wave' - a sine wave will be displayed with
%    our selected color and, according to our 'Bullets' setting, will 
%    either show bullets or not.
%
%    5) Whenever we change one of the settings (Bullets, Color) the plot
%    will be refreshed according to the updated settings. This auto re-
%    freshing capability is one of the powerful features supported by the
%    SHELL class
%
%    6) In addition we see a 'File' menu, which has been offered somehow
%    'automatically' (without particular specification from our side). We
%    will investigate the 'File' features in the next section.
%    
[];
