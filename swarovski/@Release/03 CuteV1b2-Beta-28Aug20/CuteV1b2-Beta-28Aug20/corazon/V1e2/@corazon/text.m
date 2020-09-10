function o = text(o,varargin)
%
% TEXT   Plot text into current graphic window using normalized coordinates
%        in the range x:[0,1], y:[0,1]. Every text will automatically be
%        processed by method UNDERSCORE
%
%           text(gao,'my_text',50,50);         % place into center
%           text(gao,'my_text');               % place into center
%            
%        Text method is sensitive to the following options:
%
%        1) Text Positioning
%
%           text(gao,txt,'position',[50 50]);
%           text(gao,txt,'position',[10 NaN]); % position x=10; y unchanged
%           text(gao,txt,'position',[NaN 70]); % position y=70; x unchanged
%           text(gao,txt,'position','center'); % top: position = [50,50]  
%           text(gao,txt,'position','top');    % top: position = [50,100]  
%           text(gao,txt,'position','bottom'); % bottom: position = [50,0]
%           text(gao,txt,'position','left');   % left:  position = [0,50]
%           text(gao,txt,'position','right');  % right: position = [100,50]
%           text(gao,txt,'position','home');   % top left
%
%        2) Horizontal & Vertical Alignment of Text
%
%           text(gao,txt,'halign','left');     % left horizontal alignment
%           text(gao,txt,'halign','center');   % center hor. alignment
%           text(gao,txt,'halign','right');    % right horizontal alignment
%
%           text(gao,txt,'valign','top');      % top vertical alignment
%           text(gao,txt,'valign','cap');      % cap vertical alignment
%           text(gao,txt,'valign','middle');   % middle vertical alignment
%           text(gao,txt,'valign','baseline'); % baseline vert. alignment
%           text(gao,txt,'valign','bottom');   % bottom vertical alignment
%
%        3) Text Size & Text Color
%
%           text(gao,txt,'size',8);            % set text size
%           text(gao,txt,'color','r');         % set text color
%
%        4) Continuous text display
%
%           smo = opt(corazon,'position','home','append',1);
%           text(smo,'1st line\n2nd line\n3rd line);
%
%        5) Test display of a figure full of texts
%
%           text(gao);                         % run all demos
%           text(opt(o,'mode','basic','size',4));
%           text(opt(o,'mode','info'));
%
%        Options:
%           position:   reference position
%           color:      text color
%           halign:     horizontal alignment
%           valign:     vertical alignment
%           size:       text size (in window height units)
%           spacing:    spacing factor   
%
%        Output Argument: contains graphics handle in var(out,'hdl')
%
%        Copyright (c): Bluenetics 2020 
%
%        See also: CORAZON
%
   if (nargin == 1)   % test
      Test(o);
      return;
   end
   
      % continue with nargin > 1

   historic = Pop(o);
   o = Options(o,historic);      % clean & initialize options

% First check is to investigate whether length of varargin. If the number
% of varargin is odd then the first argument is the text to be plotted,
% otherwise we have a pure option setting

   len = length(varargin);
   if (rem(len,2) == 1)
      txt = varargin{1};
      varargin(1) = [];
   else
      txt = '';                % otherwise no text to be plotted
   end

% need to resolve position ?

   position = opt(o,'position');
   if ischar(position)
      o = Resolve(o,position);
   end

% now process the list of variable arguments

   i = 1;
   while(i < length(varargin))
      parameter = varargin{i};  value = varargin{i+1};  i = i+2;
      
      if (isa(parameter,'double'))
         o = opt(o,'position',[parameter,value]);
      elseif strcmp(parameter,'position')
         if isa(value,'double')
            o = opt(o,'position',value);
         elseif isa(value,'char')         
            o = Resolve(o,value);
         else
            error('2-vector or character string expected for value of position option!');
         end
      else
         o = opt(o,parameter,value);
      end
   end
   
% get again options from object. If any NaN occures in position then this
% value has to be replaced by the default. See also if we have to enlarge
% the size   
   
   opti = opt(o);
   [txt,size] = Paragraph(o,txt,opti.size);
   opti = FinalTuning(opti,historic,size);
   
