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
%
%          Options:
%             files          upgrade only if file name is listed in
%                            package (default: false)
%
%          Copyright(c): Bluenetics 2020
%
%          See also: CORAZON, READ, IMPORT, COLLECT
%
   if (nargin == 1)
      oo = UpgradeList(o);
      return
   end
   
   if (nargin == 2)                    % package object given by arg1
      oo = Upgrade(oo,o);
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
% Get Upgrade Tag List
%==========================================================================

function tags = UpgradeList(o)         % Get Upgrade Tag List          
   tags = {'project','machine','package','date','time',...
           'creator','version'};
end

%==========================================================================
% Upgrade a Data Object With Parameters From Package Object
%==========================================================================

function oo = Upgrade(oo,o)            % Upgrade Obj with Package Info 
%
% UPGRADE  Upgrade an object by adding package info data
%
%             oo = Upgrade(oo,o)
%
%          oo is the data object, while o is a package object from which
%          data is copied to the data object.
%     
      % verify that arg2 is a package object
      
   if ~(isobject(o) && type(o,{'pkg'}))
      error('package object expected (arg2)');
   end
   
      % if 'files' option is set then an object upgrade is only possible
      % if object file name is listed in the files list of the package

   if opt(o,{'files',false})
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
   end

      % go ahead and inherit package data to object
      
   tags = UpgradeList(o);              % get upgrade tag list
   oo = FromPkg(oo,o,tags);            % inherit from package
end

%==========================================================================
% Inherit Parameters From Package Object
%==========================================================================

function oo = FromPkg(oo,o,tags)       % Inherit From Package Object   
%
% FROMPKG  Upgrade object (oo) by inheriting package (o) info data
%
%             o = FromPkg(o,oo,tags,idx)
%     
   for (i=1:length(tags))
      tag = tags{i};
      value = get(o,tag);              % get package parameter value
      oo = set(oo,tag,value);          % inherit to object parameter
   end
end


