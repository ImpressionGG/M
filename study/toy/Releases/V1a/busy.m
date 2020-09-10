function out = busy(fig,msg)
%
% BUSY   Indicate a busy state
%
%    Indicate busy state by changing mouse pointer to a watch symbol.
%
%       busy          % change mouse pointer for current figure
%       busy(2)       % change mouse pointer for figure 2
%
%       busy('busy now ...')      % display text if available busy display
%       busy(gao,'busy now ...')  % display text (no condition)
%       busy(2,'busy now ...')    % display busy text in figure 2
%
%    More explanation:
%
%    Case 1: some library function makes busy messages, If in some
%    cases we want to see the messages, while in other cases not, we
%    will use the following sequences:
%
%       busy(gao,'');             % set up a centered busy display
%       busy('in progress ...');  % display the busy message
%
%       busy(gao,NaN);            % prevent further messages
%       busy('in progress ...');  % will not display
%
%    Case 2: to display an unconditional busy message we will use
%
%       busy(gao,'operation in progress ...')   % always display
%
%    Mind that this unconditional statement activates the busy display
%    and if library calls of the form busy('..') should be hidden then
%    we need to deaktivate the busy display again with busy(gao,NaN).
%
%    To pass further attributes to the busy function some options
%    can be passed through a smart object. These options are forwarded
%    to SMART/TEXT
%
%      smo = option(smart,'position',[50,0]);
%      smo = option(smart,'color','b');
%      smo = option(smart,'valign','bottom');
%      smo = option(smart,'halign','center');
%      smo = option(smart,'figure',2);
%
%      busy(smo,'busy now ...');      % display busy message
%      busy([]);                      % delete busy display
%
%   Example 1: setup an empty blue busy display at the bottom
%
%      busy(option(gao,'position','bottom'));    % setup busy display
%      busy(option(gao,'position','bottom'),''); % setup busy display
%
%   Example 2: setup an empty red busy display in the middle
%
%      busy(option(gao,'color','red'),'');       % setup busy display
%
%   Later on use the following commands for displaying busy/ready
%
%      busy('I am busy now ...');      % busy now
%      ready;                          % ready again
%
%   See also: SMART READY
%
   busymessage = 0;    % by default
   smo = [];           % by default
   
   if (nargin == 0)
      fig = gcf;  msg = '';
   elseif (nargin == 1)
      arg1 = fig;
      if isempty(arg1)
         hdl = gao('busy');
         eval('delete(hdl);','');
         gao('busy',[]);
      elseif isa(arg1,'double')
         msg = '';  fig = arg1;
         busymessage = 0;
      elseif ischar(arg1)
         msg = arg1;  fig = gcf;
         busymessage = 1;
      elseif isa(arg1,'smart')
         busy(arg1,'');
         return
      elseif ~ischar(fig)
         error('arg1 must be double (fig) or character string (message)!');
      end
   elseif (nargin == 2)
      if isa(fig,'smart')
         smo = fig;
         fig = either(option(smo,'figure'),gcf);
      elseif ~isdouble(fig)
         error('arg1 (fig) must be double!');
      end
      
      if isnan(msg)
         gao('busy',[]);        % deactivate busy display
         return
      elseif ~ischar(msg)
         error('arg2 (message) must be a character string!');
      end
      busymessage = 1;
   else
      error('max 2 args allowed!');      
   end
   
      % 1) change pointer symbol to 'busy' symbol

   try
      set(fig,'pointer','watch');
   catch
      set(gcf,'pointer','watch');
   end

      % 2) If message has to be displayed - display now
      % There are two cases:
      %
      % a) no smart object provided. In this case we will use an existing 
      %    GAO handle, otherwise a new one will be setup with default 
      %    settings
      %
      % b) smart object provided as first arg: the actual handle (if
      %    exists) will be deleted and a new busy text will be displayed
      %    according to the options of the smart object
      

   if (busymessage)
      msg = either(msg,' ');         % continue with always non-empty msg
      ready;                         % clear busy display
      smo = option(smo,'append',0);  % don't appen busy text
      
      if isempty(smo)                % case a) no smart object provided
         hdl = gao('busy');
         if isempty(hdl)             % ignore
            %smo = text(gao,msg,0.5,0.5,'size',16,'color','b');
            %hdl = arg(smo);
         else
            set(hdl,'string',underscore(smart,msg));
         end
      else
         hdl = gao('busy');
         eval('delete(hdl);','');
         
         size = either(option(smo,'size'),4);
         color = either(option(smo,'color'),'b');
         text(smo,'position','center','size',size,'color',color);
         smo = text(smo,msg);
         hdl = arg(smo);
      end
      gao('busy',hdl);
   end
   
   drawnow;
   if (nargout > 0) out = fig; end
   
   return
end 

