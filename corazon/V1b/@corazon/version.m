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

function KnownBugsAndTodos             % Just a Dummy Function         
%
% Known Bugs & ToDo's & Wishes
% ============================
%
% - no known bugs so far :-)
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
