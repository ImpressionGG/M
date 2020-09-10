function ok = carabased(name)
%
% CARABASED   Is argument a mountable CARABASE folder?
%
%    Return boolean result whether input argument belongs to the list of
%    additional mountable folders for CARABASE database system. 
%
%       ok = carabased(name);
%
%    Remark: if you change this function make sure that the function has
%    a short execution time, since it is called many times.
%
%    Performance: 10 µs
%
%    See also: CARABASE, CARABASE/MOUNTABLE
%
   switch name
      case {'MASCHINENDATEN','MASCHINENDATEN_2.0'};
         ok = true;
      otherwise
         ok = false;
   end
end
