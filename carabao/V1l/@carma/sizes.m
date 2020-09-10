function [out1,out2,out3] = sizes(o)
%
% SIZES   Get sizes of a TRACE object (using property(o,'sizes'))
%
%    1) Get sizes if everything is well defined
%
%       [m,n,r] = sizes(o)             % rows (m), cols (n), repeats (r)
%       [m,n] = sizes(o)
%        mnr = sizes(o)                % return 1x3 vector [m,n,r]
%
%    2) Print sizes in readanle form
%
%       sizes(o)                       % print sizes in readable form
%
%    See also: CARALOG, TRACE
%
   sz = Sizes(o);

   if (nargout == 1)
      out1 = sz;
      return
   else
      m = sz(1);  n = sz(2);  r = sz(3);
   end
   
   if (nargout==0)
      fprintf('   %g x %g matrix, %g repeats\n',m,n,r);
   else
      out1 = m;  out2 = n;  out3 = r;
   end
   
   return
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function sz = Sizes(o)
   n = prod(size(data(o,'time')));
   if (n == 0)
      n = prod(size(data(o,'t')));
   end
   sz = get(o,'sizes');
   if (length(sz) < 2)
      sz = [1,1];
   end
   if (length(sz) < 3)
      sz(3) = n / [sz(1)*sz(2)];
   end
end
