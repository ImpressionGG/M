function obj = wait(dp,duration,events)
%
% WAIT   wait modifyer for Discrete Process Object
%      
%            dp = wait(dproc('W1'),duration,events);  % create wait DPO
%            dp = ramp(dproc('A1'));  % duration = 0, events = {} 
%
%        Meaning of arguments
%            duration:    minimum duration of wait step
%            events:      list of names
%
%        Example: wait at least 20 time units and then for events A1 and B5
%
%            dp = wait(dproc('W1'),20,{{'A1','B5'}}));
%
%        Event syntax
%
%           events = {{'A','B'}};             % (A and B)
%           events = {{'A','B'},{'C','D'}};   % (A and B) or (C and D)
%           events = {{'A'},{'B'}};           % (A or B)
%           events = {{'A'}};                 % A only
%
%   See also   DISCO, DPROC

   if (~isa(dp,'dproc')) error('arg1: DPROC object expected!'); end

% Define default property values

   dat = data(dp);
   dat.type = 'wait';
   dat.kind = 'wait';

% defaults

   if (nargin < 2) duration = 0; end
   if (nargin < 3) events = {}; end

% check

   if(~iscell(events)) error('arg3 must be list of strings!'); end

   for (i=1:length(events))
      if ~(isstr(events{i}) || iscell(events{i}))
         error('arg3 must be list of strings or lists!');
      end
   end

% set parameters

   dat.duration = duration;
   dat.events = events;

% create class object

   obj.data = dat;
   obj.work = [];             % work properties
   obj = class(obj,'dproc');  % convert to class object

end
