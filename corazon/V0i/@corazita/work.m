function o = work(o,tag,value)
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
   if (nargin == 1)
      o = o.work;
   elseif (nargin == 2)
      if ischar(tag)
         if isempty(findstr(tag,'.'))            
             if isfield(o.work,tag)
                 o = o.work.(tag);
             else
                 o = [];
             end
         else
            o = eval(['o.work.',tag],'[]');
         end
      elseif isstruct(tag)
         o.work = tag;
      elseif isempty(tag)
         o.work = [];
      end
   elseif (nargin == 3)
      if isempty(findstr(tag,'.'))            
         o.work.(tag) = value;
      else
         eval(['o.work.',tag,' = value;']);
      end
   else
      error('1, 2 or 3 input args expected!')
   end
end
