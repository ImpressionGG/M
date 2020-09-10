function [cob,dob,pob] = tutor(obj,arg)
% 
% TUTOR   Building block functions for tutorials
%    
%    Functions to display text, execute command lines or display headings
%    and tasks on the screen. 
%
%    The TUTOR member function called with one input argument dispatches on
%    the CORE object type.
%
%    1) Clear screen, clear command window, clear both
%
%       tutor(core('cls'));                % clear screen & init parameters
%       tutor(core('clc'));                % clear command window
%       tutor(core('clear'));              % clear screen & command window
%
%    2) Display topic/task after clearing screen/command
%
%       tutor(core,obj);                   % clear & draw heading 
%       [cmd,dsp,scr] = tutor(core,obj);   % clear & draw heading, 
%                                          % setup tutor objects
%
%    Note: as this function call is normally the first of a TUT sequence
%    its syntax is exception. The first argument - a CORE object - can be
%    of any type. This allows to write more compact code
%
%    3) Displaying text on both screen & command window
%
%       tutor(core('display'),'My Text');
%
%    4) Execute a command in the basis environment
%
%       tutor(core('command'),'A = magic(3)');
%
%    X) Setting up TUT objects
%
%    As the TUT function dispatches on the CORE object type this allows
%    for setting up CORE objects with differen type for repeatet use at
%    later time.
%
%    E.g, instead of writing
%
%       tutor(core,obj);                   % clear & display topic/task
%       tutor(core('display'),'Let us start with a magic matrix.');
%       tutor(core('command'),'A = magic(3)'); 
%       tutor(core('display'),'Calculate the inverse matrix.');
%       tutor(core('command'),'B = inv(A)'); 
%
%    we can write simpler
%
%       [cmd,dsp,prt] = tutor(core,obj);  % clear & display topic/task
%       tutor(dsp,'Let us start with a magic matrix.');
%       tutor(cmd,'A = magic(3)'); 
%       tutor(dsp,'Calculate the inverse matrix.');
%       tutor(cmd,'B = inv(A)'); 
%
%    The statement
%
%       [cmd,dsp,scr] = tutor(core);      % setup tutor objects
%
%    is equivalent to the three statements
%
%       cmd = core('command'));           % CORE object of type 'command'
%       dsp = core('display'));           % CORE object of type 'display'
%       scr = core('screen'));            % CORE object of type 'screen'
%
%    See also: CORE, TOPIC, VIEW, NAVIGATE
%
   if (nargout > 0)
      cob = core('command');              % setup a command object
      dob = core('display');              % setup a display object
      pob = core('print');                % setup a screen object
   end
   
% First dispatch on special form: tutor(core,obj)

   if (nargin == 2)
      if isa(arg,'core')                  % then draw heading
         TopicTask(arg);                  % display topic & task
         navigation(arg);                 % setup navigation (view) handler
         return                           % then it's done
      end
   end
   
% Second dispatch on type

   typ = type(obj);
   switch typ
      case 'generic'
         'no action!';                    % no action for generic type
      case 'clc'                 
         clc;                             % clear command window
      case 'cls'
         cls;                             % clear screen
         text(gao,'','position','home');  % initialize text parameters
         shg;
      case 'clear'
         tutor(core('clc'));              % clear command window
         tutor(core('cls'));              % clear screen & initialize
      case 'command'
         arg = eval('arg{1}','arg');
         fprintf(['>> ',arg,'\n']);
         evalin('base',arg);
      case 'display'
         if (nargin ~= 2)
            error('2 input args expected for displaying text!');
         end
         arg = eval('arg{1}','arg');
         if iscell(arg) && isempty(arg)
            arg = '\n';
         end
         Display(arg);
      case 'print'
         if (nargin == 1)
            Print;
         elseif (nargin == 2)
            arg = eval('arg{1}','arg');
            Print(arg);
         else
            error('1 or 2 input args expected for printing text!');
         end
   end
   return
end

%==========================================================================
% Display Topic & Task
%==========================================================================

function TopicTask(obj)
%
% TOPIC-TASK
%
   [top,task] = topic(obj);
   if (~isempty(top) || ~isempty(task))
      cls;  bright;
      text(gao,'','position',[100 0],'halign','right','size',3);
   end
   
   if ~isempty(top)
      text(gao,[top]);

      text(gao,'','position','home','size',4);
      text(gao,'§§\n');
   end      
   if ~isempty(task)   
      Display(['§§',task]);
      text(gao,'\n');
      fprintf('%%\n');
   end
   shg;
   return
end

%==========================================================================
% Evaluate & Echo
%==========================================================================

function Eval(cmd)
%
% EVAL    Evaluate in base work space
%
   fprintf(['>> ',cmd,'\n']);
   evalin('base',cmd);
   return
end

function Print(line)
%
% Print   Print a line in command window
%
%            Print;
%            Print('my text');
%
   if (nargin == 0)
      fprintf('%%\n');
   elseif iscell(line) && isempty(line)
      fprintf(['%%\n']);
   else
      fprintf(['%% ',line,'\n']);
   end
   return
end

%==========================================================================
% Display a Text Line in Window
%==========================================================================

function Display(line)
%
% DISPLAY  Display a text line in window
%
%    Disp('my text');           % display text
%
   text(gao,[line,'\n']);
   shg;
   idx = find(line=='§');
   line(idx) = [];
   Print(line);
   return
end

