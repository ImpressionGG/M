function onoff = grid(o)
%
% GRID   Switch grid on or off, depending on option 'plot.grid'
%
%             grid(o)                  % set grid on/off (depend on option)
%             onoff = grid(o)          % return grid on/off option
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZON, PLOT, DARK, DONE
%
   onoff = opt(o,'view.grid');
   
   if (nargout > 0)
      return
   end
   
   if isempty(onoff)
      return
   elseif onoff
      grid on;
   else
      grid off;
   end
end