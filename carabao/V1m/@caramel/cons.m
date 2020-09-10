function olist = cons(item,list)
%
% CONS   Construct a list in a lisp like style (static method)
%
%    Syntax
%       olist = cons(item,list);
%       olist = cons('X',{'A','B','C'});   % olist = {'X','A','B','C'}
%
%    See also: CARAMEL
%
   if ~iscell(list)
      error('Arg2 needs to be a list!');
   end

   olist = {item};
   for (i=1:length(list))
      olist{end+1} = list{i};
   end
end
