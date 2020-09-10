function out = tffdisp(G,name)
%
% TFFDISP Display transfer function. 
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
   maxlen = 60;  cur_len = 10;	off = 4;
   spc = '                               ';  spc = [spc, spc, spc];
   bar = '-------------------------------';  bar = [bar, bar, bar];

%
% roots, degrees
%
   [class,kind,sign] = ddmagic(G);
  
   if ( class ~= tffclass )
      error('No tffclass object');
   end

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
   else
      n_str = [n_str,trf.trim(str)];
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
   else
      %d_str = trf.trim(d_str);
      d_str = [d_str,trf.trim(str)];
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
	      if ( i < deg  &&  abs(imag(ri)) > eps )
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
% Auxillary Functions
%==========================================================================
   
function V = Gain(num,den,deg_num,deg_den)
%
% GAIN   Extract gain factor
%
   if ( all(num == 0)  &&  all( den == 0 ) )
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

%==========================================================================
% Auxillary Functions
%==========================================================================

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Rev   Date        Who   Comment
%  ---   ---------   ---   --------------------------------------------
%    0   19-Nov-93   hux   Version 2.0
%    1   29-May-14   hux   fixed negative omega and omega = NaN
%    2   04-Jul-17   hux   print into list, if nargout > 0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%