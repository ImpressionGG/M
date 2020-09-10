function varargout = ket(obj,varargin)
%
% KET   Get a ket vector from a given space, or check if object is a ket
%
%    1) Check if toy object is a ket vector
%
%       isket = ket(u)                  % boolean result whether u is a ket
%
%    2) Get one or more ket vectors from a given space by numerical or
%    symbolic index
%
%       H = space('spin');
%       u = ket(H,1);                   % reference by numeric index
%       d = ket(H,'d');                 % reference by label
%       [l,r] = ket(H,'l','r');         % multiple ket vectors
%
%    See also: TOY, VECTOR, BRA, SPACE
%
   if (nargin == 0)
      error('at least 1 input arg expected!');
   elseif (nargin == 1)
      varargout{1} = property(obj,'ket?');
   elseif (nargin == 2)
      varargout{1} = vector(obj,varargin{1});
   else
      for (i=1:length(varargin))
         varargout{i} = ket(obj,varargin{i});
      end
   end
   return
end
