function vers = version(o,arg)       % MESH Class Version
%
% VERSION   MESH class version / release notes
%
%       vs = version(mesh);            % get MESH version string
%
%    See also: MESH
%
%--------------------------------------------------------------------------
%
% Features MESH/V1A
% ==================
%
% - Toolbox to analyse and study BT Mesh performance
% - bug fixes in shell
%
%--------------------------------------------------------------------------
%
% Roadmap
% =======
% - roadmap item 1
% - roadmap item 2
% - roadmap item ...
%
%--------------------------------------------------------------------------
%
% Release Notes MESH/V1A
% =======================
%
% - created: 21-Oct-2021 17:05:32
% - basic analysis with collision probability implemented
% - methods bench, boost and yield
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('mesh/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@MESH'));
   vers = path(idx-4:idx-2);
end
