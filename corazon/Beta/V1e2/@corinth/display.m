function display(o)
%
% DISPLAY   Display a CORINTH object (rational object)
%
%             o = corinth(5,6);        % rational number 5/6
%             display(o);              % display CORINTH object
%
%          See also: CORINTH
%
   switch o.type
      case 'number'
         fprintf('rational number:\n');
         Number(o);
      case 'poly'      
         fprintf('polynomial:\n');
         Poly(o);
      case 'ratio'      
         fprintf('rational function:\n');
         Ratio(o);
      case 'matrix'      
         fprintf('rational matrix:\n');
         Matrix(o);
      otherwise
         disp(o)                       % display in corazon style
   end
end

%==========================================================================
% Display Number
%==========================================================================

function Number(o,name)                 % Display Number               
   if (nargin == 1)
      name = get(o,{'name',''});
   end
   prefix = o.iif(isempty(name),'',['   ',name,': ']);
   
   blue = real(o);
   
   base = o.data.base;
   expo = o.data.expo;

   n = log10(base);
   format = sprintf('%%0%gg',n);

   sgn = +1;
   num = sprintf(format,o.data.num(end));
   if (any(o.data.num<0))
      num(1) = [];  o.data.num = -o.data.num;  sgn = -sgn;
   end
   if (length(o.data.num) == 1)
      %num = ['_',num];
   else
      for (i=length(o.data.num)-1:-1:1)
         num = [sprintf(format,o.data.num(i)),'_',num];
      end
   end

   den = sprintf(format,o.data.den(end));
   if (any(o.data.den<0))
      den(1) = [];  o.data.den = -o.data.den;  sgn = -sgn;
   end
   if (length(o.data.den) == 1)
      %den = ['_',den];
   else
      for (i=length(o.data.den)-1:-1:1)
         den = [sprintf(format,o.data.den(i)),'_',den];
      end
   end

   blue = sprintf('   %g = ',blue);
   tab = setstr(0*blue+' ');

   m = max(length(num),length(den));
   tab1 = [tab,'   ',setstr(0*prefix)+' '];
   tab2 = [tab,'   ',setstr(0*prefix)+' '];

   switch base
      case 1e6
         btxt = '1_000_000';
      case 1e5
         btxt = '100_000';
      case 1e4
         btxt = '10_000';
      otherwise
         btxt = sprintf('%g',base);
   end

   bar = sprintf([setstr(zeros(1,m+6)+'-'),' * %s^%g'],btxt,expo);
   if (sgn < 0)
      bar = ['- ',bar];  tab1 = ['  ',tab1];  tab2 = ['  ',tab2];
   end
   bar = [blue,bar];

   fprintf('%s%s\n',tab1,num);
   fprintf('%s%s\n',prefix,bar);
   fprintf('%s%s\n',tab2,den);
end

%==========================================================================
% Display Polynomial
%==========================================================================

function Poly(o)                       % Display Polynomial            
   [num,den,xpo] = peek(o);
   
   m = length(xpo);
   if (m ~= size(num,1) || m ~= size(den,1))
      error('internal mismatch!');
   end
   
   oo = o;
   oo.type = 'number';
   
   for (i=1:m)
      k = i-1;
      name = sprintf('%s(%g)',get(o,{'name','poly'}),k);

      oo = poke(oo,xpo(i),num(i,:),den(i,:));      
      oo = trim(oo);
      Number(oo,name);                 % display i-th number
      
      poly(1,m-k) = real(oo);
   end
   
      % print as a fraction of two polynomials
      
   Display(o,poly,1);
end

%==========================================================================
% Display Rational Function
%==========================================================================

function Ratio(o)                      % Display Rational Function                
   assert(isequal(o.type,'ratio'));
   [ox,oy,~] = peek(o);
   
   num = real(ox);
   den = real(oy);
         
   Display(o,num,den);
end

%==========================================================================
% Display Matrix
%==========================================================================

function Matrix(o)                     % Display Matrix                
   assert(isequal(o.type,'matrix'));
   
   M = o.data.matrix;
   [m,n] = size(M);
   for (i=1:m)
      for (j=1:n)         
         if (m*n > 1)
            fprintf('rational function (%g,%g):\n',i,j);
         end
         
         Ratio(M{i,j});                % display rational function
      end
   end
