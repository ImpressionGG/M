classdef corinth < corazon             % Corinth Class Definition
%
% CORINTH   Variable length integer based arithmetic
%
%           Construct a Number (rational number):
%
%              o = corinth             % zero number
%              o = corinth({n,d})      % from num/den digit arrays
%
%              oo = base(corinth,100)  % next construct all base 100
%
%              n = corinth(o,'number') % zero number
%              p = corinth(o,'poly')   % zero polynomial
%              r = corinth(o,'ratio')  % zero rational function
%              m = corinth(o,'matrix') % zero 1x1 matrix
%
%           Supported types:
%
%              'number'    rational number (integer ratio)
%              'poly'      polynomial (with rational coefficients)
%              'ratio'     rational function
%              'matrix'    matrix of rational functions
%
%           Remark: use methods NUMBER, POLY, RATIO and MATRIX to 
%                   construct corinthian objects
%
%           Examples:
%              o = base(corinth,100)   % define base (default: 1e6)
%
%              n = number(o,8.88)      % number 888/100
%              n = number(o,5,6)       % number 5/6
%
%              p = poly(o,[2 3 4])     % polynomial: 2s^2 + 3s + 4
%              p = poly(o,[2 3.2 4.17])% polynomial: 2s^2 +16/5s + 417/100
%
%              r = ratio(o,[1 2],[1 0] % rational function: (s+2)/s
%
%              m = matrix(o,magic(3))  % matrix of corinthian objects
%
%           Copyright(c): Bluenetics 2020
%
%           See also: CORINTH, NUMBER, POLY, RATIO
%            
%
   methods                             % public methods
      function o = corinth(arg1,arg2,arg3)  % corinth constructor
         casted = (nargin > 0 && isobject(arg1));
         if (casted)                   % in case of casted object
            arg = arg1;                % construct from object
            arg.data = [];             % otherwise crash downwards
            arg.data.base = get(arg,{'base',1e6});
         else
            arg = 'number';            % default type
         end
         
         o@corazon(arg);               % construct base object
         
            % initialize! make sure that the opt field is always available
            % which makes inheritance super fast
            
         if casted                     % default setup
            o.work.opt = opt(arg1);
         else
            o.tag = mfilename;         % tag must equal derived class name
            base = 1e6;              
            o.data.base = base;        % set representation base;
            o.work.opt = [];           % opt field is always available !!!
         end
         
            % provide defaults
            
         o.data.expo = 0;              % init necessary!
         o.data.num = 0;
         o.data.den = 1;
         
            % dispatch arg list
            
         switch nargin
            case 0                     % supported: o = corinth
               return                  % nothing left to do - bye!
            case 1
               if isa(arg1,'corinth')
                  o = can(o);
                  o = trim(o);
                  return;              % all done yet - bye!
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
                  o.work.opt = arg1.work.opt;
                  return
               else
                  error('bad arg list!');
               end
         end
         error('bad arg list!');
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
         o.data.num = poly(o,[0]);
         o.data.den = poly(o,[1]);
      case 'matrix'
         data.base = o.data.base;
         data.matrix = {};
         o.data = data;
      otherwise
         error('implementation restriction');
   end
   o.work.can = 1;                     % object is already canceled
   o.work.trim = 1;                    % object is already trimmed
end
function [num,den,xpo] = Number(o,arg) % Construct rational Number  
   assert(false);                      % use number(o,arg)
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
      
      % integers and floats are differently processed!
      
   if (floor(mantissa) == mantissa)    % integer processing ...
      [num,den] = Integer(mantissa,base,xpo);
   else                                % float processing ...
      [num,den] = Float(mantissa,base,xpo);
   end
   
      % work in sign

   num = num * sign;
   
   if (nargout == 1)
      oo = poke(corinth(o,'number'),xpo,num,den);
      num = oo;                        % return out arg
   end
   
   function [num,den] = Integer(mantissa,base,xpo)
   %
   % INTEGER  Calculate num/den for integer number
   %
      assert(xpo >= 0);                % for integers
      den = 1;
      num(1) = rem(mantissa,base);
      
      for (i=1:xpo)
         mantissa = round(mantissa/base);
         den(end+1) = 0;
         num = [rem(mantissa,base),num];
      end
   end
   function [num,den] = Float(mantissa,base,xpo)
   %
   % FLOAT  Calculate num/den for floating point numbers
   %
      x = mantissa / base^xpo;
      if (x >= 1)
         num = floor(x);
         x = x - num;
      elseif (x == 0)
         num = 0;
      end

      while (abs(x) > 10000*eps)       % calulate 'digits'  
         x = x * base;
         dig = floor(x);
         x = x - dig;

         num(1,end+1) = dig;
         den(1,end+1) = 0;
      end      
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
