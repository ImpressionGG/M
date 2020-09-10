function o = work(o,tag,value)
%
% WORK   Get/set a QUARK©s object's work
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
%         Code lines: 16
%
%         See also: QUARK, VAR, OPT, FIGURE
%
   if (nargin == 1)
      o = o.wrk;
   elseif (nargin == 2)
      if ischar(tag)
         if isempty(strfind(tag,'.'))            
             if isfield(o.wrk,tag)
                 o = o.wrk.(tag);
             else
                 o = [];
             end
         else
            o = eval(['o.wrk.',tag],'[]');
         end
      elseif isstruct(tag)
         o.wrk = tag;
      elseif isempty(tag)
         o.wrk = [];
      end
   elseif (nargin == 3)
      if isempty(strfind(tag,'.'))            
         o.wrk.(tag) = value;
      else
         eval(['o.wrk.',tag,' = value;']);
      end
   else
      error('1, 2 or 3 input args expected!')
   end
end
