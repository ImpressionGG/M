function txt = display(o)              % Display Corinthian Object     
%
% DISPLAY   Display a CORINTH object (rational object)
%
%             o = corinth(5,6);        % rational number 5/6
%             display(o);              % display CORINTH object
%
%          Options:
%
%             detail:    display coefficients in detail (default: 0)
%
%          Copyright(c): Bluenetics 2020
%
%          See also: CORINTH
%
   if container(o)
      fprintf('CORINTH object\n');
      fprintf(' MASTER Properties:\n');
      fprintf('  tag: %s\n',o.tag);
      fprintf('  type: %s\n',o.type);

      if isa(o.par,'double') && isempty(o.par)
         fprintf('   par: []\n');
      else
         fprintf('   par:\n');
         disp(o.par);
      end

      if iscell(o.data) && isempty(o.data)
         fprintf('   data: {}\n');
      elseif isa(o.data,'double') && isempty(o.data)
         fprintf('   data: []\n');
      else
         fprintf('   data:\n');
         disp(o.data);
      end
      fprintf(' WORK Property:\n');
         disp(o.work);
      return
   end
   
   switch o.type
      case 'number'
         if (nargout == 0)
            fprintf('   rational number:\n');
            Number(o);
         else
            txt = Number(o);
         end

      case 'poly'      
         if (nargout == 0)
            Poly(o);
         else
            coeffs = real(o);
            txt = PolyString(o,coeffs,'s');
            txt = ['(',txt,')'];
         end

      case 'ratio'      
         if (nargout == 0)
            Ratio(o);
         else
            txt = Ratio(o);
         end

      case 'matrix'  
         if (nargout == 0)
            [m,n] = size(o.data.matrix);
            fprintf('   rational matrix %gx%g:\n',m,n);
            Matrix(o);
         else
            [m,n] = size(o);
            txt = sprintf('%g x %g rational matrix',m,n);
         end
      otherwise
         disp(o)                       % display in corazon style
   end
end

%==========================================================================
% Display Number
%==========================================================================

function txt = Number(o,name)          % Display Number                
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

   if (nargout == 0)
      fprintf('%s%s\n',tab1,num);
      fprintf('%s%s\n',prefix,bar);
      fprintf('%s%s\n',tab2,den);
   else
      upper = [tab1,num];
      middle = [prefix,bar];
      lower = [tab2,den];

      txt = setstr(' '+zeros(3,length(middle)));
      txt(1,1:length(upper)) = upper;
      txt(2,:) = middle;
      txt(3,1:length(lower)) = lower;
   end
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
   
   coeff = [];
   objects = {};
   for (i=1:m)
      k = i-1;
      name = sprintf('%s(%g)',get(o,{'name','poly'}),k);

      oo = poke(oo,xpo(i),num(i,:),den(i,:));      
      oo = trim(oo);
      
      objects{i} = var(oo,'name',name);
      %Number(oo,name);                 % display i-th number
      
      coeff(m+1-i) = real(oo);
      poly(1,m-k) = coeff(end);   
   end
   
      % print as a fraction of two polynomials

   str = PolyString(o,coeff,'s');
   if (size(str,1) == 1)
      fprintf('\n   polynomial(%g):  %s\n\n',order(o),str);
   else
      fprintf('\n   polynomial (order %g)\n\n',order(o));
      for (i=1:size(str,1))
         fprintf('      %s\n',str(i,:));
      end
      fprintf('\n');
   end
      
      % in case of detail option set print coefficient details
      
   if opt(o,{'detail',0})
      for (i=1:length(objects))
         oo = objects{i};
         Number(oo,var(oo,'name'));       % display i-th number
      end
   end
end

%==========================================================================
% Display Rational Function
%==========================================================================

function txt = Ratio(o)                % Display Rational Function                
   assert(isequal(o.type,'ratio'));
   [on,od,~] = peek(o);
   
      % fetch numerator ans denominator objects
      
   num = real(on);
   den = real(od);
   
      % compile readable text string; distinguish if denominator equals
      % one or else      
         
   if iseye(od)
      txt = PolyString(o,num,'s');
      txt = ['((',txt,'))'];
   else
      txt = RatioString(o,num,den,'s');
      txt = Trim(o,txt);
   end
   
      % depending on calling syntax return readable text string or
      % print to console
      
   if (nargout > 0)
      return
   elseif ~opt(o,{'detail',0})
      fprintf('rational function (%g/%g)\n\n   ',order(on),order(od));
      disp(txt);
      fprintf('\n');
   else
      Display(o,num,den);
   end
end

%==========================================================================
% Display Matrix
%==========================================================================

