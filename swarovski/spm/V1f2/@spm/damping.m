function oo = damping(o,arg2,arg3)
%
% DAMPING     Set specific damping values. This method directly manipulates
%             the damping table (oo.par.dtable) of an SPM typed object. By
%             brewing the parameter variation the damping parameters of the
%             A-matrix are replaced according to the damping table.
%
%             1) set damping according to damping table (dtab)
%
%                dtab = [0 0, 0.05; 9 12, 0.08; 15 24, 0.10]
%                damping(o,o,dtab)        % store damping according to dtab
%                                         % changes in shell and entire
%                                         % cache is cleared
%
%                oo = damping(o,dtab)     % store dtab to oo's parameters
%                                         % no changes in shell
%
%             2) get effective damping or plot effective damping
%
%                zeta = damping(o)   % get effective damping (zeta values)
%                damping(o)          % plot effective damping
%
%             3) read damping table from damping file and store in object
%                parameters
%
%                damping(o,'')               % read & set damping table 
%                                            % from proper file
%
%                dtab = damping(o,'#05.dmp') % read dtab from file #5.dmp
%                dtab = damping(o,'#05')     % read dtab from file #5.dmp
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
%             Example 2:
%
%                damping(cuo,'')    % load provided damping table for cuo
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
      if ( ischar(arg2) )
         file = arg2;                  % rename arg2
         if (nargout == 0)
            Load(o,file);
         else
            oo = Load(o,file);
         end
      else
         dtab = arg2;
         if (nargout == 0)
            error('1 output arg expected');
         else
            oo = Store(o,dtab);
         end
      end
   elseif (nargin == 3)                % store variation in object params
      if ~isequal(o,arg2)
         error('expected arg2 to be a copy of arg1');
      end
      dtab = arg3;
      if (nargout == 0)
         Store(o,dtab);
      else
         error('no output arg expected');
      end
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
       % is provided for the package object then we override the zeta 
       % value according to the damping table

   if opt(o,{'variation.package',0})
      po = pkg(o);
      dtab = get(po,'dtable');            % get dtable from package object
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
   end
   zeta1 = zeta;                       % zeta1 after package object's dtab
       
       % zeta holds now the values of the A matrix modified by the package
       % info object's damping table. If the data object also provides a 
       % damping table then we override
      
   if opt(o,{'variation.object',0})
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
   end
   
   if (nargout == 0)
      Plot(o,zeta0,zeta1,zeta);
   end
end

%==========================================================================
% Store Variation
%==========================================================================

function oo = Store(o,dtab)
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
   
   if (nargout == 0)
      push(o);                         % push shell object back
      cache(oo,oo,[]);                 % clear total cache (hard)      
   end
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

function Plot(o,zeta0,zeta1,zeta)
   sub = opt(o,{'subplot',111});
   subplot(o,sub);
   
   for (i=1:length(zeta))
      col = o.iif(dark(o),'w','k');
      
      plot([i i],[0 zeta0(i)],col);
      plot([i i],[zeta0(i) zeta1(i)],'r');
      plot([i i],[zeta1(i) zeta(i)],'g');
      plot(i,zeta0(i),[col,'o'], i,zeta1(i),'ro', i,zeta(i),'go');
   end
   
   N = norm(zeta-zeta0);
   title(sprintf('Mode Damping  (||zeta-zeta0|| = %g)',N));
   ylabel('zeta');
   xlabel('mode number');
   
   subplot(o);
end

%==========================================================================
% Load Damping Table from File
%==========================================================================

function dtab = Load(o,file)
   if isempty(file)
      if (container(o) )
         error('loading of damping table not provided for shell object');
      end
      
      number = get(o,'number');
      if isempty(number)
         error('empty number');
      end
      
      file = sprintf('#%02d',number);
   end
   
      % provide extension if not yet provided
      
   extension = (length(file) >= 4 && isequal(file(end-3:end),'.dmp'));
   if ~extension
      file = [file,'.dmp'];            % auto provide extension      
   end
   
      % make full path and open file
      
   path = [get(o,'dir'),'/',file];  
   fid = fopen(path,'r');
   
   dtab = [];                          % init dtab
   
   if ~isequal(fid,-1)
      line = fgetl(fid);
      while (1)
         if isequal(line,-1);
            break;
         end

            % if we have no comment line read 3 double numbers

         if ~(length(line) >= 1 && line(1) == '%')
            row = eval(['[',line,']'],[]);
            row = row(:)';
            if (length(row) ~= 3)
               error('bad file format');
            end
            dtab = [dtab; row];
         end

         line = fgetl(fid);
      end
      fclose(fid);
   end
   
      % if no output args provided then we write dtab directly to the
      % parameters
      
   if (nargout == 0)
      if (container(o))
         error('improper calling syntax for shell object');
      end
      
      assert(isempty(dtab) || size(dtab,2)==3);
      damping(o,dtab);
   end
end
