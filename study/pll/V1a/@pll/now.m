function [date,time] = now(stamp,time)
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
%       To create a compound string containing given date and time the
%       following syntax can be used:
%
%          datetime = o.now(date,time)
%
%       Remark: try datetime = now(o,now) or [date,time] = now(o,now);
%
%       See also: CARALOG, CLOCK
%
   if (nargin < 2)
      stamp = now;
   end
   
   if (nargin <= 1)
      datetime = datestr(stamp);
      date = datetime(1:11);
      time = datetime(13:end);
   else
      date = stamp;
   end
   
   if (nargout <= 1)
      date = [date([1:2,4:6,8:11]),'-',time(1:2),':',time(4:5),':',time(7:8)];
   end
   return
end