function OldMatrix(o)                  % Display Matrix                
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
function Matrix(o)                     % Display Matrix                
   assert(isequal(o.type,'matrix'));
   
   M = o.data.matrix;
   [m,n] = size(M);

   fprintf('\n');
   for (i=1:m)
      paragraph = [];
      txt = {};  rows = 0;
      for (j=1:n)        
         txt{j} = display(M{i,j});     % display rational function
         rows = max(rows,size(txt{j},1));      % estimate max rows
      end

         % add n (horizontal) blocks to paragraph      

      for (j=1:n)
         [mj,nj] = size(txt{j});

         index = sprintf('[%g,%g]:  ',i,j);
         index = '';
         spacer = setstr(' '+zeros(mj,3));

         txtj = [spacer,index,txt{j}];
         [mj,nj] = size(txtj);

         block = setstr(' '+zeros(rows,nj));
         idx = ceil((rows-mj)/2);
         block(idx+1:idx+mj,:) = txtj;
        
         paragraph = [paragraph, block(1:rows,:)];
      end

         % print paragraph

      for (i=1:size(paragraph,1))
         fprintf('   %s\n',paragraph(i,:));
      end
      fprintf('\n');
   end
end

%==========================================================================
% Display Rational Function
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
      Trf(o,G,name);
   else
      Trf(o,G);
   end
end
function out = Trf(o,G,name)           % Display Transfer Funcion      
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
   spc = setstr(' '+zeros(1,2*maxlen));   % big enough
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
      if ( nargin >= 3)
         fprintf(['\n   rational function ',name,': (%g/%g), type ',s,strgain],deg_num,deg_den);
      else
         fprintf(['\n   rational function (%g/%g), type ',s,strgain],deg_num,deg_den);
      end
      if ( kind == 2 | kind == 3 )
         fprintf(', sampling period = %g',G(2));
      end
      fprintf('\n\n');
   else
      if ( nargin >= 3)
         %list{end+1} = sprintf(['   Transfer function ',name,': %g/%g, type ',s,strgain],deg_num,deg_den);
         header = sprintf(['   rational function ',name,': (%g/%g), type ',s,strgain],deg_num,deg_den);
      else
         %list{end+1} = sprintf(['   Transfer function %g/%g, type ',s,strgain],deg_num,deg_den);
         header = sprintf(['   rational function (%g/%g), type ',s,strgain],deg_num,deg_den);
      end
      if ( kind == 2 | kind == 3 )
         %list{end} = [list{end},sprintf(', sampling period = %g',G(2))];
         header = [header,sprintf(', sampling period = %g',G(2))];
      end
      %list{end+1} = '';
      %list{end+1} = '';
   end
%
% construct numerator & denominator string
%
   str = RatioString(o,G(1,2:end),G(2,2:end),s);  
%
% display transfer function in coefficient form
%

   if (nargout == 0)
      disp(str);
   else
      list{end+1} = str;
      % list{end+1} = '';
      % list{end+1} = '                                                   Omegas     Zetas';
      list{end+1} = '';
      list{end+1} = header;
   end
   
   if ~opt(o,{'detail',false})
      return
   end
   
   if (nargout == 0)
      fprintf(['\n                                                   ',...
               'Omegas     Zetas\n']);
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
	         fprintf(['      %s #%g: ',re_str,im_str],kind,i);
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
function txt = Trim(o,txt)             % Trim Text                     
   while (size(txt,1) > 0 && all(txt(:,1)==' '))
      txt(:,1) = [];
   end
   while (size(txt,1) > 0 && all(txt(:,end)==' '))
      txt(:,end) = [];
   end
end

%==========================================================================
% Construct Polynomial String and Rational String
%==========================================================================

