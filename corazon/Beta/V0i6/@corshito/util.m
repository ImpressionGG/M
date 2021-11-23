function varargout = util(o,varargin)
%
% UTIL   Get function handles for utility functions
%
%    One reason to provide utility functions via function handles is to
%    provide utility functions without function name clashes
%
%    Setup some short hands (function handles) in base environment
%
%       utility(corshito);   % setup: cuo, gfo, ticn, tocn
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
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORSHITO
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
            cmd = ['@corshito.',func];
            fhdl = eval(cmd);
         otherwise
            fhdl = util(corazon,varargin{i});
      end
      varargout{i} = fhdl;
   end
   return
end

%==========================================================================

function Shorthands(o)                 % Setup some short hands
   evalin('base','cuo=@corshito.cuo;');
   evalin('base','gfo=@corshito.gfo;');
   evalin('base','ticn=@corshito.ticn;');
   evalin('base','tocn=@corshito.tocn;');
end

%==========================================================================
% Utility Functions
%==========================================================================

function o = gfo                       % Get Figure Object             
   o = pull(corazon);
end

