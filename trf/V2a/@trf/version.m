function vers = version(obj,arg)       % TRF Class Version           
%
% VERSION   TRF class version / release notes
%
%       vs = version(trf);             % get TRF version string
%
%    See also: TRF
%
%--------------------------------------------------------------------------
%
% Release Notes TRF/V1A
% =======================
%
% - created: 20-Jun-2016 17:45:52
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('trf/version'));
   idx = max(findstr(path,'@TRF'));
   vers = path(idx-4:idx-2);
end   
