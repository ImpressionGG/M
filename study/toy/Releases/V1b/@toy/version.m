function out = version(obj)
%
% VERSION   Get version of Quantum Toy Toolbox
%
%              vs = version(toy);    % get version string
%              version(toy);         % type also release notes / known bugs
%
%           See also: TOY, CORE
%---------------------------------------------------------------------------
%
% Release Notes Toy/V1A
% ==========================
%
% - Build basic methods and basic demo features
% - setup TOY demos with a menu shell
% - add a hotkey functionality to navigate through TOY demos
%
% Known Bugs
% ==========
% 
% - navigation through demos (with page up/page down) is not fully working
% - short cuts with subsref() are not working inside of functions
%
   path = upper(which('toy/version'));
   idx = max(strfind(path,'\@TOY\VERSION.M'));
   vers = path(idx-3:idx-1);
   
   if (nargout == 0)
      help toy/version
      line = '-------------------';
      fprintf([line,line,line,line,'\n']);
      fprintf(['Quantum Toy Toolbox - Version: ',vers,'\n']);
      fprintf([line,line,line,line,'\n']);
   else
      out = vers;
   end
   return
end
