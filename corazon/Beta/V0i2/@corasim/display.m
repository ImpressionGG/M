function txt = display(o)              % Display Corasim Object        
%
% DISPLAY   Display a CORINTH object (rational object)
%
%             o = corinth(5,6);        % rational number 5/6
%             display(o);              % display CORINTH object
%
%             Options:
%
%                minlen:      minimum length of string (default 10)
%                maxlen:      maximum length of string (default 70)
%                detail:      display details (default: true)
%                braces:      add braces to exponents (default: false)
%
%          Copyright(c): Bluenetics 2020
%
%          See also: CORASIM
%
   switch o.type
      case 'css'
         fprintf('continuous state space system:\n');
         System(o);
      
      case 'dss'
         [~,~,~,~,T] = system(o);
         fprintf('discrete state space system (T = %g):\n',T);
         System(o);
      
      case 'modal'
         if (nargout > 0)
            oo = trf(o);
            txt = Ratio(oo);
            return
         end
         
         [a0,a1,w] = data(o,'a0,a1,w');
         name = get(o,'name');
         if isempty(name)
            fprintf('Modal system (%g modes)\n',length(a0));
         else
            fprintf('%s: Modal system (%g modes)\n',name,length(a0));
         end

         System(o);
                  
         sep = '';
         fprintf('   a0: [');
         for (i=1:length(a0))
            fprintf('%s%g',sep,a0(i));  sep = ', ';
         end
         fprintf(']\n');
         
         sep = '';
         fprintf('   a1: [');
         for (i=1:length(a1))
            fprintf('%s%g',sep,a1(i));  sep = ', ';
         end
         fprintf(']\n');
         
         if ~isempty(w)
            sep = '';
            fprintf('   w:  [');
            for (i=1:length(w))
               fprintf('%s%g',sep,w(i));  sep = ', ';
            end
            fprintf(']\n');
         end

                  
      case {'strf','ztrf','qtrf'}
         [num,den] = peek(o);
         if (nargout > 0)
            try
               txt = Ratio(o);
            catch
               fprintf('*** exception catched\n');
               txt = '';
            end
         else
            o = opt(o,{'detail'},true);
            try
               Ratio(o);
            catch
               fprintf('*** exception catched\n');
            end
         end
            
      case {'szpk','zzpk','qzpk','psiw'}
         oo = vpa(o,0);
         oo = trf(oo);                  % cast to trf type
         [num,den] = peek(oo);
         if (nargout > 0)
            try
               txt = Ratio(o);
            catch
               fprintf('*** exception catched\n');
               txt = '';
            end
         else
            o = opt(o,{'detail'},true);
            try
               Ratio(o);
            catch
               fprintf('*** exception catched\n');
            end
         end
            
      case 'matrix'  
         if (nargout == 0)
            [m,n] = size(o.data.matrix);
            fprintf('   rational matrix %gx%g:\n',m,n);
            Matrix(o);
         else
            [m,n] = size(o);
            txt = Matrix(o);
         end
      otherwise
         display(corazon,o);           % display in corazon style
   end
end

%==========================================================================
% Display System
%==========================================================================

function oo = System(o)                % Display System
   display(corazon,o);
   return
   
   [A,B,C,D,T] = system(o,'A,B,C,D,T');
   fprintf('   [ A | B ]\n');
   fprintf('   [---+---] =\n');
   fprintf('   [ C | D ]\n\n');
   
   ABCD =  [ A NaN*A(:,1) B
             NaN*A(1,:) NaN NaN*B(1,:)
             C NaN*C(:,1) D];
   disp(ABCD);
end

%==========================================================================
% Display Rational Function
%==========================================================================