end

%==========================================================================
% Display Polynomial
%==========================================================================

function Display(o,num,den)            % Display Rational Function     
   nn = length(num);
   nd = length(den);
   n = max(nn,nd);
   
   kind = 1;                           % s-transfer function kind
   Ts = 0;                             % samplig time
   
      % find denominator coefficient of highest potenz
      
   idx = find(den~=0);
   if ~isempty(den)
      fac = den(idx(1));
      den = den/fac;  num = num/fac;
   end
   
   G = [kind,[zeros(1,n-nn),num];
        Ts,  [zeros(1,n-nd),den]];
     
   name = get(o,'name');
   if ~isempty(name)                   % name provided
      Trf(G,name);
   else
      Trf(G);
   end
end
function out = Trf(G,name)             % Display Transfer Funcion      
%
% TRFDISP Display transfer function. 
%
%            tffdisp(G)           % print on console
%            list = tffdisp(G)    % return list, no print!
%
%         displays the type of transfer function G, coefficients, roots
%	  omegas and zetas. tffdisp(G,'G(s)') displays string 'G(s)'
%         in the head line. See tffnew, tffcmp.
%
%
   list = {};
   maxlen = 70; %maxlen = 60; 
   cur_len = 10;	off = 4;
   spc = '                               ';  spc = [spc, spc, spc];
   bar = '-------------------------------';  bar = [bar, bar, bar];

%
% roots, degrees
%
   %[class,kind,sign] = ddmagic(G);
  
   %if ( class ~= tffclass )
   %   error('No tffclass object');
   %end
   kind = G(1);  sign = 1;

   m = length(G);

   if (m > 1  &  sign < 0) G(1) = -G(1);  G(2,:) = -G(2,:); end
   num = G(1,2:m);  den = G(2,2:m);

   if (all(num == 0)) r_num = []; else r_num = roots(num); end
   if ( kind == 2 ) [ans,idx] = sort(abs(r_num));
      else [ans,idx] = sort(real(r_num));  end
   r_num = r_num(idx);	deg_num = length(r_num);
   num = num(m-deg_num-1:m-1);

   if (all(den == 0)) r_den = []; else r_den = roots(den); end
   if ( kind == 2 ) [ans,idx] = sort(abs(r_den));
      else  [ans,idx] = sort(real(r_den));  end
   r_den = r_den(idx);	deg_den = length(r_den);
   den = den(m-deg_den-1:m-1);
%
% type of rational function (s,z,q)
%

%    if (nargout == 0)
%       fprintf([spc(1:51),'V = %g\n'],V);
%    else
%       list{end+1} = sprintf([spc(1:51),'V = %g\n'],V);
%       out = list;
%    end

   V = Gain(num,den,deg_num,deg_den);
   strgain = sprintf(',  gain = %g',V);
   
   s = 'szq';  s = s(kind);
   if (nargout == 0)
      if ( nargin >= 2)
         fprintf(['\n   Transfer function ',name,': %g/%g, type ',s,strgain],deg_num,deg_den);
      else
         fprintf(['\n   Transfer function %g/%g, type ',s,strgain],deg_num,deg_den);
      end
      if ( kind == 2 | kind == 3 )
         fprintf(', sampling period = %g',G(2));
      end
      fprintf('\n\n');
   else
      if ( nargin >= 2)
         %list{end+1} = sprintf(['   Transfer function ',name,': %g/%g, type ',s,strgain],deg_num,deg_den);
         header = sprintf(['   Transfer function ',name,': %g/%g, type ',s,strgain],deg_num,deg_den);
      else
         %list{end+1} = sprintf(['   Transfer function %g/%g, type ',s,strgain],deg_num,deg_den);
         header = sprintf(['   Transfer function %g/%g, type ',s,strgain],deg_num,deg_den);
      end
      if ( kind == 2 | kind == 3 )
         %list{end} = [list{end},sprintf(', sampling period = %g',G(2))];
         header = [header,sprintf(', sampling period = %g',G(2))];
      end
      %list{end+1} = '';
      %list{end+1} = '';
   end
