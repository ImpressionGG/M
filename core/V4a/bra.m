function varargout = bra(obj,varargin)
%
% BRA   Get a bra vector from a given space, or check if object is a bra
%
%    1) Check if toy object is a bra vector
%
%       isbra = bra(u)                  % boolean result whether u is a bra
%
%    2) Get one or more bra vectors from a given space by numerical or
%    symbolic index
%
%       H = space('spin');
%       u = bra(H,1);                   % reference by numeric index
%       d = bra(H,'d');                 % reference by label
%       [l,r] = bra(H,'l','r');         % multiple bra vectors
%
%    See also: TOY, VECTOR, KET, SPACE
%
   if (nargin == 0)
      error('at least 1 input arg expected!');
   elseif (nargin == 1)
      varargout{1} = property(obj,'bra?');
   elseif (nargin == 2)
      varargout{1} = vector(obj,varargin{1})';
   else
      for (i=1:length(varargin))
         varargout{i} = bra(obj,varargin{i});
      end
   end
   return
end
