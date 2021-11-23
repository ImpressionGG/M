%
% WORK   Get/set a GEM object's work
%
%           bag = work(o)                   % same as bag = struct(o)
%           value = work(o,tag);            % get an object work
%           o = work(o,tag,value);          % set an object work
%
%         Examples:
%            vars = work(o,'var');          % get object's variables
%            o = work(o,'var',vars);        % set object's variables
%            x = work(o,'var.x');           % get object variable x
%            o = work(o,'var.x',x);         % set object variable x
%
%            opts = work(o,'opt');          % get object's options
%            o = work(o,'opt',opts);        % set object's options
%
%            fig = work(o,'figure');        % get object's figure handle
%            o = work(o,'figure',fig);      % set object's figure handle
%
%         Copyright(c): Bluenetics 2020 
%
%         See also: CORAZITA, VAR, OPT, FIGURE
%
