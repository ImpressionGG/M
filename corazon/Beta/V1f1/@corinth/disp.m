function disp(o)
%
% DISP   Display with details
%
%           disp(o)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH, DISPLAY
%
   oo = opt(o,'detail',true);
   display(oo);
end
