function n = order(o)                  % Order of CORINTH Object   
%
% ORDER   Get order of a corinthian object
%
%            o = corinth([1 5 6])      % polynomial
%            n = order(o);             % get polynomial order
%
%         See also: CORINTH, TRIM, FORM
%
   switch o.type
      case 'number'
         n = 0;
      case 'poly'
         n = length(o.data.expo)-1;
      case 'ratio'
         [ox,oy,~] = peek(o);
         n = order(ox) - order(oy);
      otherwise
         error('implementation restriction!');
   end
end
