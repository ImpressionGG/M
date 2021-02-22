function vers = version(o,arg)         % SPM Class Version             
%
% VERSION   MINISPM class version / release notes
%
%       vs = version(spm);            % get SPM version string
%
%    See also: MINISPM
%
%--------------------------------------------------------------------------
%
% Release Notes MINISPM/V1E
% =========================
%
% - start of mini SPM toolbox
% - critical analysis
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('minispm/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@MINISPM'));
   vers = path(idx-4:idx-2);
end
