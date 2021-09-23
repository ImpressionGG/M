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
%           Options:
%              fontsize.title        font size of title (default: 14)
%              fontsize.comment      font size of comment (default:  8)
%              subplot               subplot identifier (default [1 1 1])
%              pitch                 vertical pitch width (default: 1)
%
%           Copyright(c): Bluenetics 2020 
%
%           See also: CORAZON, TEXT
%
   either = util(o,'either');          % need some utility
   comment = varargin;
   
   if (nargin == 1)
      title = get(o,{'title',''});
      comment = get(o,{'comment',{}});
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
   fontsize.title = opt(o,{'fontsize.title',14});
   fontsize.comment = opt(o,{'fontsize.comment',8});
   
   [either,uscore] = util(o,'either','uscore');     % need some util
   if isempty(figure(o))
      o = figure(o,gcf(o));            % set figure handle if not set
   end
   %figure(figure(o));

      % first look at subplot option, if option is empty then fetch
      % current subplot settings with sub = subplot(o)
      
%  sub = opt(o,{'subplot',subplot(o)});
   sub = opt(o,'subplot');
   if (isempty(sub) || isequal(sub,[1 1 1 1]))
      o = cls(o,'off');                % clear screen, axes off
      hax = axes(o);                   % get axes handle
   else
      o = subplot(o,sub);
      delete(axes(o));
      o = subplot(o,sub);
      hax = axes(o);
      set(hax,'visible','off');
   end
   
   darkmode = dark(o);
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
   htxt = text(hax,x,0.9,uscore(txt));
   set(htxt,'fontsize',fontsize.title,'horizontalalignment',halign,...
            'verticalalignment',valign)
   if (darkmode)
      set(htxt,'color',[1 1 1]);
   end
%
% display comment
%
   comment = get(o,'comment');
   if ~isa(comment,'cell')
      comment = {comment};
   end
   
   pitch = opt(o,{'pitch',1}) * 0.05;
   row = 1;
   for (i=1:length(comment))
      txt = either(comment{i},'');
      for (j=1:size(txt,1))
         txtj = txt(j,:);
         if (length(txtj) >= 2) && strcmp(txtj(1:2),'\r')
            htxt = text(hax,0,0.85-row*pitch,uscore(txtj(3:end)));
            set(htxt,'fontsize',fontsize.comment,'horizontalalignment',...
                     'left','verticalalignment',valign)
         else
            htxt = text(hax,x,0.85-row*pitch,uscore(txtj));
            set(htxt,'fontsize',fontsize.comment,'horizontalalignment',...
                     halign,'verticalalignment',valign)
         end
         if (darkmode)
            set(htxt,'color',[1 1 1]);
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
