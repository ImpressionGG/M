function obj = dproc(name,text,events)
% DPROC   Create Discrete Process Object
%      
%            dp = dproc('name');         % create discrete process object
%            dp = dproc('name','text');  % provide teext in clear
%            dp = dproc(5);              % delay object
%
%         provide events ('A' and 'B')

%            dp = dproc('name','text',events);   % 
%
%         event syntax
%
%            events = {{'A','B'}};             % (A and B)
%            events = {{'A','B'},{'C','D'}};   % (A and B) or (C and D)
%
%         Addiditonal modifiers:
%
%            ramp(dp)
%            delay(dp)
%            sequence(dp,dp1,dp2,...,dpn)         
%
%   See also   DISCO

   delay = NaN;

   if (nargin < 1) 
      name = '???';
   elseif ~isstr(name)
      delay = name;
      name = '@';
   end
   
   if (nargin < 2) text = ''; end
   if (nargin < 3) events = {}; end

% process events

   if ~iscell(events)
      error('events (arg3) must be a list!');
   end
   for (i=1:length(events))
      el = events{i};
      if ischar(el)
         events{i} = {el};
      elseif ~iscell(el)
         error('events (arg3) must be a list of strings or lists!');
      end
   end
   
% Define default property values

   dat.type = 'any';
   dat.kind = 'any';
   dat.name = name;
   dat.text = text;
   dat.events = events;
   dat.color = 'k';
   dat.linetype = '-';
   dat.linewidth = 3;
   dat.start = 0;
   dat.stop = 0;
   dat.moti = {};
   dat.idx = [];
   
% check

   if(~isstr(name)) error('arg1 must be string!'); end
   if(~isstr(text)) error('arg2 must be string!'); end
   if(~iscell(events)) error('arg3 must be list of string lists!'); end

   for (i=1:length(events))
      evi = events{i};
      if ~iscell(evi)
         error('arg3 must be list of string lists!');
      else
         for (j=1:length(evi))
            if ~isstr(evi{j})
               error('arg3 must be list of string lists!');
            end
         end
      end
   end

% convert to class object

   obj.data = dat;            % data properties
   obj.work = [];             % work properties
   
   obj = class(obj,'dproc');  % convert to class object
   
   if ~isnan(delay)
      obj = wait(obj,delay,events);
   end
   
% eof
