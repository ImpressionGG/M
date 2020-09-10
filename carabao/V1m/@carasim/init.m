function oo = init(o)
%
% INIT   Initialize a CARASIM object for discrete process simulation
%
%           oo = init(o)
%
   dat.name = '';
   dat.text = '';
   dat.events = {};
   dat.linetype = '-';
   dat.linewidth = 3;
   dat.start = 0;
   dat.stop = 0;
   dat.moti = {};
   dat.idx = [];
   dat.color = 'y';
   dat.kind = 'any';

   oo = data(o,dat);
end
