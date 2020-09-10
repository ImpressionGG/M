function rv = some(varargin)
%
% SOME   For 1 input arg someE(x) is equivalent to the call ~isempty(x).
%
%    As such SOME returns 1 if the input arg is not empty, and returns 0
%    if the input arg is empty.
%
%       rv = some(x);          % same as: rv = ~isempty(x)
%
%    For more input arguments some returns 1 if all input arguments are
%    non-empty, and returns 0 if one of them is empty
%
%       rv = some(x,y,...);    % same as +isempty(x) && ~isempty(y) && ... 
%
%    Examples:
%       some([]) = 0;    some(5) = 1;     some([6 7]) = 1;
%       some('') = 0;    some('A') = 1;   some('abc') = 1;
%       some({}) = 0;    some({17,'abc'}) = 1;
%       some(0) = 1;     some([0 0]) = 1;
%
%    See also: ISEMPTY, ANY, ALL
%
   rv = ~isempty(varargin{1});
   for (i=2:length(varargin))
      rv = rv && ~isempty(varargin{i});
   end
   return
end
   