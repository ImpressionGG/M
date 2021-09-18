function oo = pkginfo(o,path)          % Provide Package Info          
%
% PKGINFO Provide package info, if not existing
%
%            oo = pkginfo(o,path)
%
%         Copyright(c): Bluenetics 2021
%
%         See also: SPM, SHELL, COLLECT
%
   [dir,file,ext] = fileparts(path);
   title = [file,ext];              % recombine file & extension to name
   
      % extract package type
      
   try
      [package,typ,name,run,mach] = split(o,title);
   catch
      typ = '';                        % initiate an error
   end
      
   if isempty(package) || isempty(typ) || isempty(run) || isempty(mach)
      message(o,'Error: something wrong with package folder syntax!',...
                '(cannot import files)');
      return
   end
   
   [date,time] = filedate(o,path);
   project = context(o,'Project',path);     % extract project from path
   
      % create a package object and set package parameters
      
   oo = spm('pkg');
   oo.data = [];                       % make a non-container object
   oo.par.title = title;
   oo.par.comment = {};
   oo.par.date = date;
   oo.par.time = time;
   oo.par.kind = typ;
   oo.par.project = project;
   oo.par.machine = mach;
   
   oo.par.package = package;
   oo.par.creator = opt(o,{'tools.creator',user(o,'name')});
   oo.par.version = [upper(class(o)),' ',version(o)];
   
      % open a dialog for parameter editing
      
   oo = opt(oo,'caption',['Package Object: ',package]);
   oo = ReadInfo(oo,[path,'/info.txt']);
   oo = Dialog(oo);                    % dialog for editing key parameters
   
   if isempty(oo)
      return
   end

      % update some settings
      
   setting(o,'tools.creator',get(oo,'creator'));
   
      % now write package file (.pkg)
      
   file = [FileName(oo,typ,date,time,package),'.pkg'];
   filepath = [path,'/',file];
   filepath = o.upath(filepath);
   
   oo = write(oo,'WritePkgPkg',filepath);
   if isempty(oo)
      o = Error(o,'could not write package file!');
      o = [];
      return
   end
   
   folder = o.either(context(o,'Path',path),title);
   [dir,fname,ext] = fileparts(folder);
   
   message(o,'Package info successfully written!',...
      ['Package: ',package],['Path: ',dir],['Folder: ',title],['File: ',file]);
   return
   
   function file = FileName(o,typ,date,time,pkg)  % Compose File Name             
      file = [upper(typ),date([1:2,4:6,8:11]),'-',time([1:2,4:5,7:8])];

      if isequal(o.type,'pkg')
         file = o.either(pkg,file);
         if ~isempty(typ)
            file = [file,'.',upper(typ)];
         end
      end
      file = Allowed(file);
   end
   function name = Allowed(name)       % Convert to Allowed File Name  
   %
   % ALLOWED   Substitute characters in order to have an allowed file name
   %
      allowed = '!$%&()=?+-.,#@������ ';
      for (i=1:length(name))
         c = name(i);
         if ('0' <= c && c <= '9')
            'ok';
         elseif ('A' <= c && c <= 'Z')
            'ok';
         elseif ('a' <= c && c <= 'z')
            'ok';
         elseif ~isempty(find(c==allowed))
            'ok';
         else
            name(i) = '-';             % substitute character with '-'
         end
      end
   end
end

%==========================================================================
% Helper
%==========================================================================

function oo = Dialog(o)                % Edit Key Parameters           
%
% Dialog  A dialog box is opened to edit key parameters
%         With opt(o,'caption') the default caption of the dialog box
%         can be redefined.
%
   either = @corazito.either;          % short hand
   is = @corazito.is;                  % short hand
   trim = @corazito.trim;              % short hand
   
   caption = opt(o,{'caption','Edit Key Parameters'});
   title = either(get(o,'title'),'');
   comment = either(get(o,'comment'),{});
   if ischar(comment)
      comment = {comment};
   end
   date = either(get(o,'date'),'');
   time = either(get(o,'time'),'');
   project = either(get(o,'project'),'');
   variation = either(get(o,'variation'),'pivot');
   image = either(get(o,'image'),'image.png');
   version = either(get(o,'version'),'');
   creator = either(get(o,'creator'),'');
%
% We have to convert comments into a text block
%
   text = '';
   for (i=1:length(comment))
      line = comment{i};
      if is(line)
         text(i,1:length(line)) = line;
      end
   end
%
% Now prepare for the input dialog
%
   prompts = {'Title','Comment','Date','Time',...
              'Project','Variation','Image','Version','Creator'};
   values = {title,text,date,time,project,variation,image,version,creator};
   dims = ones(length(values),1)*[1 50];  dims(2,1) = 3;
   
   values = inputdlg(prompts,caption,dims,values);   
   if isempty(values)
      oo = [];
      return                           % user pressed CANCEL
   end
   
   title = either(values{1},title);
   text = values{2};
   comment = {};
   for (i=1:size(text,1))
      comment{i,1} = trim(text(i,:),+1);   % right trim
   end
   oo = set(o,'title,comment',title,comment);
   
   date = values{3};  time = values{4};
   oo = set(oo,'date',date,'time',time);
   
   project = values{5};  variation = values{6};
   image = values{7};  version = values{8};  creator = values{9};
   oo = set(oo,'project',project,'version',version,'creator',creator);
   oo = set(oo,'variation',variation,'image',image);
end
function oo = ReadInfo(o,path)         % Read Info into Comment        
   fid = fopen(path);
   if isequal(fid,-1)
      oo = o;
      return                           % file not found / cannot open file
   end
   phi = 0;                        % init by default
   
   comment = get(o,{'comment',{}});
   while (1)
      line = fgetl(fid);
      if ~isequal(line,-1)
         idx = find(line==':');
         if ~isempty(idx)
            idx = idx(1)+1;
            while (length(line)>=idx+1 && line(idx)==' ' && line(idx+1)==' ')
               line(idx) = [];
            end
         end
         
         comment{end+1} = o.trim(line);
         
            % search for key 'phi:' and if found set 'phi'
            % parameter
            
         key = 'phi:';             % key to search
         idx = strfind(line,key);
         if ~isempty(idx)
            str = line(idx+length(key):end);
            phi = eval(str);
         end
      else
         break
      end
   end
   
   fclose(fid);
   oo = set(o,'comment',comment);
   oo = set(oo,'phi',phi);
end