function str = PolyString(o,poly,sym)       % Readable String for Poly 
%
% POLYSTRING  Construct readable string for polynomial
%
%                stxt = PolyString(o,[1 2 3],'s')
%                ztxt = PolyString(o,[2 3 4],'z')
%                qtxt = PolyString(o,[2 0 5]poly,'q')
%
%             Results:
%
%                stxt = 's^2 + 2s +3'
%                ztxt = '2z^2 + 3z +4'
%                qtxt = '2q^2 + 5'
%
%             Options:
%
%                minlen:      minimum length of string (default 10)
%                maxlen:      maximum length of string (default 70)
%
   trim = @corazito.trim;              % short hand
   
      % if polynomial is 0 or 1 we have already a quick answer
      % since 0 and 1 as the highest order coefficient is treated 
      % as a special we cannot run through the general procedure
      
   while (length(poly) > 1 && poly(1) == 0)
      poly(1) = [];                    % delete trailing zeros
   end
   
   if isequal(poly,0)                  % special: 0
      str = '0';
      return                           % we can handle quickly: bye!
   elseif isequal(poly,1)              % special: 1
      str = '1';
      return                           % we can handle quickly: bye!
   elseif isequal(poly,-1)             % special: -1
      str = '-1';
      return                           % we can handle quickly: bye!
   end
   
      % since it was neither 0 nor 1 we have to work over the general case
   
   maxlen = opt(o,{'maxlen',70});
   curlen = opt(o,{'minlen',10});

   degree = length(poly) - 1;
   m = degree+1;                       % auxillary quantity

      % need some working stuff (like spaces)
      
   spc = setstr(' '+zeros(1,2*maxlen));  % long enough
   
      % in the following loop through all coefficients we will build up two
      % variables: str is a matrix of lines which will hold the resulting
      % (eventually multi line string), and 'line' which will be the actual
      % line as part of 'str'
      
   str = '';  line = '';  begin = true;
   for (i = degree:-1:0 )

         % compose power of s: ... ' s^3', ' s^2', ' s', ''  
         
      if ( i == 0 )
         pow = '';
      elseif (i == 1)
         pow = [' ',sym];
      else
         pow = [' ',sym,'^',sprintf('%g',i)];
      end

         % fetch i-th polynomial coefficient (c); if zero then skip
         % to next coefficient with index i-1
         
      c = poly(m-i);
      if (begin && c == 0)
         continue
      end
      
         % next we compose string for sign; note that in the very beginning
         % (empty str)
         
      if ( c >= 0 )
         op = o.iif(begin,'',' + ');
      else
         op = o.iif(begin,'-',' - ');
      end

         % compose string for polynomial term consisting of coefficient
         % plus power string
         
      term = [sprintf('%1g',abs(c)), pow];
      if (begin && c == 1)
         term = pow;                         % drop coefficient if = 1
      elseif (begin && c == -1)
         term = pow(2:end);                  % drop coefficient if = 1
      end
      begin = false;                         % begin is over!

         % handle line overflow: if new line length exceeds maximum length
         % plus some margin then we store line in str and start a new line
         
      if ( length(line) + length(term) > maxlen - 3 )
         line = trim([line, op]);
         l = length(line);
         curlen = max(l,curlen);  
         l = floor((maxlen - l)/2);
         
            % add leading and trailing spaces to line, then add
            % line to str as a new row
            
         line = [spc(1:l), line, spc];
         str =  [str; line(1:maxlen)];
         
            % now we can start a new line
            
         line = '';
      end;

         % finally add term to line
         
      line = [line,op,term];
   end

      % the last line is not added to str what needs to be done now

   line = trim(line);
   l = length(line);
   curlen = max(l,curlen);  
   l = floor((maxlen - l)/2);

      % add leading and trailing spaces to line, then add
      % line to str as a new row

   line = [spc(1:l), line, spc];
   str =  [str; line(1:maxlen)];

      % finally trim str (note that str might be an mxn matrix of chars)
      
   while (1)
      if ~isempty(str) && all(str(:,1)==' ')
         str(:,1) = [];
      elseif ~isempty(str) && all(str(:,end)==' ')
         str(:,end) = [];
      else
         break                         % str is trimmed - break loop
      end
   end
end
function str = RatioString(o,num,den,sym)   % Readable String for Poly 
%
% RATIOSTRING Construct readable string for rational functions
%
%                stxt = RatioString(o,[1 2 3],[4 5 6],'s')
%                ztxt = PolyString(o,[2 3 4],[4 5 6],'z')
%                qtxt = PolyString(o,[2 0 5],[4 5 6],'q')
%
%             Options:
%
%                minlen:      minimum length of string (default 10)
%                maxlen:      maximum length of string (default 70)
%
   maxlen = opt(o,{'maxlen',70});
   curlen = opt(o,{'minlen',10});

   numstr = PolyString(o,num,sym);
   denstr = PolyString(o,den,sym);
   
      % calculate total width
      
   [m1,n1] = size(numstr);
   [m2,n2] = size(denstr);
   n0 = max(n1,n2) + 4;                % plus 4 is for fraction bar
   
      % compose resulting string
      
   n = max(maxlen,n0);
   spc = setstr(' '+zeros(n1+n2+1,2*n));     % big enough
   
   l1 = floor((n-n1)/2);               % length of leading space num
   l2 = floor((n-n2)/2);               % length of leading space den
   l0 = floor((n-n0)/2);               % length of leading space bar
   
   numstr = [spc(1:m1,1:l1),numstr,spc(1:m1,:)];
   bar = [spc(1,1:l0),setstr('-'+zeros(1,n0)),spc(1,:)];
   denstr = [spc(1:m2,1:l2),denstr,spc(1:m2,:)];

      % assemble the multi line string for the rational function
      
   str = [numstr(:,1:n); bar(1:n); denstr(:,1:n)];
end
