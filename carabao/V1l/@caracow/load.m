function bag = load(o)
%
% LOAD   Load a bag of properties from .MAT file
%
%           bag = load(caracow)
%           construct = eval(['@',bag.tag]);  % constructor function handle
%           construct(bag)                    % construct & launch
%
%        Code lines: 16
%
%        See also: CARACOW, LOAD, DIRECTORY
%
   bull = carabull;                    % carabull object

   curdir = cd;                        % save current directory
   if ~isempty(directory(bull))        % check persistent directory path
      cd(directory(bull));             % change to persistent dir path
   end
   
   [file, dir] = uigetfile('*.mat', 'Open .mat file');
   if isequal(file,0)
      bag = [];
   else
      directory(bull,dir);             % save to persistent directory path
      cso = server(bull,pack(o));      % create a Carabase server object
      bag = load(cso,[dir,file]);      % use Carabase load service
   end
   
   cd(curdir);                         % restore current directory
end

