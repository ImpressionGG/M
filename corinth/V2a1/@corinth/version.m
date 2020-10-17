function oo = version(o,varargin)                                      
%
% VERSION   CORINTH toolbox version / release notes
%
%    Print CORINTH release notes / bug list or get CORINTH version
%
%       vs = version(corinth);         % get CORINTH version string
%       version(corinth);              % type release notes / known bugs
%
%    See also: CORINTH
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
   path = upper(which('corinth/version'));
   path = upath(o,path);
   idx = max(findstr(path,'/@CORINTH/VERSION.M'));
   vers = path(idx-3:idx-1);
   
   if (nargout == 0 || nin > 1)
      clc
      %help corinth/version
      type corinth/version
      line = '----------------------------------------';
      fprintf('%s%s\n',line,line);
      fprintf('CORINTH Toolbox - Version: %s\n',vers);
      fprintf('%s%s\n',line,line);
   else
      oo = vers;
   end
end   

%==========================================================================
% Corinth Power Features
%==========================================================================

function CorinthPowerFeatures                                          
%
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

function VersionV2A                                                    
%
% Release Notes Corinth/V2A
% =========================
%
% - Support of MATLAB symbolic toolbox
%
%
% Change Log V2a1:
%
% - starting corinth beta V2a1
% - add VPA support and adopt plus/minus arithmetics for TRFs 
%
%
% Known Bugs / Wishlist
% - none so far
%
end

