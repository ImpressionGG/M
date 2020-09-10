function len = piece(o)
%
% PIECE    Length of a data piece. The data piece can be a column or a line
%          and can be extracted from the method matrix. Here are examples
%          for the method matrix:
%
%             len = piece(o)
%
%          Methods:
%             method = [x0 y0; 0 1;  1 -1]   % column wise saw
%             method = [x0 y0; 0 1;  1  0]   % column wise meander
%             method = [x0 y0; 1 0; -1  1]   % row wise saw
%             method = [x0 y0; 1 0;  0  1]   % column wise meander
%
%          Copyright(c): Bluenetics 2020 
%
%          See also: CORDOBA, COOK
%
   [m,n,r] = sizes(o);
   
   if m*n*r == 0
      len = 0;
      return
   end
   
   meth = get(o,'method');
   if isempty(meth)
      len = m*n;
      return
   end
   
   if ischar(meth)
      meth = method(o,meth);           % get method matrix
   end
   
   if meth(2,1) == 0                   % this means column wise
      len = m;
   elseif meth(2,2) == 0               % this means row wise
      len = n;
   else
      len = m*n;                       % otherwise whole matrix
   end
end
