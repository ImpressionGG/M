function oo = dialog(o,varargin)
%
% DIALOG   Open and manage an input dialog box for several applications
%
%          1) New Package Dialog
%
%             oo = dialog(o,'Simple')  % dialog for title & comment
%             oo = dialog(o,'Package') % dialog for new package 
%             oo = dialog(o,'Plain')   % dialog for new plain package 
%             oo = dialog(o,'Project') % dialog for new project 
%             oo = dialog(o,'Control') % dialog for title & comment
%
%          See also: CARAMEL, NEW
%
   [gamma,oo] = manage(o,varargin,@Simple,@Package,@Plain,@Project,@Control);
   oo = gamma(oo);
end

%==========================================================================
% Published Local Functions
%==========================================================================

function oo = Simple(o)                % Dialog for Title & Comment    
   caption = opt(o,{'caption','Title and Comment'});
   prompts = {'Title','Comment'};
   
   title = get(o,{'title',''});
   comment = get(o,{'comment',{}});
   if ischar(comment)
      comment = {comment};
   end
%
% We have to convert comments into a text block
%
   text = '';
   for (i=1:length(comment))
      line = comment{i};
      if o.is(line)
         text(i,1:length(line)) = line;
      end
   end
%
% Now prepare for the input dialog
%
   prompts = {'Title','Comment'};
   values = {title,text};
   
   values = inputdlg(prompts,caption,[1 50;10 50],values);   
   if isempty(values)
      oo = [];
      return                           % user pressed CANCEL
   end
   
   title = o.either(values{1},title);
   text = values{2};
   comment = {};
   for (i=1:size(text,1))
      comment{i,1} = o.trim(text(i,:),+1);   % right trim
   end
   
   oo = set(o,'title',title,'comment',comment);
end
function oo = Package(o,kind)          % Dialog for New Package        
%
% Package   A dialog box is opened to enter object parameters for new
%           package creation.
%
   if (nargin < 2)
      kind = o.either(arg(o,1),'any'); % contained type
   end
   
   head = [get(o,'package'),'.',upper(kind)];
   caption = opt(o,{'caption',['New Package (',head,')']});
   [date,time] = o.now;
   name = get(o,{'title',[date,'@',time]});
   comment = get(o,{'comment',{}});
   if ischar(comment)
      comment = {comment};
   end
%
% We have to convert comments into a text block
%
   text = '';
   for (i=1:length(comment))
      line = comment{i};
      if o.is(line)
         text(i,1:length(line)) = line;
      end
   end
%
% Now prepare for the input dialog
%
   prompts = {'Name','Comment'};
   values = {name,text};
   
   %values = inputdlg(prompts,caption,[1 50;10 50],values);   
   values = inputdlg(prompts,caption,[1 50;10 50],values);   
   if isempty(values)
      oo = [];
      return                           % user pressed CANCEL
   end
   
   name = values{1};
   text = values{2};
   comment = {};
   for (i=1:size(text,1))
      comment{i,1} = o.trim(text(i,:),+1);   % right trim
   end

      % additionally we store title and comment from the dialog
      % into the object variables, so functions who create trace objects
      % can access the dialog output info
      
   oo = o;                             % duplicate object
   oo = var(oo,'title',name);
   oo = var(oo,'comment',comment);
   
   package = get(oo,{'package','@0000.0'});
   if isempty(name)
      oo = set(oo,'title',[package,'.',upper(kind)]);
   elseif opt(o,'plain')
      oo = set(oo,'title',name);
   else
      oo = set(oo,'title',[package,'.',upper(kind),' ',name]);
   end
   oo = set(oo,'comment',comment);
end
function oo = Plain(o,kind)            % Dialog for New Plain Package        
%
% Package   A dialog box is opened to enter object parameters for new
%           package creation.
%
   if (nargin < 2)
      kind = o.either(arg(o,1),'any'); % contained type
   end
   
   head = [get(o,'package'),'.',upper(kind)];
   caption = opt(o,{'caption',['New Package (',head,')']});
   [date,time] = o.now;
   name = get(o,{'title',[date,'@',time]});
   comment = get(o,{'comment',{}});
   if ischar(comment)
      comment = {comment};
   end