%
% construct numerator string
%
   n_str = '';  str = '';
   for (i = deg_num:-1:0 )

      if ( i == 0 )
         pot = '';
      elseif (i == 1)
         pot = [' ',s];
      else
         pot = [' ',s,'^',sprintf('%g',i)];
      end

      c = G(1,m-i);
      if ( c >= 0 )
         op = ' + ';  first_op = '';
      else
         op = ' - ';  first_op = '-';
      end

      coeff = [ sprintf('%1g',abs(c)), pot];

      if ( length(str) + length(coeff) > maxlen - 3 )
         str = [str, op];  l = length(str);
         cur_len = max(l,cur_len);  l = round((maxlen - l)/2);
         str = [spc(1:l+off), str, spc];
         n_str =  [n_str; str(1:maxlen)];
         str = '';
      end;

      if (i == deg_num)
         str = [first_op, coeff];
      else
         str = [str,op,coeff];
      end
   end

   l = length(str);	cur_len = max(l,cur_len);
   l = round((maxlen - l)/2);
   if (nargout == 0)
      str = [spc(1:l+off), str, spc];
      n_str =  [n_str; str(1:maxlen)];
   elseif (size(n_str,1) == 1)
      n_str = [n_str,trf.trim(str)];
   else
      space = '                                              ';
      space = [space,space,space];
      str = trf.trim(str);
      str = [space(1:floor((maxlen-length(str))/2)),str,space];
      n_str = [n_str;str(1:maxlen)];
   end
%
% construct denominator string
%
   d_str = '';  str = '';
   for (i = deg_den:-1:0 )

      if ( i == 0 )
         pot = '';
      elseif (i == 1)
         pot = [' ',s];
      else
         pot = [' ',s,'^',sprintf('%g',i)];
      end

      c = G(2,m-i);
      if ( c >= 0 )
         op = ' + ';  first_op = '';
      else
         op = ' - ';  first_op = '-';
      end

      coeff = [ sprintf('%1g',abs(c)), pot];

      if ( length(str) + length(coeff) > maxlen - 3 )
         str = [str, op];  l = length(str);
         cur_len = max(l,cur_len);  l = round((maxlen - l)/2);
         str = [spc(1:l+off), str, spc];
         d_str =  [d_str; str(1:maxlen)];
         str = '';
      end;

      if (i == deg_den)
         str = [first_op, coeff];
      else
         str = [str,op,coeff]; 
      end
   end

   l = length(str);	cur_len = max(l,cur_len);
   l = round((maxlen - l)/2);  str = [spc(1:l+off), str, spc];
   if (nargout == 0)
      d_str =  [d_str; str(1:maxlen)];
   elseif (size(n_str,1) == 1)
      d_str = [d_str,trf.trim(str)];
   else
      space = '                                              ';
      space = [space,space,space];
      str = trf.trim(str);
      str = [space(1:floor((maxlen-length(str))/2)),str,space];
      d_str = [d_str;str(1:maxlen)];
   end

%
% display transfer function in coefficient form
%

   if (nargout == 0)
      bar = bar(1:cur_len+2*off);	l = round((maxlen - length(bar))/2);
      bar = [spc(1:l+off),bar];
      disp(n_str);  disp(bar);  disp(d_str);
      fprintf('\n                                                   Omegas     Zetas\n');
   else
      bar = [bar;bar];
      bar = bar(1:cur_len+6*off);	l = round((maxlen - length(bar))/2);
      list{end+1} = n_str;
      list{end+1} = bar;
      list{end+1} = d_str;
      % list{end+1} = '';
      % list{end+1} = '                                                   Omegas     Zetas';
      list{end+1} = '';
      list{end+1} = header;
   end
%
% calculate the field size
%
   re_field = 10;  im_field = 15;
   for (j = 1:2)
      if (j == 1)
         r = r_num;  deg = deg_num;
      else
         r = r_den;  deg = deg_den; 
      end

      for (i = 1:deg)
         str = sprintf('%g',real(r(i)));
         re_field = max(re_field,length(str));
         str = sprintf('%g',abs(imag(r(i))));
         im_field = max(im_field,length(str));
      end
   end

   re_field = re_field + 3;  im_field = im_field + 3;
