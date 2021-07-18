function oo = damping(o,dtab)
%
% DAMPING     Set specific damping values. This method directly manipulates
%             the damping table (oo.par.dtable) of an SPM typed object. By
%             brewing the parameter variation the damping parameters of the
%             A-matrix are replaced according to the damping table.
%
%             1) set damping according to damping table (dtab)
%
%                dtab = [0 0, 0.05; 9 12, 0.08; 15 24, 0.10]
%                damping(o,dtab)     % store damping according to dtab
%
%             2) get effective damping or plot effective damping
%
%                zeta = damping(o)   % get effective damping (zeta values)
%                damping(o)          % plot effective damping
%
%             Example 1:
%
%                dtab = ...
%                [
%                   0  0,  0.05     % zeta = 5% by default
%                   9 12,  0.08     % zeta = 8% for modes 9:12
%                  15 24,  0.10     % zeta = 10% for modes 15:24 
%                ];
%
%             Options
%                subplot:              specify subplot (default 111)
%
%             Copyright(c): Bluenetics 2021
%
%             See also: SPM, VARIATION, BREW SYSTEM
%
   if (nargin == 1 && nargout > 0)
      oo = Damping(o);
   elseif (nargin == 1 && nargout == 0)
      Damping(o);
   elseif (nargin == 2)                % store variation in object params
      Store(o,dtab);
   else
      error('bad args');   
   end
end

%==========================================================================
% Get/Plot Effective Damping
%==========================================================================

function zeta = Damping(o)             % Effective Damping
   if ~type(o,{'spm'})
      error('SPM typed object expected');
   end

   A = data(o,'A');
   n = floor(length(A)/2);
   i1 = 1:n;  i2 = n+1:2*n;
   
   a21 = -diag(A(i2,i1));              % a21 = omega^2
   a22 = -diag(A(i2,i2));              % a22 = 2*zeta*omega
   
   omega = sqrt(a21);
   zeta = a22 ./ omega / 2;
   zeta0 = zeta;
   
       % zeta holds now the values of the A matrix; if a damping table 
       % is provided then we override the zeta value according to the
       % damping table
      
   dtab = get(o,'dtable');
   if ~isempty(dtab)
      Check(o,dtab);
       
      for (i=1:size(dtab,1))
         from = dtab(i,1);  to = dtab(i,2);  zt = dtab(i,3);
          
         for (k=from:to)
            if (k == 0)
               zeta = 0*zeta + zt;    % replace all zeta values
            elseif ( 1 <= k && k <= n)
               zeta(k) = zt;
            end
         end
      end
   end
   
   if (nargout == 0)
      Plot(o,zeta,zeta0);
   end
end

%==========================================================================
% Store Variation
%==========================================================================

function Store(o,dtab)
   Check(o,dtab);                      % check consistenccy of dtab
   
   oo = o;                             % rename
   o = pull(o);                        % pull shell object
   
   if container(oo)
      o = set(o,'dtable',dtab);
   else
      ID = id(oo);
      [~,idx] = id(o,ID);              % get child index
      
      if isempty(idx)
         error('object could not be located in shell');
      end
      
      oo = o.data{idx};
      oo = set(oo,'dtable',dtab);
      o.data{idx} = oo;
   end
   
   push(o);                            % push shell object back
   cache(oo,oo,[]);                    % clear total cache (hard)
end

%==========================================================================
% Check Consistency of Variation Table
%==========================================================================

function Check(o,dtab)                 % Check Vtab Consistency        
   A = data(o,'A');
   n = floor(length(A)/2);
   
   if (~isempty(dtab) && size(dtab,2) ~= 3)
      error('bad sized damping table');
   end
end

%==========================================================================
% Plot Damping
%==========================================================================

function Plot(o,zeta,zeta0)
   sub = opt(o,{'subplot',111});
   subplot(o,sub);
   
   for (i=1:length(zeta))
      col = o.iif(dark(o),'w','k');
      
      plot([i i],[0 zeta(i)],col);
      plot([i i],[zeta(i) zeta0(i)],'r');
      plot(i,zeta0(i),[col,'o'], i,zeta(i),'ro');
   end
   
   N = norm(zeta-zeta0);
   title(sprintf('Mode Damping  (||zeta-zeta0|| = %g)',N));
   ylabel('zeta');
   xlabel('mode number');
   
   subplot(o);
end