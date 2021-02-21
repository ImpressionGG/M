function oo = done(o)
%
% DONE   Done with diagram - calls grid(o) method and calls dark(o,'Axes')
%        to refresh dark mode if selected
%
%           done(o)                  % set grid on/off (depend on option)
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZON, PLOT, DARK, GRID, CLS
%
   grid(o);                          % draw grid if selected
   dark(o,'Axes');                   % refresh dark mode for axes                             
end