%
% We have to convert comments into a text block
%
   text = '';
   for (i=1:length(comment))
      line = comment{i};
      if o.is(line)
         text(i,1:length(line)) = line;
      end
   end
%
% Now prepare for the input dialog
%
   prompts = {'Name','Comment'};
   values = {name,text};
   
   values = inputdlg(prompts,caption,[1 50;10 50],values);   
   if isempty(values)
      oo = [];
      return                           % user pressed CANCEL
   end
   
   name = values{1};
   text = values{2};
   comment = {};
   for (i=1:size(text,1))
      comment{i,1} = o.trim(text(i,:),+1);   % right trim
   end

      % additionally we store title and comment from the dialog
      % into the object variables, so functions who create trace objects
      % can access the dialog output info
      
   oo = o;                             % duplicate object
   oo = var(oo,'title',name);
   oo = var(oo,'comment',comment);
   
   package = get(oo,{'package','@0000.0'});
   if isempty(name)
      oo = set(oo,'title',[package,'.',upper(kind)]);
   else
      oo = set(oo,'title',name);       % !!!!! plain !!!!!
   end
   oo = set(oo,'comment',comment);
end
function oo = Project(o)               % Dialog for New Project        
   caption = 'New Project';
   prompts = {'Project Name'};
   [date,~] = o.now;
   project = ['Project ',date];
   
   loop = true;
   while (loop)
      values = {project};
      values = inputdlg(prompts,caption,[1 50],values);   
      if isempty(values)
         oo = [];
         return                        % user pressed CANCEL
      end

      project = values{1};
      if isempty(project)
         errordlg('Project name must be non-empty!','Error','modal');
         continue;
      end
      
      forbidden = ':/\';
      
      loop = false;                    % give it a trial
      for (i=1:length(project))
         if any(project(i) == forbidden)
            errordlg({'Project names cannot contain',...
                   ' characters like '':'', ''/'' or ''\''!'},'Error','modal');
            loop = true;               % must loop once more 
            break
         end
      end
   end
   oo = set(o,'project',project);
end

function [title,package,machine] = PackageParameters(o,name,kind)
   [date,time] = o.now;
   name = o.either(name,[date,'@',time]);
   machine = get(o,{'machine','95000000000'});
   run = get(o,{'run',1});
   package = sprintf('@%s.%g',machine(end-3:end),run);
   if isempty(name)
      title = [package,'.',upper(kind)];
   else
      title = [package,'.',upper(kind),' ',name];
   end
end

%==========================================================================
% Control Dialog
%==========================================================================

function oo = Control(o)               % Control Dialog                
   caption = opt(o,{'caption','Title and Comment'});
   prompts = {'Title','Comment'};
   
   title = get(o,{'title',''});
   comment = get(o,{'comment',{}});
   if ischar(comment)
      comment = {comment};
   end
%
% We have to convert comments into a text block
%
   text = '';
   for (i=1:length(comment))
      line = comment{i};
      if o.is(line)
         text(i,1:length(line)) = line;
      end
   end
%
% Now prepare for the input dialog
%
   prompts = {'Title','Comment'};
   values = {title,text};
   
   values = InputDlg(prompts,caption,[1 50;10 50],values);   
   if isempty(values)
      oo = [];
      return                           % user pressed CANCEL
   end
   
   title = o.either(values{1},title);
   text = values{2};
   comment = {};
   for (i=1:size(text,1))
      comment{i,1} = o.trim(text(i,:),+1);   % right trim
   end
   
   oo = set(o,'title',title,'comment',comment);
end

%==========================================================================
% Input Dialog
%==========================================================================

function Answer = InputDlg(Prompt, Title, NumLines, DefAns, resize)    
%INPUTDLG Input dialog box.
%  ANSWER = INPUTDLG(PROMPT) creates a modal dialog box that returns user
%  input for multiple prompts in the cell array ANSWER. PROMPT is a cell
%  array containing the PROMPT strings.
%
%  INPUTDLG uses UIWAIT to suspend execution until the user responds.
%
%  ANSWER = INPUTDLG(PROMPT,NAME) specifies the title for the dialog.
%
%  ANSWER = INPUTDLG(PROMPT,NAME,NUMLINES) specifies the number of lines for
%  each answer in NUMLINES. NUMLINES may be a constant value or a column
%  vector having one element per PROMPT that specifies how many lines per
%  input field. NUMLINES may also be a matrix where the first column
%  specifies how many rows for the input field and the second column
%  specifies how many columns wide the input field should be.
%
%  ANSWER = INPUTDLG(PROMPT,NAME,NUMLINES,DEFAULTANSWER) specifies the
%  default answer to display for each PROMPT. DEFAULTANSWER must contain
%  the same number of elements as PROMPT and must be a cell array of
%  strings.
%
%  ANSWER = INPUTDLG(PROMPT,NAME,NUMLINES,DEFAULTANSWER,OPTIONS) specifies
%  additional options. If OPTIONS is the string 'on', the dialog is made
%  resizable. If OPTIONS is a structure, the fields resize, WindowStyle, and
%  Interpreter are recognized. resize can be either 'on' or
%  'off'. WindowStyle can be either 'normal' or 'modal'. Interpreter can be
%  either 'none' or 'tex'. If Interpreter is 'tex', the prompt strings are
%  rendered using LaTeX.
%
%  Examples:
%
%  prompt={'Enter the matrix size for x^2:','Enter the colormap name:'};
%  name='Input for Peaks function';
%  numlines=1;
%  defaultanswer={'20','hsv'};
%
%  answer=inputdlg(prompt,name,numlines,defaultanswer);
%
%  options.resize='on';
%  options.WindowStyle='normal';
%  options.Interpreter='tex';
%
%  answer=inputdlg(prompt,name,numlines,defaultanswer,options);
%
%  See also DIALOG, ERRORDLG, HELPDLG, LISTDLG, MSGBOX,
%    QUESTDLG, TEXTWRAP, UIWAIT, WARNDLG .

%  Copyright 1994-2010 The MathWorks, Inc.
%  $Revision: 1.58.4.21 $

%%%%%%%%%%%%%%%%%%%%
%%% Nargin Check %%%
%%%%%%%%%%%%%%%%%%%%
   error(nargchk(0,5,nargin));
   error(nargoutchk(0,1,nargout));

   %%%%%%%%%%%%%%%%%%%%%%%%%
   %%% Handle Input Args %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%
   if nargin<1
     Prompt=getString(message('MATLAB:uistring:popupdialogs:InputDlgInput'));
   end
   if ~iscell(Prompt)
     Prompt={Prompt};
   end
   NumQuest=numel(Prompt);


   if nargin<2,
     Title=' ';
   end

   if nargin<3
     NumLines=1;
   end

   if nargin<4
     DefAns=cell(NumQuest,1);
     for lp=1:NumQuest
       DefAns{lp}='';
     end
   end

   if nargin<5
     resize = 'off';
   end
   WindowStyle='modal';
   Interpreter='none';

   Options = struct([]); %#ok
   if nargin==5 && isstruct(resize)
     Options = resize;
     resize  = 'off';
     if isfield(Options,'resize'),      resize=Options.resize;           end
     if isfield(Options,'WindowStyle'), WindowStyle=Options.WindowStyle; end
     if isfield(Options,'Interpreter'), Interpreter=Options.Interpreter; end
   end

   [rw,cl]=size(NumLines);
   OneVect = ones(NumQuest,1);
   if (rw == 1 & cl == 2) %#ok Handle []
     NumLines=NumLines(OneVect,:);
   elseif (rw == 1 & cl == 1) %#ok
     NumLines=NumLines(OneVect);
   elseif (rw == 1 & cl == NumQuest) %#ok
     NumLines = NumLines';
   elseif (rw ~= NumQuest | cl > 2) %#ok
     error(message('MATLAB:inputdlg:IncorrectSize'))
   end

   if ~iscell(DefAns),
     error(message('MATLAB:inputdlg:InvalidDefaultAnswer'));
   end

   %%%%%%%%%%%%%%%%%%%%%%%
   %%% Create InputFig %%%
   %%%%%%%%%%%%%%%%%%%%%%%
   FigWidth=175;
   FigHeight=100;
   FigPos(3:4)=[FigWidth FigHeight];  %#ok
   FigColor=get(0,'DefaultUicontrolBackgroundColor');

   InputFig=dialog(                     ...
     'Visible'          ,'off'      , ...
     'KeyPressFcn'      ,@FigureKeyPress, ...
     'Name'             ,Title      , ...
     'Pointer'          ,'arrow'    , ...
     'Units'            ,'pixels'   , ...
     'UserData'         ,'Cancel'   , ...
     'Tag'              ,Title      , ...
     'HandleVisibility' ,'callback' , ...
     'Color'            ,FigColor   , ...
     'NextPlot'         ,'add'      , ...
     'WindowStyle'      ,WindowStyle, ...
     'resize'           ,resize       ...
     );


   %%%%%%%%%%%%%%%%%%%%%
   %%% Set Positions %%%
   %%%%%%%%%%%%%%%%%%%%%
   DefOffset    = 5;
   DefBtnWidth  = 53;
   DefBtnHeight = 23;

   TextInfo.Units              = 'pixels'   ;
   TextInfo.FontSize           = get(0,'FactoryUicontrolFontSize');
   TextInfo.FontWeight         = get(InputFig,'DefaultTextFontWeight');
   TextInfo.HorizontalAlignment= 'left'     ;
   TextInfo.HandleVisibility   = 'callback' ;

   StInfo=TextInfo;
   StInfo.Style              = 'text'  ;
   StInfo.BackgroundColor    = FigColor;


   EdInfo=StInfo;
   EdInfo.FontWeight      = get(InputFig,'DefaultUicontrolFontWeight');
   EdInfo.Style           = 'edit';
   EdInfo.BackgroundColor = 'white';

   BtnInfo=StInfo;
   BtnInfo.FontWeight          = get(InputFig,'DefaultUicontrolFontWeight');
   BtnInfo.Style               = 'pushbutton';
   BtnInfo.HorizontalAlignment = 'center';

   % Add VerticalAlignment here as it is not applicable to the above.
   TextInfo.VerticalAlignment  = 'bottom';
   TextInfo.Color              = get(0,'FactoryUicontrolForegroundColor');


   % adjust button height and width
   btnMargin=1.4;
   ExtControl=uicontrol(InputFig   ,BtnInfo     , ...
     'String'   ,getString(message('MATLAB:uistring:popupdialogs:Cancel'))        , ...
     'Visible'  ,'off'         ...
     );

   % BtnYOffset  = DefOffset;
   BtnExtent = get(ExtControl,'Extent');
   BtnWidth  = max(DefBtnWidth,BtnExtent(3)+8);
   BtnHeight = max(DefBtnHeight,BtnExtent(4)*btnMargin);
   delete(ExtControl);

   % Determine # of lines for all Prompts
   TxtWidth=FigWidth-2*DefOffset;
   ExtControl=uicontrol(InputFig   ,StInfo     , ...
     'String'   ,''         , ...
     'Position' ,[ DefOffset DefOffset 0.96*TxtWidth BtnHeight ] , ...
     'Visible'  ,'off'        ...
     );

   WrapQuest=cell(NumQuest,1);
   QuestPos=zeros(NumQuest,4);

   for ExtLp=1:NumQuest
     if size(NumLines,2)==2
       [WrapQuest{ExtLp},QuestPos(ExtLp,1:4)]= ...
         textwrap(ExtControl,Prompt(ExtLp),NumLines(ExtLp,2));
     else
       [WrapQuest{ExtLp},QuestPos(ExtLp,1:4)]= ...
         textwrap(ExtControl,Prompt(ExtLp),80);
     end
   end % for ExtLp

   delete(ExtControl);
   QuestWidth =QuestPos(:,3);
   QuestHeight=QuestPos(:,4);
   if ismac % Change Edit box height to avoid clipping on mac.
       editBoxHeightScalingFactor = 1.4;
   else 
       editBoxHeightScalingFactor = 1;
   end
   TxtHeight=QuestHeight(1)/size(WrapQuest{1,1},1) * editBoxHeightScalingFactor;
   EditHeight=TxtHeight*NumLines(:,1);
   EditHeight(NumLines(:,1)==1)=EditHeight(NumLines(:,1)==1)+4;

   FigHeight=(NumQuest+2)*DefOffset    + ...
     BtnHeight+sum(EditHeight) + ...
     sum(QuestHeight);

   TxtXOffset=DefOffset;

   QuestYOffset=zeros(NumQuest,1);
   EditYOffset=zeros(NumQuest,1);
   QuestYOffset(1)=FigHeight-DefOffset-QuestHeight(1);
   EditYOffset(1)=QuestYOffset(1)-EditHeight(1);

   for YOffLp=2:NumQuest,
     QuestYOffset(YOffLp)=EditYOffset(YOffLp-1)-QuestHeight(YOffLp)-DefOffset;
     EditYOffset(YOffLp)=QuestYOffset(YOffLp)-EditHeight(YOffLp);
   end % for YOffLp

   QuestHandle=[];
   EditHandle=[];

   AxesHandle=axes('Parent',InputFig,'Position',[0 0 1 1],'Visible','off');

   inputWidthSpecified = false;

   for lp=1:NumQuest,
     if ~ischar(DefAns{lp}),
       delete(InputFig);
       error(message('MATLAB:inputdlg:InvalidInput'));
     end


     EditHandle(lp)=uicontrol(InputFig    , ...
       EdInfo      , ...
       'Max'        ,NumLines(lp,1)       , ...
       'Position'   ,[ TxtXOffset EditYOffset(lp) TxtWidth EditHeight(lp)], ...
       'String'     ,DefAns{lp}           , ...
       'Tag'        ,'Edit'                 ...
       );

     QuestHandle(lp)=text('Parent'     ,AxesHandle, ...
       TextInfo     , ...
       'Position'   ,[ TxtXOffset QuestYOffset(lp)], ...
       'String'     ,WrapQuest{lp}                 , ...
       'Interpreter',Interpreter                   , ...
       'Tag'        ,'Quest'                         ...
       );

     MinWidth = max(QuestWidth(:));
     if (size(NumLines,2) == 2)
       % input field width has been specified.
       inputWidthSpecified = true;
       EditWidth = SetColumnWidth(EditHandle(lp), NumLines(lp,1), NumLines(lp,2));
       MinWidth = max(MinWidth, EditWidth);
     end
     FigWidth=max(FigWidth, MinWidth+2*DefOffset);

   end % for lp

   % fig width may have changed, update the edit fields if they dont have user specified widths.
   if ~inputWidthSpecified
     TxtWidth=FigWidth-2*DefOffset;
     for lp=1:NumQuest
       set(EditHandle(lp), 'Position', [TxtXOffset EditYOffset(lp) TxtWidth EditHeight(lp)]);
     end
   end

   FigPos=get(InputFig,'Position');

   FigWidth=max(FigWidth,2*(BtnWidth+DefOffset)+DefOffset);
   FigPos(1)=0;
   FigPos(2)=0;
   FigPos(3)=FigWidth;
   FigPos(4)=FigHeight;

   set(InputFig,'Position',getnicedialoglocation(FigPos,get(InputFig,'Units')));

   OKHandle=uicontrol(InputFig     ,              ...
     BtnInfo      , ...
     'Position'   ,[ FigWidth-2*BtnWidth-2*DefOffset DefOffset BtnWidth BtnHeight ] , ...
     'KeyPressFcn',@ControlKeyPress , ...
     'String'     ,getString(message('MATLAB:uistring:popupdialogs:OK'))        , ...
     'Callback'   ,@Callback , ...
     'Tag'        ,'OK'        , ...
     'UserData'   ,'OK'          ...
     );

   setdefaultbutton(InputFig, OKHandle);

   CancelHandle=uicontrol(InputFig     ,              ...
     BtnInfo      , ...
     'Position'   ,[ FigWidth-BtnWidth-DefOffset DefOffset BtnWidth BtnHeight ]           , ...
     'KeyPressFcn',@ControlKeyPress            , ...
     'String'     ,getString(message('MATLAB:uistring:popupdialogs:Cancel'))    , ...
     'Callback'   ,@Callback , ...
     'Tag'        ,'Cancel'    , ...
     'UserData'   ,'Cancel'       ...
     ); %#ok

   handles = guihandles(InputFig);
   handles.MinFigWidth = FigWidth;
   handles.FigHeight   = FigHeight;
   handles.TextMargin  = 2*DefOffset;
   guidata(InputFig,handles);
   set(InputFig,'ResizeFcn', {@DoResize, inputWidthSpecified});

   % make sure we are on screen
   movegui(InputFig)

   % if there is a figure out there and it's modal, we need to be modal too
   if ~isempty(gcbf) && strcmp(get(gcbf,'WindowStyle'),'modal')
     set(InputFig,'WindowStyle','modal');
   end

   set(InputFig,'Visible','on');
   drawnow;

   if ~isempty(EditHandle)
     uicontrol(EditHandle(1));
   end

   if ishghandle(InputFig)
     % Go into uiwait if the figure handle is still valid.
     % This is mostly the case during regular use.
     uiwait(InputFig);
   end

   % Check handle validity again since we may be out of uiwait because the
   % figure was deleted.
   if ishghandle(InputFig)
     Answer={};
     if strcmp(get(InputFig,'UserData'),'OK'),
       Answer=cell(NumQuest,1);
       for lp=1:NumQuest,
         Answer(lp)=get(EditHandle(lp),{'String'});
       end
     end
     delete(InputFig);
   else
     Answer={};
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function FigureKeyPress(obj, evd)      % ok                            
   switch(evd.Key)
     case {'return','space'}
       set(gcbf,'UserData','OK');
       uiresume(gcbf);
     case {'escape'}
       delete(gcbf);
   end
end
function ControlKeyPress(obj, evd)     % ok                            
   switch(evd.Key)
     case {'return'}
       if ~strcmp(get(obj,'UserData'),'Cancel')
         set(gcbf,'UserData','OK');
         uiresume(gcbf);
       else
         delete(gcbf)
       end
     case 'escape'
       delete(gcbf)
   end
end
function Callback(obj, evd)            % ok                            
   if ~strcmp(get(obj,'UserData'),'Cancel')
     set(gcbf,'UserData','OK');
     uiresume(gcbf);
   else
     delete(gcbf)
   end
end
function DoResize(FigHandle, evd, multicolumn) % ok                    
% TBD: Check difference in behavior w/ R13. May need to implement
% additional resize behavior/clean up.

   Data=guidata(FigHandle);

   resetPos = false;

   FigPos = get(FigHandle,'Position');
   FigWidth = FigPos(3);
   FigHeight = FigPos(4);

   if FigWidth < Data.MinFigWidth
     FigWidth  = Data.MinFigWidth;
     FigPos(3) = Data.MinFigWidth;
     resetPos = true;
   end

   % make sure edit fields use all available space if
   % number of columns is not specified in dialog creation.
   if ~multicolumn
     for lp = 1:length(Data.Edit)
       EditPos = get(Data.Edit(lp),'Position');
       EditPos(3) = FigWidth - Data.TextMargin;
       set(Data.Edit(lp),'Position',EditPos);
     end
   end

   if FigHeight ~= Data.FigHeight
     FigPos(4) = Data.FigHeight;
     resetPos = true;
   end

   if resetPos
     set(FigHandle,'Position',FigPos);
   end
end
function EditWidth = SetColumnWidth(object, rows, cols)                
   % set pixel width given the number of columns
   % Save current Units and String.
   old_units = get(object, 'Units');
   old_string = get(object, 'String');
   old_position = get(object, 'Position');

   set(object, 'Units', 'pixels')
   set(object, 'String', char(ones(1,cols)*'x'));

   new_extent = get(object,'Extent');
   if (rows > 1)
     % For multiple rows, allow space for the scrollbar
     new_extent = new_extent + 19; % Width of the scrollbar
   end
   new_position = old_position;
   new_position(3) = new_extent(3) + 1;
   set(object, 'Position', new_position);

   % reset string and units
   set(object, 'String', old_string, 'Units', old_units);

   EditWidth = new_extent(3);
end
