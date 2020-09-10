function list = import(o,driver,ext)   % Import Object From File       
%
% IMPORT   Import object(s) from file
%
%             list = import(o,'ReadText','.txt')
%
%          Copyright(c): Bluenetics 2020 
%
%          See also: CORAZON, EXPORT, READ
%
   caption = sprintf('Import object from %s file',ext);
   [files, dir] = fselect(o,'i',ext,caption);
   
   list = {};                          % init: empty object list
   gamma = eval(['@',driver]);         % function handle for import driver
   for (i=1:length(files))
      path = [dir,files{i}];
      oo = read(o,driver,path);        % read data file into object
      oo = launch(oo,launch(o));       % inherit launch function
      list{end+1} = oo;                % add imported object to list
   end
end
 