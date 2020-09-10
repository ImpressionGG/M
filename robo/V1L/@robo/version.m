function out = version(obj)
%
% VERSION  Robo toolkit version and relese notes / known bug list
%
%             vs = version(robo)
%
%          See also: ROBO
%
% Release Notes ROBO/V1L
% ===========================
%
% - ROBO class & class objects introduced (derived SHELL class)
% - VERSION method introduced with release notes / known bugs list
% - Tutorial implemented with intro menu
%
% Known Bugs & ToDo's ROBO/V1L
% ==============================
%
% - none
%
   path = upper(which('robo/version'));
   idx = max(findstr(path,'\@ROBO\VERSION.M'));
   vers = path(idx-3:idx-1);
   
   if (nargout == 0)
      fprintf(['ROBO Toolkit - Version: ',vers,'\n']);
   else
      out = vers;
   end
   return
   
% eof

   