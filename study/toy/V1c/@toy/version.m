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
% Release Notes Toy/V4A
% ==========================
%
% - move through menu tree functionality added to core/mitem 
% - bug fixed: window exits after advancing to File menu
% - bug fixed: navigation through demos (with page up/page down) is not
%   fully working.
% - bug fixed: info/home does not work
% - Backup Core.V4a.Bak6, Toy.V4a.Bak6
% - bug fixed: toy/view does not work, especially after reselecting a menu
%   item with the mouse
% - test menu introduced
% - Backup Core.V4a.Bak7, Toy.V4a.Bak7 - quite a good version!!!
% - TOY/TOPIC replaced by CORE/TOPIC
% - call to topic at begin of package handler replaced by call to
%   navigation
% - navigation functionality of TOY/VIEW moved to CORE/VIEW
% - Backup Core.V4a.Bak8, Toy.V4a.Bak8
% - some fine tunings of the deno menu
% - Backup Core.V4a.Bak9, Toy.V4a.Bak9
% - Posion operator added (methods TOY/OPERATOR & TOY/DISPLAY)
% - Backup Core.V4a.Bak10, Toy.V4a.Bak10
% - added natural operator(H,'#') => TOY/OPERATOR & TOY/DISPLAY
% - TOY/TOY: added quantum coin, quantum die and quantum game space
%   creation
% - TOY/CSPACE introduced to support extended space type
% - TOY/RESHAPE added to deal with property vector matrices in one single
%   central function
% - MATRIX, VECTOR, SUBSREF, PROPERTY adopted to deal with CSPACE
%   functionality
% - Backup Core.V4a.Bak11, Toy.V4a.Bak11
% - Provided test routines for extended space
% - Backup Core.V4a.Bak12, Toy.V4a.Bak12
% - More test routines for extended space provided
% - Backup Core.V4a.Bak13, Toy.V4a.Bak13
%
% Known Bugs / Wish List
% ======================
% 
% - need to adopt TOPIC/VIEW to work with CORE/VIEW navigation
%   functionality
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
