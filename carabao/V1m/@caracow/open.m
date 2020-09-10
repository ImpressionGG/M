function open(o)
%
% OPEN   Present a file selection dialog to launch and open a Caracow
%        object which is stored in a .mat file
%
%           open(caracow)
%
%        See also: CARACOW, load
%
   bag = load(o);                      % bring a dialog to load .mat file
   launch(o,bag);                      % launch a proper shell
end

