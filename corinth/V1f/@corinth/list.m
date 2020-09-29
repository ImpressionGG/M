function lst = list(o)
%
% LIST   Convert corinthian object to list representation
%
%           dlist = list(o)            % convert to list representation
%
%        Copyright/c): Bluenetics 2020
%
%        See also CORINTH, UNIT
%
   lst{1} = '#°#';
   lst{2} = o.data;
   
   par = o.par;
   
   if isfield(par,'unit')
      lst{3} = par.unit;
   else
      lst{3} = '';
   end
   
   if isfield(par,'name')
      lst{4} = par.name;
   else
      lst{4} = '';
   end
   
   if isfield(par,'label')
      lst{5} = par.label;
   else
      lst{5} = '';
   end
   
   if isfield(par,'lim')
      lst{6} = par.lim;
   else
      lst{6} = [];
   end
end
