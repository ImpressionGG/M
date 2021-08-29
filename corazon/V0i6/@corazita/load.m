function bag = load(o,path)
%
% LOAD   Load a bag of properties from .MAT file
%
%           bag = load(corazita)
%           bag = load(corazita,path)
%
%        Example
%
%           bag = load(corazita)
%           construct = eval(['@',bag.tag]);  % constructor function handle
%           construct(bag)                    % construct & launch
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZITA, LOAD, DIRECTORY
%
   obj = corazito;                    % corazito object

   curdir = cd;                        % save current directory
   if ~isempty(directory(obj))         % check persistent directory path
      cd(directory(obj));              % change to persistent dir path
   end
   
   if (nargin >= 2)
      [dir,file,ext] = fileparts(path);
      file = [file,ext];
      dir = [dir,'/'];
   else
      [file, dir] = uigetfile('*.mat', 'Open .mat file');
   end
   
   if isequal(file,0)
      bag = [];
   else
      directory(obj,dir);              % save to persistent directory path
      cso = server(obj,pack(o));       % create a Corleon server object
      bag = load(cso,[dir,file]);      % use Corleon load service
   end
   
   cd(curdir);                         % restore current directory
end

