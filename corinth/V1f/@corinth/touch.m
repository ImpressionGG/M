function o = touch (o)
%
% TOUCH   'Touch' object by marking it as both uncanceled and untrimmed
%
%            oo = touch(o)             % mark as uncanceled & untrimmed
%
%         Copyright(c): Bluenetics 2020
%
%         See also: CORINTH, CAN, TRIM
%
   o.work.can = false;
   o.work.trim = false;
end