% Plot text if text provided to be plotted
   
   while some(txt)
      newline = 0;
      idx = min(find(txt == 10));
      if some(idx)
         chunk = txt(1:idx-1); 
         txt = txt(idx+1:end); 
         newline = 1;
      else
         chunk = txt;
         txt = '';              % next time we are done!
      end
      
      opti = Draw(o,opti,chunk,size);         % draw this chunk of text
      if (newline)
         opti.position(2) = opti.position(2) + size*opti.spacing;
         opti.line = '';
         opti.handle = [];
      else
         break;                          % we are done!
      end
   end
   Push(o,opti);

% Store graphic handle in object's argument

   o = opt(o,opti);                % return current options
   %o = arg(o,[],opti.handle);
   o = var(o,'hdl',opti.handle);
   return
end

%==========================================================================
% Aobj - Get/Set Axis Object
%==========================================================================

function oo = Aobj(o)
%
% AOBJ   Push/pull axis object
%
%           oo = Aobj                  % pull axis object
%           Aobj(o)                    % push axis object
%
   if (nargin == 0)
      oo = get(gca,'UserData');
      if isempty(oo)
         oo = corazon;
      end
   else
      set(gca,'UserData',o)
      oo = o;
   end
end

%==========================================================================
% Resolve
%==========================================================================

function o = Resolve(o,position)
%
% RESOLVE
%
   if isa(position,'double')
      if length(position) == 2
         o = opt(o,'position',position);
         return
      end
   end
   
   if ~ischar(position)
      error('double or character expected for position!');
   end
   
   switch (position)
      case 'center'
         o = opt(o,'position',[50 50],...
                          'halign','center','valign','middle');
      case 'top'
         o = opt(o,'position',[50 0],...
                          'halign','center','valign','top');
      case 'bottom'
         o = opt(o,'position',[50 100],...
                          'halign','center','valign','bottom');
      case 'left'
         o = opt(o,'position',[0 50],...
                          'halign','left','valign','middle');
      case 'right'
         o = opt(o,'position',[10 50],...
                          'halign','right','valign','middle');
      case 'home'
         o = opt(o,'position',[0 0],...
                          'halign','left','valign','top');
      otherwise
         error('bad short cut for posdition used!');
   end
   return
end

%==========================================================================
% Final Option Tuning
%==========================================================================

function opti = FinalTuning(opti,historic,size)
%
% FINALTUNING   Make a final tuning of options. Any NaN in position
%               has to be replaced by the proper default, and opti.handle
%               has to be cleared if position or size has changed
%
   if isnan(opti.position(1))
      opti.position(1) = historic.position(1);
   end
   if isnan(opti.position(2))
      opti.position(2) = historic.position(2);
   end
   
   if any(opti.position ~= historic.position) || (size ~= opti.size)
      opti.handle = [];
   end
   return
end

%==========================================================================
% Process Paragraphs
%==========================================================================

