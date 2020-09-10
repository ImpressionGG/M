function vers = version(obj,arg)       % FITO Class Version           
%
% VERSION   FITO class version / release notes
%
%       vs = version(fito);            % get FITO version string
%
%    Fito was originally created in Jun-2010 based on CHAMELEON toolbox
%    Now FITO has been ported in Aug-2017 to CARABAO toolbox within 3 days.
%
%    See also: FITO
%
%--------------------------------------------------------------------------
%
% Release Notes FITO/V1A
% =======================
%
% - created: 14-Aug-2017 17:48:40
% - backup carabao.v1l.bak118 (16-Aug-2017)
%
% Known bugs & wishlist
% =========================
% - some german texts in Principles menu need to be translated to English
%
%--------------------------------------------------------------------------
%
   path = upper(which('fito/version'));
   idx = max(findstr(path,'@FITO'));
   vers = path(idx-4:idx-2);
end   
