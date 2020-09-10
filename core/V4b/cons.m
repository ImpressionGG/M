function olist = cons(item,list)
%
% CONS   Construct a list in a lisp like style
%
%    Syntax
%       olist = cons(item,list);
%       olist = cons('X',{'A','B','C'});   % olist = {'X','A','B','C'}
%
%    See also: CORE
%
   if ~iscell(list)
      error('Arg2 needs to be a list!');
   end

   olist = {item};
   for (i=1:length(list))
      olist{end+1} = list{i};
   end
   return

%eof