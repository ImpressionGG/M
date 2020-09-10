function o = base(o,number)            % Set Basis of Rational Object  
%
% BASIS   Set basis of a rational object
%
%            o = base(rat,10);         % set basis 10          
%            o = base(rat,1000);       % set basis 1000          
%            o = base(rat,1e6);        % set basis 1e6          
%
%         See also: RAT
%
   o.base = number;
end

%==========================================================================
% Add Two Mantissa
%==========================================================================

function z = Add(o,x,y)                % Mantissa Addition             
   if (all(y>=0) && any(x<0))
      z = Sub(o,y,x);
      return
   elseif (all(x>=0) && any(y<0))
      z = Sub(o,x,y);
      return
   elseif (any(x<0) && any(y<0))
      z = -Add(o,-x,-y);
      return
   end
   
   [x,y] = Match(o,x,y,1);

   base = o.base;
   z = x + y;
   for (i=length(x):-1:1)
      if (z(i) > base)
         z(i) = z(i) - base;
         z(i-1) = z(i-1) + 1;
      end
   end
   
   z = Trim(o,z);
end