%
% roots, omegas, zetas
%
   for (j = 1:2)
      if (j == 1)
         kind = 'Zero';
	      r = r_num;  deg = deg_num;
         if (deg > 0)
            if (nargout == 0)
               fprintf('   Zeros:\n');
            else
               %list{end+1} = sprintf('   Zeros:');
            end
         end
      else
         kind = 'Pole';
   	   r = r_den;  deg = deg_den;
	      if (deg > 0)
            if (nargout == 0)
               fprintf('   Poles:\n');
            else
               list{end+1} = '';     % sprintf('   Poles:');
            end
         end
      end

      pair = 0;
      for (i = 1:deg)
	      ri = r(i);
	      str = sprintf('%g',real(ri));
	      re_str = [spc(1:re_field-length(str)), str];

	      if ( abs(imag(ri)) <= 100*eps )
	         im_str = spc(1:im_field+2);
         else
	         str = sprintf('%g',abs(imag(ri)));
	         if ( imag(ri) >= 0 ) op = ' + i '; else op = ' - i '; end
	         im_str = [op,str,spc(1:im_field-length(str)-3)];
         end

         if (nargout == 0)
	         fprintf(['  %s #%g: ',re_str,im_str],kind,i);
         else
	         list{end+1} = sprintf(['%s #%g: ',re_str,im_str],kind,i);
         end
         
	         % display omegas zetas

	      if ( pair ~= 0)
            if (nargout > 0)
               list{end} = [list{end},'                  '];
            end
         else
	         if ( abs(imag(ri)) > 100*eps )
	            q = abs(real(ri) / imag(ri));
	            zeta = q / sqrt(1 + q*q);
               if (zeta == 0)
                  omega = abs(imag(ri));
               else
	               %omega = -real(ri) / zeta;
	               omega = abs(real(ri) / zeta);
               end
	            %str = sprintf('(%g)',omega);
	            %str = [spc(1:20-length(str)), str];
               if (zeta < 100*eps)
                  zeta = 0;
               end
               
               if (nargout == 0)
   	            str = sprintf('%g',omega);
                  str = [spc(1:20-length(str)), str];
   	            fprintf([str,'   %g'],zeta);
               else
   	            str = sprintf('%g',omega);
                  list{end} = sprintf(['%s @  [',str,';%g]'],list{end},zeta);
               end
            else
	            omega = -real(ri);

	            str = sprintf('@  (%g)',omega);
	            str = [spc(1:20-length(str)), str];
               
               if (nargout == 0)
   	            fprintf(str);
               else
                  list{end} = [list{end},str];
               end
            end
         end
         
         if (nargout == 0)
            fprintf('\n');
         else
            %list{end+1} = '';
         end

	         % check if conjugate complex pair of roots

	      pair = 0;
	      if ( i < deg  &  abs(imag(ri)) > eps )
	         diff_re = abs(real(ri) - real(r(i+1)));
	         diff_im = abs(imag(ri) + imag(r(i+1)));
	         pair = ( diff_re < eps  &  diff_im < eps );
	      end
      end
   end

   if (nargout > 0)
      out = list;
   end
end

%==========================================================================
% Helper
%==========================================================================
   
function V = Gain(num,den,deg_num,deg_den)                             
%
% GAIN   Extract gain factor
%
   if ( all(num == 0)  &  all( den == 0 ) )
      V = NaN;
   elseif ( all(num == 0) )
      V = 0;
   elseif ( all(den == 0) )
      V = inf;
   else
      V = 0;
      for (i=deg_num+1:-1:1)
         if ( abs(num(i)) > 1e8*eps )
            V = num(i);
            break;
         end
      end
      for (i=deg_den+1:-1:1)
         if ( abs(den(i)) > 1e8*eps )
            V = V/den(i);
            break;
         end
      end
   end
end
function list = Header(list,G,name,deg_num,deg_den,gain)               
   if ( nargin >= 2)
      list{end+1} = sprintf(['   Transfer function ',name,': %g/%g, type ',s,strgain],deg_num,deg_den);
   else
      list{end+1} = sprintf(['   Transfer function %g/%g, type ',s,strgain],deg_num,deg_den);
   end
   if ( kind == 2 | kind == 3 )
      list{end} = [list{end},sprintf(', sampling period = %g',G(2))];
   end
end
