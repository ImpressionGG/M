function oo = unzip(o,bag)
%
% UNZIP  Uncompress CORINTH object from bag. Ignore tag, parameter and
%        work info.
%
%           oo = unzip(o,bag)
%
%        Copyright(c): Bluenetics 2020
%
%        See also CORINTH, ZIP
%
   oo = o;
   oo.type = bag.type;
   oo.data = rmfield(bag,'type');
end