function oo = mtimes(o1,o2)
%
% MTIMES   Overloaded operator * for TRF objects (transfer functions)
%
%             G1 = trf(1,[1 1]);
%             G2 = trf([1 1/T1],[1 1/T2]);
%
%             G = G1 * G2;     % multiply transfer functions
%
%          See also: TRF, PLUS, MINUS, MTIMES, MRDIVIDE
%
   if (~isa(o1,'trf'))
      o1 = trf(o1);
   end
   
   clas = class(o2);
   switch clas
      case 'cordoba'
         oo = Response(o1,o2);
      case 'double'
         oo = Response(o1,o2);
      otherwise                        % product of 2 transfer functions
         oo = Multiply(o1,o2);
   end   
end

%==========================================================================
% Work Horses
%==========================================================================

function oo = Multiply(o1,o2)
   if (~isa(o2,'trf'))
      o2 = trf(o2);
   end
   G1 = data(o1);
   G2 = data(o2);
   G = tffmul(G1,G2);
   oo = trf(G);
end

function oo = Response(o1,o2)
   G1 = data(o1);

   switch class(o2)
      case 'cordoba'
         dat = cordoba.either(data(o2),struct(''));
         tags = fields(dat);

         t = data(o2,tags{1});
         oo = o2;

         for (i=2:length(tags))
            sym = tags{i};
            u = data(o2,sym);
            [m,n] = size(u);
            y = tffrsp(G1,u,t);
            y = reshape(y,m,n);
            oo = data(oo,sym,y);
         end
      case 'double'
         error('*** implementation restriction!');
         u = o2;
         [m,n] = size(u);
         if (min(m,n) == 1)
            n = m*n;  m = 1;
            u = u(:)';
         end
         for (i=1:m)
            y(i,1:n) = tffrsp(G1,u(i,:));
         end
         oo = y;
      otherwise
         error('class not supported!');
   end
end
