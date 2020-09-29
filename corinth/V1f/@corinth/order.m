function n = order(o)                  % Order of CORINTH Object   
%
% ORDER   Get order of a corinthian object
%
%            o = corinth([1 5 6])      % polynomial
%            n = order(o);             % get polynomial order
%
%         See also: CORINTH, DIGITS, SIZE, TRIM, FORM
%
   switch o.type
      case 'trf'
         [num,den] = peek(o);
         n = max(length(num)-1,length(den)-1);
      case 'number'
         n = 0;
      case 'poly'
         n = length(o.data.expo)-1;
      case 'ratio'
         [ox,oy,~] = peek(o);
         ox = trim(ox);  oy = trim(oy);
         n = order(ox) - order(oy);
      otherwise
         error('implementation restriction!');
   end
end
