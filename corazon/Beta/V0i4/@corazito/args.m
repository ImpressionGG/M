function [nin,varargout] = args(list,varargin)
%
% ARGS   Process input args
%
%    The method is performing two functions:
%    1) If varargin is embedded as a first list element, it will un-embed
%    2) input arguments are assigned to variables, as long they are
%    available. If not available they will be assigned with either defaults 
%    (if defaults are provided
%
%           [nin,arg1,arg2,...] = o.args(varargin)
%
%    Example: A usual function header would be 
%
%       function y = lin(o,x,k,d)
%          if (nargin < 2) x = 0; end
%          if (nargin < 3) k = 1; end
%          if (nargin < 4) d = 2; end
%          y = k*x + d
%       end
%
%    and possible calling syntax could be
%
%       y = lin(o,x,k,d);              % all input args provided
%       y = lin(o,x,k);                % use default d = 2
%       y = lin(o,x);                  % use default k = 1, d = 2
%       y = lin(o);                    % use default x = 0, k = 1, d = 2
%
%    This function can be re-written:
%
%       function y = lin(o,varargin)
%          [nin,x,k,d] = o.args(varargin,0,1,2);
%          y = k*x + d
%       end
%
%    and possible calling syntax could be
%
%       y = lin(u,x,k,d);              % all input args provided
%       y = lin(u,x,k);                % use default d = 2
%       y = lin(u,x);                  % use default k = 1, d = 2
%       y = lin(u);                    % use default x = 0, k = 1, d = 2
%
%    but also (the case where varargin is embedded)
%
%       y = lin(o,{x,k,d});            % all input args provided
%       y = lin(o,{x,k});              % use default d = 2
%       y = lin(o,{x});                % use default k = 1, d = 2
%       y = lin(o,{});                 % use default x = 0, k = 1, d = 2
%
%    Not that this allows the definition of an abbreviated function
%
%       lin = @(varargin) lin(corazito,varargin);
%
%    which supports the calling syntax:
%
%       y = lin(x,k,d);                % all input args provided
%       y = lin(x,k);                  % use default d = 2
%       y = lin(x);                    % use default k = 1, d = 2
%       y = lin();                     % use default x = 0, k = 1, d = 2
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO
%
   if (length(list) == 1)              % look for embedded list        
      if iscell(list{1})               % is embedded in 1st list element?
         list = list{1};               % yes - un-embed list!
      end
   end
%
% now we have an un-embedded argument list. get the number of input args
%
   nin = length(list);                 % number of input args
%
% Transfer input args to out args. If not enough input args are provided
% use provided defaults from input arg list (varargin). If defaults are
% missing in the input arg list then provide [] as default.
%
   for (i=1:nargout-1)
      if (i <= length(list))
         varargout{i} = list{i};
      elseif (i <= length(varargin))
         varargout{i} = varargin{i};
      else
         varargout{i} = [];
      end
   end
end
