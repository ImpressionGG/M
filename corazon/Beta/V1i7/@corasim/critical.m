function [om,gain] = critical(o)
%
% CRITICAL   Find critical frequencies and gains. 
%
%                [om,gain] = critical(L0)
%
%            Critical (circular) frequencies w are defined by 
%
%                arg(G(jw)) = (2*k+1)*pi for positive gain
%            or
%                arg(G(jw)) = (2*k)*pi    for negative gain
%
%            The critical gain calculates as
%
%                       { + 1/|G(jw)| for arg(G(jw)) = (2*k+1)*pi
%                gain = {
%                       { + 1/|G(jw)| for arg(G(jw)) = (2*k)*pi
%
%            Copyright(c): Bluenetics 2021
%
%            See also: CORASIM
%
   [n,ni,no] = size(o);
   
   if ((ni*no) > 1)
      error('multivariable systems not yet supported')
   end
   
   [om,gain] = Siso(o);                % solve for single variable case
end

%==========================================================================
% Single Input/Output Systems
%==========================================================================
   
function [om,gain] = Siso(o)
   [~,om] = fqr(o);                        % get omega range
   oscale = opt(o,{'oscale',1});
   Om = om/oscale;
   
   Gjw = trfval(o,1i*Om);
   N = 50;                                 % number of iterations
   
   
   phi = MapPhi(angle(Gjw)+pi);
   [olim,sig,plim] = Intervals(Om,phi);
   for (i=1:N)
      Om = mean(olim);
      
      Gjw = trfval(o,1i*Om);
      phi = MapPhi(angle(Gjw)+pi);
      phi = phi .* sig;
      
      idx = find(phi <= 0);
      if ~isempty(idx)
         olim(1,idx) = Om(idx);
         plim(1,idx) = phi(idx);
      end
      
      idx = find(phi >= 0);
      if ~isempty(idx)
         olim(2,idx) = Om(idx);
         plim(2,idx) = phi(idx);
      end
      
      err = norm(sum(plim));
   end
   
   sgn = -sign((diff(plim)>pi)-0.5);
   gain = sgn .* abs(Gjw);
   om = Om*oscale;
   
   function phi = MapPhi(phi)             % map to range -pi ... pi    

         % map all (phi > 0) to range [-2*pi ... 0]

      idx = find(phi > pi);
      while ~isempty(idx)
         phi(idx) = phi(idx) - 2*pi;
         idx = find(phi > pi);   
      end

         % map all (phi < -2*pi0) to range [-2*pi ... 0]

      idx = find(phi < -pi);
      while ~isempty(idx)
         phi(idx) = phi + 2*pi;
         idx = find(phi < -pi);   
      end   
   end
   function [om,sig,phi,idx] = Intervals(om,phi)                       
      sig = sign(phi(1));
      
      tab = [1 1 -sig];
      for (k=2:length(om))
         if (sig > 0)
            if (phi(k) >= 0)
               tab(end,2) = k;
            else
               sig = -1;
               tab(end+1,1:3) = [k k -sig];
            end
         else
            if (phi(k) <= 0)
               tab(end,2) = k;
            else
               sig = +1;
               tab(end+1,1:3) = [k k -sig];
            end
         end
      end
      
      idx = [];
      for (k=1:size(tab,1)-1)
         idx(k,1:2) = [tab(k,2), tab(k+1,1)];
         %ivl(k,1:3) = [om(tab(k,2)), om(tab(k+1,1)), tab(k,3)];
      end
      sig = tab(1:end-1,3)';
   
      om = om(idx)';
      phi = phi(idx)';
   end
end