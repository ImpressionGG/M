function vers = version(o,arg)       % SPM Class Version
%
% VERSION   SPM class version / release notes
%
%       vs = version(spm);             % get SPM version string
%
%    See also: SPM
%
%--------------------------------------------------------------------------
%
% Release Notes SPM/V1A
% =======================
%
% - created: 21-Apr-2020 08:27:43
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('spm/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@SPM'));
   vers = path(idx-4:idx-2);
end
