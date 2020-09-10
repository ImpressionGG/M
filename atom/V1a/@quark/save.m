function o = save(o,bag)
%
% SAVE   Save a bag of properties to .MAT file
%
%           o = save(quark,bag)
%           o = save(quark,pack(o))
%
%        Code lines: 13
%
%        See also: QUARK, GLUON, LEPTON, LOAD, DIRECTORY
%
   gob = gluon;                        % GLUON object
   
   curdir = cd;                        % restore current directory
   if ~isempty(directory(gob))
      cd(directory(gob));
   end
   
   [file, dir] = uiputfile('.mat', 'Save .mat file');
   if ~isequal(file,0)
      directory(gob,dir);              % save to persistent directory path
      lep = server(gob,bag);           % create a LEPTON server object
      save(lep,bag,[dir,file]);        % delegate save to lepton/save
   end
   
   cd(curdir);                         % restore current directory
end

