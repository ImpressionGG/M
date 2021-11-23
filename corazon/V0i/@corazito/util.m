function varargout = util(o,varargin)
%
% UTIL   Get function handles for utility functions
%
%    One reason to provide utility functions via function handles is to
%    provide utility functions without function name clashes
%
%    Setup some short hands (function handles) in base environment
%
%       util(corazito);      % setup: either, iif, is, cuo, sho, ticn, tocn
%    
%    Assign utility functions
%
%       [iif,either..] = util('iif','either',..)  % return function hdls
%
%    Utility functions:
%       color                % color setting
%       either               % either function
%       iif                  % inline if
%       is                   % isempty or find string in list or compare
%       isfigure             % check if handle is a figure handle
%       isghandle            % check if handle is a graphics handle
%       isscreen             % check if handle is a screen handle
%       rd                   % round to n digits
%       trim                 % trim text
%       uscore               % manage underscores in texts
%
%    Examples:
%
%       iif = util(o,'iif');
%       value = iif(flag,1,0);
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO
%
   if (nargin == 1)
      Shorthands(o)
      return
   end
   
   if (nargin-1 ~= nargout)
      error('number of input and output args must match');
   end
 
   for (i=1:length(varargin))
      if ~ischar(varargin{i})
         error('all input args must be string!');
      end
   end
%
% Define functions
%
   locals = {'isfigure','isghandle','isscreen','uscore'};
   statics = {'color','either','iif','is','rd','trim','ticn','tocn'};
          
   for (i=1:length(varargin))
      func = varargin{i};
      switch func
         case locals
            cmd = ['@',func];
            fhdl = eval(cmd);
         case statics
            cmd = ['@corazito.',func];
            fhdl = eval(cmd);
         otherwise
            error(['no utility function: ',func]);
      end
      varargout{i} = fhdl;
   end
   return
end

%==========================================================================

function Shorthands(o)                 % Setup some short hands
   evalin('base','iif=@corazito.iif;');
   evalin('base','is=@corazito.is;');
   evalin('base','either=@corazito.either;');
%  evalin('base','cuo=@corazito.cuo;');
%  evalin('base','sho=@corazito.sho;');
   evalin('base','ticn=@corazito.ticn;');
   evalin('base','tocn=@corazito.tocn;');
end

%==========================================================================
% Utility Functions
%==========================================================================

function num = gnumber(list)           % Get Numeric Graphics Handle   
%
% GNUMBER   Get numeric graphics handle from a handle graphics handle 
%           object.
%
%              hdl = gnumber(gcf);
%
%           Return value is either a double value or empty [] if no 
%           graphics handle.
%
%           See also: UTIL, ISGHANDLE
%
   hdl = list{1};
   num = [];                           % empty return value by default
   if isgraphics(hdl)
       if isa(hdl,'double')
           num = hdl;                  % we can return the double value
       else
           num = hdl.Number;
       end
   end
end

function ok = isghandle(hdl)           % Is Object a Graphics Handle   
%
% ISGHANDLE   Is object a valid graphics handle. Works for R2014 but also
%             lower versions
%
%                ok = isghandle(hdl)
%
%             See also: UTIL, GNUMBER
%

   either = @corazito.either;
   ok = either(any(IsGraphics(hdl)),0) || isa(hdl,'double');
   if ~ok
       cla = class(hdl);
       if isequal(cla,{'matlab.ui.container.Menu'})
           ok = 1;                     % also for deleted menu objects
       end
   end
   function isok = IsGraphics(handle)
      if exist('isgraphics') == 0
         isok = true;
      else
         isok = isgraphics(handle);
      end
   end
end

function ok = isfigure(hdl)            % Is Object a Figure Handle     
%
% ISFIGURE   Check if graphics handle is a figure handle
%
%               ok = isfigure(gcf)
%
%            See also: UTIL, ISGHANDLE, ISSCREEN
%
   ok = 0;                             % init not OK by default
   if isghandle(hdl) && ~isempty(hdl)
       if isa(hdl,'double')
           ok = (round(hdl)==hdl && hdl ~= 0);
       else
           ok = isequal(class(hdl),'matlab.ui.Figure');
       end
   end
end

function ok = isscreen(hdl)            % Is Object a Screen handle     
%
% ISSCREEN   Check if graphics handle is the screen handle
%
%               ok = isscreen(gcf)
%
%            See also: UTIL, ISGHANDLE, ISFIGURE
%
   ok = 0;                             % init not OK by default
   if isghandle(hdl) &&  ~isempty(hdl)
       if isa(hdl,'double')
           ok = (hdl == 0);
       else
           ok = isequal(class(hdl),'matlab.ui.Root');
       end
   end
end

function otxt = uscore(txt)            % Underscore Management         
%
% USCORE Treat a text string with underscores
%
%    Treat a text string with underscores to show underscores
%    properly. The reason to have this function is that MATLAB
%    functions like TITLE, XLABEL, YLABEL, TEXT treat the under-
%    score character as a meta character to interprete the
%    following character as a subscript. This is prevented by the 
%    USCORE function.
%            
%       txt = uscore(corazon,'sample_text');
%
%    Try this:
%       title('sample_text');
%       title(uscore(corazon,'sample_text'));
%
%    The USCORE functionality can be deactivated by clearing
%    option 'underscore', e.g.
%
%       o = opt(corazon,'underscore',0);
%       title(underscore(o,'sample_text')); % no substitution !!!
%
%    See also: CORAZON, TEXT
%
   if isempty(txt)
      otxt = '';
      return
   end
   
   if (~ischar(txt) || size(txt,1) > 1)
      error('arg1 must be a character string!');
   end

   usc = true;
   if (usc)
      otxt = '';
      for (i=1:length(txt))
         c = txt(i);
         if (c == '_')
            otxt(1,end+1:end+2) = '\_';
         else
            otxt(1,end+1) = c;
         end
      end
   else
      otxt = txt;       % no substitution
   end
end

