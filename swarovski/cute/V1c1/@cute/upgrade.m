function oo = upgrade(o,oo,list)       % Upgrade Obj with Package Info 
%
% UPGRADE  Upgrade an object by adding package info data
%
%             oo = upgrade(o,oo)       % upgrade object, given package obj
%             oo = upgrade(o,oo,list)  % upgrade object, list of packages
%
%             tags = upgrade(o)        % return upgrade tag list
%
%          oo is the data object, while for 2 input args o is a package
%          object from which data is copied to the data object. For 3 input
%          args package object is one of the objects in list (arg3) and
%          upgrade() method must find out proper package object in list
%          based on data object's package identifier.
%     
%          Copyright(c): Bluenetics 2020
%
%          See also: CUTE, READ, IMPORT, COLLECT
%
   if (nargin == 1)
      oo = UpgradeList(o);
      return
   end
   
   if (nargin == 2)                    % package object given by arg1
      oo = Upgrade(o,oo);
      return
   end
   
   if (nargin == 3)                    % package object in given list
      package = get(oo,{'package',''});
      
         % find proper package object (with matching package identifier)
         % in provided list, and if found, upgrade object
         
      for i=1:length(list)
         o = list{i};
         if type(o,{'pkg'}) && oo.is(get(o,{'package','?'}),package)
            oo = Upgrade(o,oo);
            return                     % and that's it - bye!
         end
      end
      
         % if we get here then something did fail!
         
      fprintf(['*** warning: ',...
               'could not find referred package object for upgrade!\n']);
      fprintf('*** missing package object: %s\n',package);
      return
   end

      % we should not get beyond this line
      
   error('1,2 or 3 input args expected');
end

%==========================================================================
% Upgrade a Data Object With Parameters From Package Object
%==========================================================================

function oo = Upgrade(o,oo)            % Upgrade Obj with Package Info 
%
% UPGRADE  Upgrade an object by adding package info data
%
%             oo = upgrade(o,oo)
%
%          oo is the data object, while o is a package object from which
%          data is copied to the data object.
%     
      % verify that arg2 is a package object
      
   if ~(isobject(o) && type(o,{'pkg'}))
      error('package object expected (arg2)');
   end
   
      % an object upgrade is only possible if object file name is listed
      % in the files list of the package

   files = get(o,{'files',{}});
   if isempty(files)
      fprintf('*** warning: cannot upgrade object!\n');
      fprintf('*** reason: empty files list of package object\n');
      return
   end
   
   file = get(oo,{'file','?'});
   idx = o.is(file,files);

   if (idx == 0)
      fprintf('*** warning: cannot upgrade object!\n');
      fprintf('*** reason: file not found in package object''s file list\n');
      return
   end

      % go ahead and inherit package data to object
      
   tags = UpgradeList(o);              % get upgrade tag list
   oo = FromPkg(o,oo,tags,idx);        % inherit from package
   oo = FromArticle(oo);               % inherit from article data base
end

%==========================================================================
% Inherit Parameters From Package Object
%==========================================================================

function oo = FromPkg(o,oo,tags,idx)   % Inherit From Package Object   
%
% INHERIT  Upgrade object (oo) by inheriting package (o) info data
%
%             o = Inherit(o,oo,tags,idx)
%     
   for (i=1:length(tags))
      tag = tags{i};
      values = get(o,tag);             % get package parameter
      
         % package parameter can be empty, a scalar or an array!
         % we have to deal with all three of them
         
      if length(values) > 0 && ~ischar(values)  % double or cell arrray
         if (idx > 0 && idx <= length(values))
            if isa(values,'double')    % double array
               oo = set(oo,tag,values(idx));
            elseif iscell(values)
               oo = set(oo,tag,values{idx});
            else  
               fprintf('*** warning: cannot inherit from package!\n');
            end
         end
      else
         oo = set(oo,tag,values);      % inherit object parameter
      end
   end
end
function oo = FromArticle(o)           % Inherit From Article
   oo = o;                             % original object
   art = get(o,'article');
   if isempty(art)
      fprintf('*** warning: no article info found for %s\n',get(o,'title'));
      return
   end
  
   ao = article(o,art);
   if isempty(ao)
      fprintf('*** warning: article not found: %s\n',art);
      return
   end
   
      % inherit facette angle information from article
      
   tags = fields(ao.par);
   for (i=1:length(tags))
      tag = tags{i};
      if (strfind(tag,'facette') == 1)
         oo.par.(tag) = ao.par.(tag);
      end
   end
end

%==========================================================================
% Get Upgrade Tag List
%==========================================================================

function tags = UpgradeList(o)         % Get Upgrade Tag List          
   tags = {'project','machine','package','date','time',...
           'station','apparatus','damping',...
           'kappl','lage','theta','vcut','vseek',...
           'creator','version'};
end


