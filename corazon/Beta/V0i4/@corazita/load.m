function bag = load(o)
%
% LOAD   Load a bag of properties from .MAT file
%
%           bag = load(corazita)
%           construct = eval(['@',bag.tag]);  % constructor function handle
%           construct(bag)                    % construct & launch
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZITA, LOAD, DIRECTORY
%
   bull = corazito;                    % corazito object

   curdir = cd;                        % save current directory
   if ~isempty(directory(bull))        % check persistent directory path
      cd(directory(bull));             % change to persistent dir path
   end
   
   [file, dir] = uigetfile('*.mat', 'Open .mat file');
   if isequal(file,0)
      bag = [];
   else
      directory(bull,dir);             % save to persistent directory path
      cso = server(bull,pack(o));      % create a Corleon server object
      bag = load(cso,[dir,file]);      % use Corleon load service
   end
   
   cd(curdir);                         % restore current directory
end

