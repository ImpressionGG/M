function grid(o)
%
% GRID   Switch grid on or off, depending on option 'plot.grid'
%
%             grid(o)     % set grid on/off (depending on option)
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZON, PLOT
%
   onoff = opt(o,'plot.grid');
   if isempty(onoff)
      return
   elseif onoff
      grid on;
   else
      grid off;
   end
end