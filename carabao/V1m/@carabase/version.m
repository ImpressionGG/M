function out = version(obj,arg)
%
% VERSION   CARABASE toolbox version / release notes
%
%    Print CARABASE release notes / bug list or get CARABASE version
%
%       vs = version(carabase);        % get CARABASE version string
%       version(carabase);             % type release notes / known bugs
%
%    Code lines: 12
%
%    See also: CARABASE
%
%--------------------------------------------------------------------------
%
% Release Notes Corona/V1A
% =========================
%
% - implementation of basic methods: corona constructor, corona/validate,
%   corona/version
% - implementation of methods corona/save, corona/load and corona/sync
% - integration test with Caramba toolbox
% - Corona.V1a.Bak1
% - syncing up to mount point directories '[...]'
% - Corona.V1a.Bak2
% - mandatory author added to query info
% - bug fixed in detection of mountable directory
% - method corona/mountable introduced
% - Corona.V1a.Bak3
% - corona/validate rewritten to save code lines
% - fine tuning, adding number of code lines, total codelines: 200
% - Corona.V1a.Bak4
%
% Release Notes Corona/V1B
% =========================
%
% - tested with CARABAO, no bugs detected
%
% Release Notes Corona/V1C
% =========================
%
% - methods MOUNTABLE and SYNC modified in order to allow for mountable
%   folders which are not starting with '[' and ending with ']'
% - extension to MOUNTABLE is done by a global function ISCORONAFOLDER
%   which test a folder name against a list of additional mountable folder
%   names.
%
% Release Notes Carabase/V1C
% ==========================
%
% - ported from Corona/V1C
%
% % Known Bugs & ToDo's Carabase
% ==========================
%
% - requirement for mountable folders which are not starting with '['
%   and ending with ']'
%
   path = upper(which('carabase/version'));
   idx = max(findstr(path,'\@CARABASE\VERSION.M'));
   vers = path(idx-3:idx-1);
   
   if (nargout == 0 || nargin > 1)
      clc;  help carabase/version
      s = '----------------------------------------';
      fprintf('%s%s\nCORONA Toolbox - Version: %s\n%s%s\n',s,s,vers,s,s);
   else
      out = vers;
   end
end   
