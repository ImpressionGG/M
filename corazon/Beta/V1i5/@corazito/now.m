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
%       See also: CORAZITO, CLOCK
%
