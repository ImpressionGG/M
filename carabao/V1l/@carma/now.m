function [date,time] = now(stamp)
%
% NOW   Return date and time (strings) of 'now' (static method)
%
%          datetime = o.now
%          [date,time] = o.now
%
%       Now can also be used to convert a time stamp in datenum format into
%       a readable date/time format, or to split into date and time.
%
%          datetime = o.now(stamp)
%          [date,time] = o.now(stamp)
%
%       Remark: try datetime = now(o,now) or [date,time] = now(o,now);
%
%       See also: CARALOG, CLOCK
%
   if (nargin < 2)
      stamp = now;
   end
   
   datetime = datestr(stamp);
   date = datetime(1:11);
   time = datetime(13:end);
   
   if (nargout <= 1)
      date = [date,' @ ',time];
   end
   return
end
