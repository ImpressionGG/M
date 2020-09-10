function hlp(topic)
%
% HLP   Help substitute for Octave
%
%          hlp quark        % help regarding quark class
%          hlp quark/disp   % help regarding quark/disp method
%
   if (nargin == 0)
      topic = "???";
   end
   
   favorites = {};
   alternatives = {};
   classdir = {};
   class = "???";           % by default
   
   idx = find(topic=="/");
   if ~isempty(idx)
      idx = idx(1);
      class = topic(1:idx-1);
      topic = topic(idx+1:end);
   end
   

   p = path;
   sep = ";";                 % used on Windows
   if isempty(find(p==sep))
      sep = ":";              % used on MacOS
   end

   while (~isempty(p))
      idx = find(p==sep);
      if isempty(idx)
         directory = p;
         p = "";
      else
         directory = p(1:idx(1)-1);
         p = p(idx(1)+1:end);
      end
      
      files = dir(directory);
      for (i=1:length(files))
         file = files(i).name;      
         if (files(i).isdir && file(1) == "@")
            cdirectory = [directory,"/",file];
            cfiles = dir(cdirectory);
            for (j=1:length(cfiles))
               cfile = cfiles(j).name;
               if isequal(lower([topic,".m"]),lower(cfile))
                  mfile = [cdirectory,"/",cfile];
                  iscons = isequal(file(2:end),topic);
                  
                  top = [file(2:end),"/",topic];
                  if isequal(file(2:end),topic) && isequal(class,"???")
                     classdir = {cdirectory,file};
                  elseif isequal(top,[class,"/",topic])
                     if (iscons)
                        favorites{end+1} = {mfile,file(2:end),1}; 
                        %Help(mfile,file(2:end),1);
                     else
                        favorites{end+1} = {mfile,file(2:end)}; 
                        %Help(mfile,file(2:end));
                     end
                  else
                     alternatives{end+1} = {top,mfile,file,iscons};
                  end
                  
                  %return
               end
            end
         elseif isequal(lower([topic,".m"]),lower(file))
            mfile = [directory,"/",file];
            favorites{end+1} = {mfile}; 
            %Help(mfile);
            %return
         end
      end
   end

   if ~isempty(classdir)
      directory = classdir{1};
      name = classdir{2};
      fprintf("Class %s\n",name);
      files = dir(directory);
      
      topics = {};
      for (i=1:length(files))
         file = files(i).name;
         idx = strfind(file,".m");
         if ~isempty(idx)
            topics{end+1} = file(1:end-2);
         end
      end
  
      columns = 6;
      n = length(topics);
      rows = floor(n/columns)+1;
      
      for (i=n+1:rows*columns)
         topics{i} = "";
      end
      topics = reshape(topics,rows,columns);
      [m,n] = size(topics);
      
      space = "                    ";
      for (i=1:m)
         fprintf("   ");
         for (j=1:n)
            name = topics{i,j};
            fprintf("%s%s",name,space(1:max(0,12-length(name))));
         end
         fprintf("\n");
      end
      Try("Try also:",alternatives);
   elseif ~isempty(favorites)
      item = favorites{1};
      if (length(item)==1)
         Help(item{1});
      elseif (length(item)==2)
         Help(item{1},item{2});
      else
         Help(item{1},item{2},item{3});
      end
      Try("Try also:",alternatives);      
   else
      if (length(alternatives)==1)
         item = alternatives{1};
         class = item{3};
         if (item{4})
             Help(item{2},class(2:end),item{4});
         else   
             Help(item{2},class(2:end));
         end
      elseif (length(alternatives) > 0)
         fprintf("Ambiguos help avalable for this topic!\n");
         Try("Try:",alternatives);
      else
         fprintf("No help avalable for this topic!\n");
         Try("Try:",alternatives);
      end
   end
end

function Try(text,alternatives)
   if ~isempty(alternatives)
      fprintf("%s\n",text);
      for (i=1:length(alternatives))
         item = alternatives{i};
         topic = item{1};
         fprintf("   hlp %s\n",topic);
      end
   end
end

function Help(mfile,class,constructor)
%
% HELP   Print help text of an m-file
%
   if (nargin >= 3)
      fprintf("Class constructor of class: @%s\n",class);
   elseif (nargin >= 2)
      fprintf("Class @%s method:\n",class);
   end

   fid = fopen(mfile);
   if (fid < 0)
      error(["cannot open file ",mfile]);
   end
   
   line = fgetl(fid);
   line = fgetl(fid);    % the second line
   
   while ischar(line)
      if (line(1) == "%")
         fprintf("%s\n", line(2:end));
      else
         break
      end
      line = fgetl(fid);
   end
   
   fclose(fid);
end
