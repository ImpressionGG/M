function oo = unit(o,sym)
%
% UNIT   Create a corinthian unit object
%
%           oo = unit(o,'s')           % second
%           oo = unit(o,'m')           % meter
%           oo = unit(o,'m/s')         % meter per second
%
%        Copyright/c): Bluenetics 2020
%
%        See also CORINTH, ADD, TIMES
%
   switch sym
      case 's'
         list = {'#' 1 sym '' 'time' []};
      case 'm'
         list = {'#' 1 sym '' 'distance' []};
      case 'm/s'
         list = {'#' 1 sym '' 'velocity' []};
      otherwise
         error('unsupported unit');
   end
   
   oo = corinth;
   oo.type = 'double';
   
   oo.par.unit = list{3};
   oo.par.name = list{4};
   oo.par.label = list{5};
   oo.par.lim = list{6};

   oo.data = list{2};
end
