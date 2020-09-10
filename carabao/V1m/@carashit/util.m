function varargout = util(o,varargin)
%
% UTIL   Get function handles for utility functions
%
%    One reason to provide utility functions via function handles is to
%    provide utility functions without function name clashes
%
%    Setup some short hands (function handles) in base environment
%
%       utility(carashit);   % setup: cuo, gfo, ticn, tocn
%    
%    Assign utility functions
%
%       [ticn,tocn..] = util('ticn','tocn',..)  % return function hdls
%
%    Utility functions:
%       cuo                  % get current figure object
%       gfo                  % get figure object
%       ticn                 % tic for n loops
%       tocn                 % toc for n loops
%
%    Examples:
%
%       cuo = util(o,'cuo');
%       oo = cuo(o);
%
%    See also: CARASHIT
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
   locals = {};
   statics = {'cuo','gfo','ticn','tocn'};
          
   for (i=1:length(varargin))
      func = varargin{i};
      switch func
         case locals
            cmd = ['@',func];
            fhdl = eval(cmd);
         case statics
            cmd = ['@carashit.',func];
            fhdl = eval(cmd);
         otherwise
            fhdl = util(carabao,varargin{i});
      end
      varargout{i} = fhdl;
   end
   return
end

%==========================================================================

function Shorthands(o)                 % Setup some short hands
   evalin('base','cuo=@carashit.cuo;');
   evalin('base','gfo=@carashit.gfo;');
   evalin('base','ticn=@carashit.ticn;');
   evalin('base','tocn=@carashit.tocn;');
end

%==========================================================================
% Utility Functions
%==========================================================================

function o = gfo                       % Get Figure Object             
   o = pull(carabao);
end