function txt = Ratio(o)                % Display Rational Function     
   switch o.type
      case {'strf','szpk'}
         sym = 's';
      case {'ztrf','zzpk'}
         sym = 'z';
      case {'qtrf','qzpk'}
         sym = 'q'
      case 'modal'
         sym = 's';
      otherwise
         error('bad type');
   end

   oo = vpa(o,0);                      % covert to double
   [on,od] = peek(oo);
   
      % fetch numerator ans denominator objects
      
   num = real(on);
   den = real(od);
   
      % compile readable text string; distinguish if denominator equals
      % one or else      
         
   if isequal(od,1)
      txt = PolyString(o,num,sym);
      txt = ['((',txt,'))'];
   else
      txt = RatioString(o,num,den,sym);
      txt = Trim(o,txt);
   end
   
      % depending on calling syntax return readable text string or
      % print to console
      
   if (nargout > 0)
      return
   end
   
      % print header
      
   name = get(o,'name');
   if isempty(name)
      fprintf('rational function (%g/%g)\n\n',Order(on),Order(od));
   else
      fprintf('%s: rational function (%g/%g)\n\n',name,Order(on),Order(od));
   end
   
      % print numerator/denuminator polynomial
      
   disp([setstr(' '+zeros(size(txt,1),3)),txt]);
   fprintf('\n');
   
      % if 'detail' option enable print also poles & zeros
      
   if opt(o,{'detail',0})      
      PoleZero(o,num,den);
   end
   
   function n = Order(p)
      p = trim(o,p);
      n = length(p) - 1;
   end
end

%==========================================================================
% Display Matrix
%==========================================================================

function txt = Matrix(o)               % Display Matrix                
   assert(isequal(o.type,'matrix'));
   
   M = o.data.matrix;
   [m,n] = size(M);

   if (nargout == 0)
      fprintf('\n');
   end
   
   width = 0;
   for (i=1:m)
      paragraph = [];
      txt = {};  rows = 0;
      for (j=1:n)
         M{i,j} = opt(M{i,j},'braces',opt(o,'braces'));
         if (n == 1)
            M{i,j} = opt(M{i,j},'maxlen',opt(o,'maxlen'));
         end
         
         if isempty(M{i,j})
            txt{j} = '[]';
         else
%           txt{j} = display(M{i,j});  % display rational function
            txt{j} = Ratio(M{i,j});    % display rational function
         end
         r = size(txt{j},1);
         rows = max(rows,r);           % estimate max rows
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

      if (nargout > 0)
         paragraphs{i} = paragraph;
         width = max(width,size(paragraph,2));
      else
         for (i=1:size(paragraph,1))
            fprintf('   %s\n',paragraph(i,:));
         end
         fprintf('\n');
      end
   end
   
         % compile full text array if outarg provided
         
   if (nargout >= 1)
      txt = [];
      for (i=1:length(paragraphs))
         paragraph = paragraphs{i};
         [m,n] = size(paragraph);
         tab = floor((width-n)/2);
         space = setstr(' '+zeros(m,width));
         if (i > 1)
            txt = [txt;space(1,:)];
         end
         txt = [txt; [space(:,1:tab),paragraph,space(:,1:width-n-tab)]];
      end
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
   braces = opt(o,{'braces',0});       % insert braces for exponents?
   
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
      elseif (braces)
         pow = [' ',sym,'^',sprintf('{%g}',i)];
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

%==========================================================================
% Display Poles & Zeros
%==========================================================================

function list = PoleZero(o,num,den)         % Display Poles & Zeros    
   [V,lambda] = gain(o);

   if (nargout == 0)
      fprintf('   Gain: %g\n',V);
   else
      list = {sprintf('Gain: %g',V)};
   end

   if type(o,{'szpk'})
      [r_num,r_den,K] = zpk(o);
   else
      [r_num,r_den,K] = zpk(o,num,den);
   end
   
   deg_num = length(r_num);
   deg_den = length(r_den);
   spc = setstr(' '+zeros(1,200));

      % calculate the field size

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

      % roots, omegas, zetas
   
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
               list{end} = [list{end},'             '];  
            end
         else
	         if ( abs(imag(ri)) > 100*eps )
	            q = abs(real(ri) / imag(ri));
	            zeta = q / sqrt(1 + q*q);
               if (zeta == 0)
                  omega = abs(imag(ri));
               else
	               omega = abs(real(ri) / zeta);
               end
               
               if (zeta < 100*eps)
                  zeta = 0;
               end
               
               if (nargout == 0)
   	            str = sprintf('%g',omega);
                  str = [spc(1:5-length(str)), str];  % spacer
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
   while (size(txt,2) > 0 && all(txt(:,1)==' '))
      txt(:,1) = [];
   end
   while (size(txt,2) > 0 && all(txt(:,end)==' '))
      txt(:,end) = [];
   end
end
