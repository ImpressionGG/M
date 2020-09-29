function bag = zip(o)
%
% ZIP   Compress CORINTH object into a bag or unpack from bag. Ignore tag,
%       parameter and work info.
%
%          bag = zip(o)
%
%       Copyright(c): Bluenetics 2020
%
%       See also CORINTH, UNZIP
%
   bag = o.data;
   bag.type = o.type;
end