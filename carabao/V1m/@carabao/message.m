function o = message(o,title,varargin)
%
% MESSAGE   Show a message on screen
%
%              message(o);        % message of object's title & comment
%
%              message(o,'This is my message!');
%              message(o,'Error','No traces!','Consider to import!');
%              message(o,'Error',{'No traces!','Consider to import!'});
%
%           Display message of a catched exception
%
%              try
%               :
%              catch err
%                 message(o,err,'Error during Save ...',text2,...)
%              end
%
%           Options: opt(o,'halign') and opt(o,'valign') control the
%           horizontal (default 'center') and vertical (default: 'middle')
%           alignment.
%
%           Remark: the short form message(o,err) will display a list of
%           error stack messages on the shell's screen.
%
%           Messaging into a subplot:
%           => set o = opt(o,'subplot',1) for messaging into a subpolot
%
%           See also: CARABAO, TEXT
%
   either = util(o,'either');          % need some utility
   comment = varargin;
   
   if (nargin == 1)
      title = get(o,'title');
      comment = get(o,'comment');
      message(o,title,comment);
      return
   elseif (nargin == 2)
      comment = {''};
   elseif (nargin == 3)
      if iscell(varargin{1})
         comment = varargin{1};
      end
   end
%
% check if second arg is an MException
%
   if (nargin >= 2) && isa(title,'MException')
      Error(o,title,comment);          % display error message
      return
   end
%
% check type of title and comments
%
   title = either(title,'');
   if ~ischar(title)
      error('message title (arg1) must be string!');
   end
   for (i=1:length(comment))
      comment{i} = either(comment{i},'');
      commenti = comment{i};
      if ~ischar(commenti)
         comment{i} = '';
         fprintf('*** all args must be string!\n');
         %error('all args must be string!');
      end
   end
%
% Show title and comment
%
   oo = set(o,'title',title);
   oo = set(oo,'comment',comment);
   
   Message(oo);
   return
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function Message(o)                    % Display Screen Message        
%
% MESSAGE   Display object's title and comment in figure
%
   [either,uscore] = util(o,'either','uscore');     % need some util
   if isempty(figure(o))
      o = figure(o,gcf(o));            % set figure handle if not set
   end
   figure(figure(o));
   if ~opt(o,{'subplot',0})
      cls(o,'off');                       % clear screen, axes off
   end
%
% display title
%
   txt = get(o,'title');
   halign = opt(o,{'halign','center'});
   valign = opt(o,{'valign','middle'});
   switch halign
       case 'left'
          x = 0;
       case 'center'
          x = 0.5;
       case 'right'
          x = 1.0;
   end
   htxt = text(x,0.9,uscore(txt));
   set(htxt,'fontsize',14,'horizontalalignment',halign,...
                          'verticalalignment',valign)
%
% display comment
%
   comment = get(o,'comment');
   if ~isa(comment,'cell')
      comment = {comment};
   end
   
   row = 1;
   for (i=1:length(comment))
      txt = either(comment{i},'');
      for (j=1:size(txt,1))
         txtj = txt(j,:);
         if (length(txtj) >= 2) && strcmp(txtj(1:2),'\r')
            htxt = text(0,0.85-row*0.05,uscore(txtj(3:end)));
            set(htxt,'fontsize',8,'horizontalalignment','left',...
                                'verticalalignment',valign)
         else
            htxt = text(x,0.85-row*0.05,uscore(txtj));
            set(htxt,'fontsize',8,'horizontalalignment',halign,...
                                'verticalalignment',valign)
         end
         row = row+1;
      end
   end
end

function  Error(o,title,comment)       % Display Error Message on Screen
   err = title;  title = '';
   if (length(comment) >= 1)
      title = comment{1};  
      comment = comment(2:end);
   end

      % we need to replace '\' characters in MATLAB error messages,
      % e.g. file path. Method upath (UNIX style path) will replace
      
   id = err.identifier;
   comment{end+1} = ['error ID: ',id];
   comment{end+1} = upath(o,err.message);  % UNIX path style

   if isempty(title)
      title = 'Error';
      comment{end+1} = '';       % empty line
      for (i=1:length(err.stack))
         entry = err.stack(i);
         line = sprintf('%g',entry.line);
         txt = [upath(o,entry.file),'>',entry.name,': line ',line];
         comment{end+1} = txt;
      end
   end

   message(o,title,comment);
end
