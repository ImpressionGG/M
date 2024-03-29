classdef corinth < corazon             % Corinth Class Definition
%
% CORINTH   Variable length integer based arithmetic
%
%           Construct corinthian object with given base
%
%           Construct a Number (rational number):
%
%              o = corinth             % rational zero
%              o = corinth(0)          % same as above
%              o = corinth(pi)         % rational representation of pi
%              o = corinth({n,d})      % from num/den digit arrays
%
%              oo = base(corinth,100)  % next construct all base 100
%
%              o = corinth(oo,0)       % rational zero (@ base 100)
%              o = corinth(oo,pi)      % rational representation of pi 
%              o = corinth(oo,{n,d})   % from num/den digit arrays0   
%
%           Construct a polynomial (with rational coefficents)
%
%              o = corinth([a3 a2 a1 a0])
%              o = corinth(oo,[a3 a2 a1 a0])
%
%              o = corinth({{n2,d2}, {n1,d1}, {n0,d0}}
%
%           Supported types:
%
%              'number'    rational number (integer ratio)
%              'poly'      polynomial (with rational coefficients)
%              'matrix'    matrix of rational functions
%
%           See also: CORINTH, NUMBER, POLY, RATIO
%            
%
   methods                             % public methods
      function o = corinth(arg1,arg2,arg3)  % corinth constructor
         casted = (nargin > 0 && isobject(arg1));
         if (casted)                   % in case of casted object
            arg = arg1;                % construct from object
         else
            arg = 'number';            % default type
         end
         
         o@corazon(arg);               % construct base object
         
         if ~casted                    % default setup
            o.tag = mfilename;         % tag must equal derived class name
            base = 1e6;              
            o.data.base = base;        % set representation base;
         end
         
            % provide defaults
            
         o.data.expo = 0;              % init necessary!
         o.data.num = 0;
         o.data.den = 1;
         
            % dispatch arg list
            
         switch nargin
            case 0
               return                  % nothing left to do - bye!
            case 1
               if isa(arg1,'corinth')
                  o = can(o);
                  return;              % all done yet - bye!
               elseif (isa(arg1,'double'))
                  o = Poly(o,arg1,'numerator (arg1)!');
                  o = can(o);
                  return;
               elseif iscell(arg1)
                  o = Poly(o,arg1,'numerator (arg1)!');
                  o = can(o);
                  return;
               else
                  error('bad arg list!');
               end
               
            case 2              
               if isa(arg1,'double') && isa(arg2,'double')   % super fast!
                  assert(all(abs(arg1)<base) && all(abs(arg2)<base));
                  data = o.data;
                  data.num = arg1;
                  data.den = arg2;
                  o.data = data;
                  return
               elseif (isa(arg1,'corinth') && ischar(arg2))
                  o = Construct(arg1,arg2);
                  return
               elseif (isa(arg1,'corinth') && isa(arg2,'double'))
                  o = Poly(o,arg2,'numerator (arg1)!');
                  o = can(o);
                  return
               elseif (isa(arg1,'corinth') && iscell(arg2) && length(arg2) == 2)
                  o = Poly(o,arg2,'numerator (arg1)!');
                  o = can(o);
                  return
               elseif (isa(arg1,'double') && isa(arg2,'double'))
                  [num,den,expo] = Poly(o,arg1,'numerator (arg1)!');
                  assert(sum(den)==1);
                  o.data.num = num;
                  o.data.expo = o.data.expo + expo;
                  
                  [num,den,expo] = Poly(o,arg2,'denominator (arg2)!');
                  assert(sum(den)==1);
                  o.data.den = num;
                  o.data.expo = o.data.expo - expo;
           
                  o = can(o);
                  return
               else
                  error('bad arg list!');
               end
               
            case 3
               if (isa(arg2,'double') && isa(arg3,'double'))
                  [num,den,expo] = Poly(o,arg2,'numerator (arg2)!');
                  assert(sum(den)==1);
                  o.data.num = num;
                  o.data.expo = o.data.expo + expo;
                  
                  [num,den,expo] = Poly(o,arg3,'denominator (arg3)!');
                  assert(sum(den)==1);
                  o.data.den = num;
                  o.data.expo = o.data.expo - expo;
           
                  o = can(o);
                  return
               else
                  error('bad arg list!');
               end
         end
         assert(0);                    % do not run up to here!
      end
   end
end

%==========================================================================
% Helpers
%==========================================================================

function o = Construct(o,type)         % construct object
   o.type = type;
   o.par = [];
   o.work = [];

   switch type
      case {'number','poly'}
         o.data.expo = 0;
         o.data.num = 0;
         o.data.den = 1;
      case 'ratio'
         o.data.expo = NaN;
         o.data.num = [];
         o.data.den = [];
      case 'matrix'
         data.base = o.data.base;
         data.matrix = {};
         o.data = data;
      otherwise
         error('implementation restriction');
   end
end
function [num,den,xpo] = Poly(o,arg,msg)  % Form Rational Polynomial   
%
% POLY   Construct polynomial
%
%           oo = Poly(o,arg,msg)
%           [num,den,expo] = Poly(o,arg,msg)
%
   [m,n] = size(arg);
   if (m*n == 0)
      error(['nonempty data expected for ',msg]);
   end
   
   if (isa(arg,'double') && m*n == 1)    % simple ratio
      [num,den,xpo] = Number(o,arg);
   elseif iscell(arg) && ~isempty(arg)
      if (m*n == 2 && ~iscell(arg{1})) % simple ratio
         [num1,den1,xpo1] = Number(o,arg{1});
         [num2,den2,xpo2] = Number(o,arg{2});
         num = mul(o,num1,den2);
         den = mul(o,num2,den1);
         xpo = xpo1-xpo2;
         o.type = 'number';
      elseif iscell(arg{1})
         arg = arg(:);
         m = length(arg);
         o = corinth(o,'poly');
         for (i=1:m)
            argi = arg{i};
            oo = corinth(o,argi);
            j = m-i;                      % index of polynomial coefficient
            o = poke(o,oo,j);             % j: 0...m-1
         end
         [num,den,xpo] = peek(o); 
      else
         error('bad arglist!');
      end
   elseif (m*n > 1)            % polynomial
      arg = arg(:);
      m = length(arg);
      
      o = corinth(o,'poly');
      for (i=1:m)
         oo = Number(o,arg(i));
         j = m-i;                      % index of polynomial coefficient
         o = poke(o,oo,j);             % j: 0...m-1
      end
      [num,den,xpo] = peek(o); 
   else
      error('bad arglist!');
   end
   
   if (nargout == 1)
      num = poke(o,xpo,num,den);
   end
end
function [num,den,xpo] = Number(o,arg)    % Construct rational Number  
   base = o.data.base;
   den = 1;
   num = [];

      % for zero arg we have a special treatement
      
   if isequal(arg,0)
      num = 0;  xpo = 0;
      if (nargout <= 1)
         o.type = 'number';
         num = poke(o,xpo,num,den);
      end
      return;
   end
      % calculate expo

   sign = 2*(arg>=0) - 1;
   mantissa = arg*sign;
   logb = log10(mantissa) / log10(base);

   xpo = floor(logb);
   x = mantissa / base^xpo;

      % calculate mantissa

   if (x >= 1)
      num = floor(x);
      x = x - num;
   elseif (x == 0)
      num = 0;
   end

   while (abs(x) > 10000*eps)          % calulate 'digits'             
      x = x * base;
      dig = floor(x);
      x = x - dig;

      num(1,end+1) = dig;
      den(1,end+1) = 0;
   end

      % work in sign

   num = num * sign;
   
   if (nargout == 1)
      num = poke(corinth(o,'number'),xpo,num,den);
   end
end
function o = Form(o)                   % Form to Get Zero Exponent     
   expo = o.data.expo;
   if (expo > 0)
      o.data.num = [o.data.num,zeros(1,expo)];
   elseif (expo < 0)
      o.data.den = [o.data.den,zeros(1,expo)];
   end
   o.data.expo = 0;
end
