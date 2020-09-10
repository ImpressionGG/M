function open(o)
%
% OPEN   Present a file selection dialog to launch and open a Corazita
%        object which is stored in a .mat file
%
%           open(corazita)
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZITA, load
%
   bag = load(o);                      % bring a dialog to load .mat file
   launch(o,bag);                      % launch a proper shell
end

