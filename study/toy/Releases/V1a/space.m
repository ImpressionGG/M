function H = space(labels,arg)
%
% SPACE   Create a simple Hilbert space.
%
%    1) The resulting object is represented by a toy object with type
%    '#SPACE'. The basic calling syntax is with one input argument
%    being either a double matrix or a cell array.  
%
%       H = space(1:5);                          % 5D Hilbert space
%       H = space([1.1 1.2; 2.1 2.2]);           % 4D Hilbert space
%
%       H = space({'u';'d'});                    % 2D Hilbert space
%       H = space({'a','b','c'});                % 3D Hilbert space
%       H = space({'a11','a12';'a21','a22'});    % 3D Hilbert space
%
%    2) By providing 2 input args the Hilbert space can be initialized
%    with a basis matrix.
%
%       H = space({'a','b','c'},magic(3));
%
%    See also: CORE, TOY, TOY/SPACE
%
   if (nargin == 0)
      
      H = space(toy,{'u';'d'});
      H = setup(H,'r',[vector(H,'u')+vector(H,'d')]/sqrt(2));
      H = setup(H,'l',[vector(H,'u')-vector(H,'d')]/sqrt(2));
      H = setup(H,'i',[vector(H,'u')+i*vector(H,'d')]/sqrt(2));
      H = setup(H,'o',[vector(H,'u')-i*vector(H,'d')]/sqrt(2));
      
   elseif (nargin == 1)
      
      H = space(toy,labels);
      
   elseif (nargin == 2)
      
      H = space(toy,labels,arg);
      
   else
      
      error('max 3 input args expected!');
      
   end
   
   return
end

