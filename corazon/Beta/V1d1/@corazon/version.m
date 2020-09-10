function oo = version(o,varargin)                                      
%
% VERSION   CORAZON toolbox version / release notes
%
%    Print CORAZON release notes / bug list or get CORAZON version
%
%       vs = version(corazon);         % get CORAZON version string
%       version(corazon);              % type release notes / known bugs
%
%    See also: CORAZON
%    Copyright (c): Bluenetics 2020 
%
   if (nargout == 0)
      Version(o,nargin)
   else
      oo = Version(o,nargin);
   end
end

%==========================================================================
% Version Work Horse
%==========================================================================

function oo = Version(o,nin)           % Actual Version Work Horse     
   path = upper(which('corazon/version'));
   path = upath(o,path);
   idx = max(findstr(path,'/@CORAZON/VERSION.M'));
   vers = path(idx-3:idx-1);
   
   if (nargout == 0 || nin > 1)
      clc
      %help corazon/version
      type corazon/version
      line = '----------------------------------------';
      fprintf('%s%s\n',line,line);
      fprintf('CORAZON Toolbox - Version: %s\n',vers);
      fprintf('%s%s\n',line,line);
   else
      oo = vers;
   end
end   

%==========================================================================
% Known Bugs & ToDo's
%==========================================================================

function KnownBugsAndRoadmap           % Just a Dummy Function         
%
% Known Bugs
% ==========
%
% - no known bugs so far :-)
%
% Roadmap
% =======
%
% - default support for import/export of CSV files
% - easier dynamic menu management:
% -    a) move 'dynamic(o)' from shell to method!
% -    b) make shell/Dynamic an obsolete function (no update required)
% - version core for better support of version method of rapid toolboxes
%
end

%==========================================================================
% Release Notes
%==========================================================================

function VersionV1A                                                    
%--------------------------------------------------------------------------
%
% Release Notes Corazon/V1A
% =========================
%
% - Nice functionality, including rapid prototyping shell - bug: cannot
%   paste filt object into shell - bug: style menu of weird/cube/ball objs
%   to be located under Select
% - bug fixed: cannot paste filt object into shell
% - bug fixed: style menu of weir/cube/ball objects to be located under 
%   Select
%
end

function VersionV1B                                                    
%--------------------------------------------------------------------------
%
% Release Notes Corazon/V1B
% =========================
%
% - bug fixed in corazon/rapid: wrong arg list passing in generated
%   study/Callback 
% - made corazito/call method tolerant against empty refresh callback
%
end

function VersionV1C                                                    
%--------------------------------------------------------------------------
%
% Release Notes Corazon/V1C
% =========================
%
% - bug fixed in corazon/rapid: in plot/Callback assignment oo = o must
%   be executed before checking empty list. Otherwise method crashes e.g.
%   if all objects are cleared and refresh calls plot.
%
end

function VersionV1D                                                    
%--------------------------------------------------------------------------
%
% Release Notes Corazon/V1D
% =========================
%
% - Introduction of comma separated tags to CORAZITA method prop() and
%   CORAZON methods get(), set(), data(), var() and opt() provides syn-
%   tactic sugar for multiple set/get.
%
% - CORASIM class added to support discretisation of continuous time
%   state space models and to simulate and plot both continuous time and
%   discretized state space models. CORASIM provides a shell to study
%   step and ramp responses.
%
% - Improved corazita/manage method to be tolerant against non-character
%   and non function_handle arguments
%
% - new corazon/paste syntax for single object pasting with implicite
%   inheritance of launch function (syntactic sugar)
%
% - extend corazon/shell with many hidden pre-defined dynamic menus which
%   can be activated with plugin functionality. Such plugin functionality 
%   is demonstrated by corazon/sample plugin
%
% - modify corazon/plot to understand scalar subplot indicator and to 
%   handle hold option
%
% - introduction of corazon/enable method for easy enable/disable of menu
%   items depending on a general condition or depending on a basket's type
%   list
%
% - corazon/basket extended with additional syntax for typelist check, to
%   be designed in compatibility with corazon/enable syntax
%
% - cleanup and better internal program structure for corazon/plot method,
%   using a local Plot() function to deal with single (non container) ob-
%   jects, and using a standardized local Basket() function to deal with
%   basket lists. This new structure allows the simplified approach that 
%   plot core functions can be written to deal with simple (non container)
%   objects, while the Basket function deals with the looping through the
%   basket list.
%
% - introduction of figure size menu and figure fixing. Bug fix of figure
%   fixing, while obsoleting window fix menu item in Info/Debug menu
%
% - Improve corazon/menu/End to support a menu/End plug point which can be
%   used for general plugins. The menu/End plug point adopts dynamically to
%   the shell objet class.
%
% - Add corazon/simple plugin for simple plugin demonstration. This plugin
%   triggers only on the menu/End and curret/Select plug points. Tested
%   with corazon/shell, corasim/shell and spm/shell.
%
% - Add heading method to provide a header for plots
%  
%
% Change Log:
%
% - extension of corazita/set to support comma separated tags
% - extension of corazita/get to support comma separated tags
% - extension of corazita/prop to support comma separated tags
% - extension of corazita/var to support comma separated tags
% - extension of corazon/data to support comma separated tags
% - corazita/manage method be tolerant for non empty arg list which
%   does not have char string or function handle as first arg
% - corasim class added for simulation objects
% - new paste syntax to inherit launch function
% - plugin functionality
% - adopt corazon/rapid to provide plug points
% - add more powerful corazon/opt with comma separated tags
% - corazon/plot modified to understand scalar subplot indicator
% - corazon/plot to support hold option
% - corazon/basket to support typelist check
% - standard structure for plot/Basket
% - transform corazon/plot (better style and structure)
% - introduce figure size menu and figure fixing
% - add enable() method to enable/disable menu items
% - add Analyse menu to sample plugin 
% - add general plugins to corazon/sample
% - add corazon/simple plugin for simple plugin demonstration
% - add mitem(o,'') functionality to clear separator activation flag
% - add additional plug point in corazon/current to trigger simple plugin
%   menu rebuild after selection of object
% - bug fixed: creation of SMP object does not refresh Plot menu (menu/End
%   is not rebuilt after reselection of objects! solution: additional 
%   plug point in current/Select
% - make corazon/simple plugin complete
% - had to modify corasim/Plot function to support input plotting
% - adopt corazon/sample plugin to trigger also on current/Select plug
%   point
% - add simulation parameter menu in simple plugin
% - bug fix: Multi color corazito/plot did not support bullets 
% - add heading method
%
end
