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

   n = length(files);
   
   for (i=1:n)
      path = [dir,files{i}];
      
      msg = sprintf('Importing %g of %g: %s', i,n, files{i});
      progress(o,msg,(i-1)*100/n);
      
      oo = read(o,driver,path);        % read data file into object
      oo = launch(oo,launch(o));       % inherit launch function

      progress(o,msg,i*100/n);
      list = Add(o,oo,list);           % add imported object to list
      
      if ~iscell(list)                 % event happened to cause a break?
         return;
      end
   end
end

%==========================================================================
% Helper
%==========================================================================

function list = Add(o,oo,list)
%
% ADD     Adding object to list; if no package identifier provided then we 
%         just add objject to list. If a package identifier is provided
%         then first lookup, whether a package is already in the shell
%         object's list, and if not then alert!
%
   is = @isequal;                      % short hand
   title = get(oo,{'title',''});
   package = get(oo,{'package',''});
   
      % if package ID is empty then just add object to list, and that's it!
      
   if isempty(package)   
      list{end+1} = oo;                % add imported object to list
      return                           % that's it - bye
   end
   
      % otherwise try to find related package in shell object's list,
      % and if not => alert!
      
   assert(iscell(o.data));
   
   for (i=1:length(o.data))
      oi = o.data{i};
      if type(oi,{'pkg'})
         pid = get(oi,{'package','#'});
         if is(package,pid) && ~type(oo,{'pkg'})
            list = Append(o,oo,list);  % add object to list
            return                     % everything well done - bye!
         end
      end
   end
   
      % unfortunately we did not find a matching package in shell's
      % children - for non-pkg type objects alert (occasionaly terminate)
      
   if ~type(oo,{'pkg'})
      msg = sprintf(['Object %s refers to Package %s which has not been ',...
               'loaded! Keep object, Skip or terminate (Cancel)?'],title,package);

      button = questdlg(msg,'Package Info Missing!',...
                            'Keep','Skip','Cancel','Skip'); 

      if isequal(button,'Skip')
         return
      elseif isequal(button,'Cancel')
         list = [];                    % return non-cell to terminate
         return
      end
   end
   
   list = Append(o,oo,list);
end
function list = Append(o,oo,list)      % append Data Object            
   assert(iscell(o.data));
   is = @isequal;                      % short hand
   
   title = get(oo,{'title',''});
   package = get(oo,{'package',''});
   
      % if package ID is empty then just add object to list, and that's it!
      
   if isempty(package)   
      list{end+1} = oo;                % add imported object to list
      return                           % that's it - bye
   end
   
      % otherwise try to find related package in shell object's list,
      % and if not => alert!
      
   duplicate = false;
   for (i=1:length(o.data))
      oi = o.data{i};
      titi = get(oi,{'title','$?$'});
      pid = get(oi,{'package','#'});
      
      if is(title,titi) && is(pid,package) && is(oi.type,oo.type)
         duplicate = true;
         break;
      end
   end
   
      % if object is not included then add object to list & bye!
      
   if (~duplicate) 
      list{end+1} = oo;                % add object to list
      return                           % bye
   end
   
      % otherwise alert and get user input how to proceed
      
   msg = sprintf(['%s seems to be already loaded, which might ',...
                  'lead to duplicate objects! ',...
                  'Duplicate, Skip or terminate (Cancel)?'],title);
               
   button = questdlg(msg,'Duplicate Object!',...
                         'Duplicate','Skip','Cancel','Skip'); 
               
   if isequal(button,'Duplicate')
      list{end+1} = oo;                % add object to list
   elseif isequal(button,'Cancel')
      list = [];                       % return non cell to terminate
   end
end