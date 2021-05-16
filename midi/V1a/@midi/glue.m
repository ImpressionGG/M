function oo = glue(car,cdr)
%
% GLUE   Glue together two items
%
   oo = midi('glue');
   oo.data.car = car;
   oo.data.cdr = cdr;
end