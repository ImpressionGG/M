function open(o,path)
%
% OPEN   Present a file selection dialog to launch and open a Corazita
%        object which is stored in a .mat file
%
%           open(corazita)             % open object (select via dialog)
%           open(corazita,path)        % open specific object
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZITA, load
%
   if (nargin == 1)
      bag = load(o);                   % bring a dialog to load .mat file
   else
      bag = load(o,path);              % load specific object
   end
   
   launch(o,bag);                      % launch a proper shell
end

