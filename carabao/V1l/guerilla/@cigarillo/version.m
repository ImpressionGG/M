function vers = version(obj,arg)       % CIGARILLO Class Version           
%
% VERSION   CIGARILLO class version / release notes
%
%       vs = version(cigarillo);        % get CIGARILLO version string
%
%    See also: CIGARILLO
%
%--------------------------------------------------------------------------
%
% Release Notes CARALYSE/V1A
% ==========================
%
% - created: 15-Jun-2016 12:52:58
%
% Release Notes CIGARILLO/V1L
% ===========================
%
% - renamed CARALYSE to CIGARILLO (06-Mar-2017)
%
% Known Bugs & Wishlist
% =====================
% - see carabao/version
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('cigarillo/version'));
   idx = max(findstr(path,'@CIGARILLO'));
   vers = path(idx-4:idx-2);
end   