function [txt,size] = Paragraph(o,txt,size)
%
% PARAGRAPH   Handle paragraphs. For any paragraph or repeated paragraphs
%             at the beginning of the text: increase the size of the text
%             by a proper increment.
%
%             Also replace all '\n' sequences by setstr(1) - (linefeed)
%
   initialsize = size;
   
   while ~isempty(txt)
      if (txt(1) == '�')
         txt(1) = '';                   % eliminate '�' character
         size = size * 1.2;
         if (size >= 11)
            size = round(1*size)/1;
         elseif (size >= 6)
            size = round(2*size)/2;
         else
            size = round(4*size)/4;
         end
      elseif (txt(1) == '/')
         txt(1) = '';                   % eliminate '�' character
         size = size / sqrt(2);
      else
         break;
      end
   end
   
   if (o.either(opt(o,'verbose'),0) >= 3)
      fprintf('   paragraph: size = %g -> %g\n',initialsize,size);
   end
   
      % replace '\n' by setstr(10)
      
   while some(txt)
      idx = either(min(find(txt == '\')),0);
      if (idx > 0 && length(txt) >= idx+1)
         if (txt(idx+1) == 'n')             % newline ('\n') detected
            txt(idx) = setstr(10);          % line feed character
            txt(idx+1) = '';
         else
            break;
         end
      else
         break;
      end
   end
      
   return
end

%==========================================================================
% Draw Chunk
%==========================================================================

function opti = Draw(o,opti,txt,size)
%
% DRAW     Draw text chunk
%
   if isempty(txt)
      return
   end

      % If opti.append is empty then everything depends on opti.handle
      % If a handle is provided than we use this handle and append. 
      % Otherwise a new (unappended) string is created.
      %
      % If however opti.append is nonempty then opti.append overwrites
      % all conditions of opti.handle and determines whether append mode
      % will be used or not!
      
   if isempty(opti.append)             % leave behaviour to opti.handle
      if some(opti.handle)
         opti.line = [opti.line,txt]; 
      else
         opti.line = txt;
      end
   elseif opti.append                  % always append
      opti.line = [opti.line,txt]; 
   else                               % never append
      opti.line = txt;
   end
   
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');

   x = xlim(1) + diff(xlim)*opti.position(1)/100;
   y = ylim(2) - diff(ylim)*opti.position(2)/100;

   hdl = opti.handle;
   line = underscore(o,opti.line);
   
      % first we need to check whether our handle is valid
      
   try
      ans = get(hdl,'string');   % test if valid handle
   catch
      hdl = [];
   end
   
      % now we know we have a valid handle
      
   if some(hdl)
      set(hdl,'string',line);
   else
      hdl = text(x,y,line);
      opti.handle = hdl;
   end
   hold on;

   set(hdl,'HorizontalAlignment',opti.halign);
   set(hdl,'VerticalAlignment',opti.valign);

   FontSize(hdl,size);

   col = opti.color;
   if (~isempty(col) && (isa(col,'double') || isa(col,'char')))
      col = color(col);
      set(hdl,'Color',col);
   end

   return
end

%==========================================================================
% Push & Pop Text Data
%==========================================================================

function Push(o,opti)
%
% Push  Push options to GAO
%
   oo = Aobj;
   oo = opt(oo,'text',opti);
   Aobj(oo);
end

function opti = Pop(o)
%
% Push  Push text data
%
   position = o.either(opt(o,'position'),inf);   % inf means not defined
   size = o.either(opt(o,'size'),-1);            % -1 means not defined
   
   oo = Aobj;
   opti = opt(oo,'text');
   
   if isempty(opti)
      oo = Options(corazon,[]);                  % init all options
      opti = opt(oo);
   end
end

%==========================================================================
% Font Size Setting
%==========================================================================

function FontSize(hdl,size)
%
% FONTSIZE  Set font size
%
   scale = 3;               % scale such that: letter height = line height
   scaling = [0,0; 100,scale*100];
   x = scaling(:,1);  y = scaling(:,2);
   sz = interp1(x,y,size);
   
   position = get(gcf,'position');
   height = position(4);
   set(hdl,'FontSize',sz);
   return
end

%==========================================================================
% Options
%==========================================================================

function o = Options(o,default)
%
% OPTIONS   Extract options, set defaults if necessary
%
%              o = Option(o);           % clean and initialize options
%              o = Option(o,default);   % provide default options
%
   either = util(o,'either');           % short hand
   default = eval('default','[]');
   
   if isempty(default)
      default.line = '';
      default.halign = 'left';
      default.valign = 'top';
      default.color = 'k';
      default.size = 4;
      default.position = [0 0];
      default.spacing = 1.5;
      default.append = [];    % neither off nor on
      default.handle = [];
      default.verbose = [];
   end
   
   opti.line = default.line;   % line has a special treatment
   
   opti.position = either(opt(o,'position'),default.position);
   opti.halign = either(opt(o,'halign'),default.halign);
   opti.valign = either(opt(o,'valign'),default.valign);
   opti.color = either(opt(o,'color'),default.color);
   opti.size = either(opt(o,'size'),default.size);
   opti.spacing = either(opt(o,'spacing'),default.spacing);
   opti.handle = either(opt(o,'handle'),default.handle);
   opti.verbose = either(opt(o,'verbose'),default.verbose);
   opti.append = either(opt(o,'append'),default.append);
   
   o = opt(o,opti);   % set cleaned & initialized options
end

%==========================================================================
% Test
%==========================================================================

function Test(o)
%
% TEST    Make a test print 
%
%             Test(opt(o,'size',8));
%
%         This function is invoked by the call to text:
%
%             text(opt(corazon,'size',8));
%
   size = o.either(opt(o,'size'),4);
   mode = o.either(opt(o,'mode'),'all');
   gao = o;
   
   switch mode
      case 'all'
         table = {'basic','info','concat','append','paragraph','twin',...
                  'busy'};
         for (i=1:length(table))
            fprintf(['Demo: ',table{i}]);
            tic
            text(opt(gao,'mode',table{i}));   % run that demo
            etime = toc;
            fprintf(' ... %g ms (pause: hit key!)\n',1000*etime);
            pause;
         end
         fprintf('done!\n');
         
      case 'basic'
         cls(o);

         spacing = 1.0;
         text(gao,'position','home','spacing',spacing);
         y = spacing*size;
         while (y <= 100)
            text(gao,'ABCDEFGHIJKLM\n');
            y = y + spacing*size;
         end


         spacing = 1.5;
         text(gao,'position',[100 0],'halign','right','spacing',spacing);
         y = spacing*size;
         while (y <= 100)
            text(gao,'NOPQRSTUVWXYZ\n');
            y = y + spacing*size;
         end
         
      case 'info'   % test like a datainfo page
         cls(o);
         text(gao,'position','top','position',[50,20]);
         text(gao,'TCB Database\n','size',6);
         text(gao,['Version ',version(o),'\n'],'size',3);
         text(gao,['\nProject: HMC\n'],'size',5);

      case 'concat'   % test concatenated text
         cls(o);
         text(gao,'position','home','size',3);
         smo = text(gao,'The quick brown fox');
         smo = text(smo,' jumps over the lazy dog.');
         smo = text(smo,' This sentence is an English-language\n');
         smo = text(smo,'pangam - ');
         smo = text(smo,' a phrase that contains all of the letters');
         smo = text(smo,' of the alphabet. It is used to show\nfonts and to test');
         smo = text(smo,' typewriters and computer keyboards,');
         smo = text(smo,' and in other applications invol-\nving all of the');
         smo = text(smo,' letters in the English alphabet.');
         smo = text(smo,' Owing to its brevity and coherence, it\nhas');
         smo = text(smo,' become widely known.');

      case 'append'   % test append mode
         cls(o);
         text(gao,'position','home','size',3,'append',1);
         text(gao,'��The quick brown fox\n\n');
         
         text(gao,'The quick brown fox');
         text(gao,' jumps over the lazy dog.');
         text(gao,' This sentence is an English-language\n');
         text(gao,'pangam - ');
         text(gao,' a phrase that contains all of the letters');
         text(gao,' of the alphabet. It is used to show\nfonts and to test');
         text(gao,' typewriters and computer keyboards,');
         text(gao,' and in other applications invol-\nving all of the');
         text(gao,' letters in the English alphabet.');
         text(gao,' Owing to its brevity and coherence, it\nhas');
         text(gao,' become widely known.');

      case 'paragraph'   % test append mode
         cls(o);
         text(gao,'position','home','spacing',1);
         title = '�The Quick Brown Fox';
         for (sz=1:13)
            txt = [sprintf('%s (size %g)',title,sz),'\n'];
            text(opt(gao,'verbose',3),txt,'size',sz);
         end
         
      case 'display'     % test append mode
         cls(o);
         smo = text(gao,'position','center','size',8,'append',0);
         for (i=1:10)
            txt = sprintf('Alarm %g',i);
            text(smo,txt);
            pause(0.5);
         end
         
      case 'twin'        % twin display
         cls(o);
         title = '��\n1000 x Display Operation';
         smo = text(gao,title,'position','top','size',6);
         smo1 = text(opt(smo,'position',[50,45]),' ');
         smo2 = text(opt(smo,'position',[50,55]),' ');
         hdl1 = var(smo1,'hdl');
         hdl2 = var(smo2,'hdl');
         
         tic;
         for (k=1:50)
            for (i=1:10)
               directory = sprintf(setstr(['Directory_','A'+i-1]));
               file = sprintf('File_%g.txt',i);
               set(hdl1,'string',underscore(gao,directory));
               set(hdl2,'string',underscore(gao,file));
               shg
            end
         end
         
         tel = toc;
         text(smo2,['\n\n\n',sprintf('Elapsed time: %g sec',rd(tel))]);
         
      case 'busy'
         cls(o);
         text(gao,'Busy Demo\n','position','top','size',5);
         text(gao,'1000 busy display actions','size',3);
         
            % setup the busy display
            
         busy(opt(gao,'position','bottom','size',3,'color','r'));
         tic;
         for (i=1:1000)
            msg = sprintf('Collecting file %g',i);
            busy(msg);
         end
         
         tel = toc;
         busy(sprintf('Elapsed time: %g sec',rd(tel)));
   end % switch
   return
end