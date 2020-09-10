function out = version(obj)
%
% VERSION   Get version of a CORE object class
%
%              vs = version(core);   % get version string
%              version(core);        % type also release notes / known bugs
%
%           See also: CORE
%
%--------------------------------------------------------------------------
%
% Release Notes Core/V4A
% ===========================
%
% - configure as an independent toolbox
% - edit version in info menu added
% - move through menu tree functionality added to core/mitem 
% - Backup Core.V4a.Bak6, Toy.V4a.Bak6
% - CORE/TOPIC added (building block functions for tutorial); slight 
%   modification: topic does no more install a view handler (moved to
%   NAVIGATION) and does no more display topic & task (moved to TUTOR)
% - CORE/TUTORIAl added (building block functions for tutorial)
% - CORE/NAVIGATION added (simple navigation functionality)
% - CORE/VIEW added (simple view handler providing basic navigation)
% - Backup Core.V4a.Bak8, Toy.V4a.Bak8
% - some fine tunings of CORE/TUTOR
% - Backup Core.V4a.Bak9, Toy.V4a.Bak9
% - CORE/TUTOR function fine tuned (Display)
% - CORE/CALL adopted to support syntax call(obj,'@')
% - menu item HowTo added in INFO menu
% - Backup Core.V4a.Bak10, Toy.V4a.Bak10
% - Backup Core.V4a.Bak11, Toy.V4a.Bak11
% - Backup Core.V4a.Bak12, Toy.V4a.Bak12
% - Backup Core.V4a.Bak13, Toy.V4a.Bak13
%
% Known Bugs & ToDo's
% ===================
%
% - no known bugs
%
   path = upper(which('core/version'));
   idx = max(findstr(path,'\@CORE\VERSION.M'));
   vers = path(idx-3:idx-1);
   
   if (nargout == 0)
      help core/version
      line = '--------------------';
      fprintf([line,line,line,line,'\n']);
      fprintf(['CHAMELEON Toolbox - Version: ',vers,'\n']);
      fprintf([line,line,line,line,'\n']);
   else
      out = vers;
   end

%    if (nargout == 0)
%       version(core)
%    else
%       out = version(core);
%    end
   return
end   
   