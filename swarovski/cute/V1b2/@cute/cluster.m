function varargout = cluster(o,mode)  % Find Cluster Indices                                      
%
% CLUSTER Brew cluster information or return facette dependent information
%         like facette indices or compact time vector
%
%         1) Brew cluster information with hard or soft caching
%
%            oo = cluster(o,'Brew')    % brew & soft cache cluster info
%            oo = cluster(o,o)         % same as above except hard refresh
%
%         2) Retrieving number clustered facettes
%
%            [n,fidx] = cluster(o,inf) % number of facettes & facette idx
%
%         3) Retrieve time vector with corresponding stream indices
%
%            [idx,t] = cluster(o)      % current time & stream index
%            [idx,t] = cluster(o,ifac) % time & stream index by facette idx
%            [idx,t] = cluster(o,0)    % for full data stream
%            [idx,t] = cluster(o,-1)   % for compact data stream
%            [idx,t] = cluster(o,2)    % for facette index 2
%
%         4) Show (graphically) cluster algorithm mechanics
%
%            oo = cluster(o,'Level')   % show Level clustering graphics
%            oo = cluster(o,'Sigma')   % show Sigma clustering graphics
%
%         Example
%
%            oo = cluster(o,'Brew');   % brew cluster info (soft cache)
%            [idx,t] = cluster(o);     % get current index and time
%
%         Input Options:
%            cluster.method: Cluster method (level,sigma)
%            show:           Show (graphically) cluster algorithm mechanics
%
%         Output Options:
%            facette:                  % description of facette idx setting
%
%         Copyright(c): Bluenetics 2020
%
%         See also: CUTE, COOK, BREW
%
   while (nargin < 1 || nargin > 2)    % arg number check              
      error('1 or 2 input args expected!');
   end
%
% One input arg
% 1) [t,idx] = cluster(o)              % time & index by current settings
%  
   while (nargin == 1)
      facette = opt(o,{'select.facette',0});
      [varargout{1},varargout{2}] = Facette(o,facette);
      return;
   end
%
% Two input args and 2nd arg is an object
% 1) oo = cluster(o,o)
%  
   while isobject(mode)                % 1) oo = cluster(o,o)          
      o  = Brew(o);                    % soft brew all cluster information
      oo = cache(o,o,'cluster');       % hard refresh of cluster cache seg
      varargout{1} = oo;
      return
   end
%
% Two input args and 2nd arg is a (double) number
% 1) [n,fac] = cluster(o,inf) % number of facettes & facette idx
% 2) [idx,t] = cluster(o,ifac) % stream index & time by facette idx
% 3) [idx,t] = cluster(o,0) % for full data stream
% 4) [idx,t] = cluster(o,-1) % for compact data stream
% 5) [idx,t] = cluster(o,2) % for facette index 2
%  
   while isa(mode,'double')            % 2) 3) 4) 5)
      if isinf(mode)                   % 1) [n,fac] = cluster(o,inf)
         itab = cache(o,'cluster.itab');
         varargout{1} = size(itab,1);  % number of facettes
         varargout{2} = opt(o,{'select.facette',0});  % facette index
      elseif (nargout <= 1)
         varargout{1} = Facette(o,mode);
      else
         [varargout{1},varargout{2}] = Facette(o,mode);
      end
      return
   end
%
% Two input args and 2nd arg is a character string
% 1) oo = cluster(o,'Brew')            % soft brewing of cluster cache
% 2) oo = cluster(o,'Level')           % show mechanics of Level algorithm
% 3) oo = cluster(o,'Sigma')           % show mechanics of Sigma algorithm
%  
     switch mode
         case 'Brew'                   % brew all cluster information
            oo = Brew(o);              % soft brewing of cluster cache seg
         case 'Level'
            oo = Level(o);             % show mechanics of Level algorithm
         case 'Sigma'
            oo = Sigma(o);             % show mechanics of Sigma algorithm
         otherwise
            error('bad mode');
     end
     varargout{1} = oo;
end

%==========================================================================
% Brew All Cluster Information
%==========================================================================

function oo = Brew(o)                  % Brew & Cache All Cluster Info 
%
% BREW   Brew & cache all required cluster information. This is done by
%        the following steps:
%
%           1) Call Cluster() function to perform selected cluster algo-
%              rithm and basically to receive the index table (itab), which
%              is a nf x 2 array containing beginning and ending indices
%              of each facette segment
%
%           2) Calculate the following additional quantities:
%              a) compact indices
%              b) compact time
%
   itab = Cluster(o);                  % call cluster algo (step 1)
   
     % calculate compact index & compact time
     
   idx = [];
   t = [];  tend = 0;
   for (i=1:size(itab,1))
      jdx = itab(i,1):itab(i,2);
      idx = [idx,jdx];

      tjdx = o.data.t(jdx) - o.data.t(jdx(1));
      t = [t,tend+tjdx];
      tend = t(end) + 0.01;
   end
   
      % store itab, compact index and time in cluster cache
   
   oo = cache(o,'cluster.itab',itab);  % index table
   
   compact.t = t;
   compact.idx = idx;
   oo = cache(oo,'cluster.compact',compact);
end

%==========================================================================
% Facette Time and According Stream Indices 
%==========================================================================

function [idx,t] = Facette(o,facette)  % Facette Time & Indices        
%
% FACETTE Retrieve time vector with corresponding stream indices
%
%            [idx,t] = Facette(o,ifac) % get time & indices by facette idx
%            [idx,t] = Facette(o,0)    % for full data stream
%            [idx,t] = Facette(o,-1)   % for compact data stream
%            [idx,t] = Facette(o,2)    % for facette index ifac=2
%
   oo = cache(o,'cluster');            % soft refresh of cache
   
   itab = cache(oo,'cluster.itab');    % get index table
   ifac = opt(oo,{'select.facette',0});% get facette index
   
   if (isa(facette,'double') && facette > 0)
      if (facette > size(itab,1))      % facette index out of range
         t = [];  idx = [];
         return
      end
      idx = itab(facette,1):itab(facette,2);
      if (nargout > 1)
         t = oo.data.t(idx);
      end
   elseif (facette == 0)
      if (nargout > 1)
         t = oo.data.t;
      end
      idx = 1:length(oo.data.t);
   elseif (facette == -1)
      compact = cache(o,'cluster.compact');
      idx = compact.idx;
      if (nargout > 1)
         t = compact.t;
      end
   end
end

%==========================================================================
% Cluster Algorithms
%==========================================================================

function itab = Cluster(o)             % General Cluster Algorithm     
   oo = with(o,'cluster');
   method = opt(oo,{'method','sigma'});

   switch method
      case 'level'
         [oo,itab] = Level(o);
      case 'sigma'
         [oo,itab] = Sigma(o);
      otherwise
         error('bad method');
   end
end
function [oo,itab] = Level(o)          % Level Cluster Method          
   show = opt(o,{'show',0});
   
   t = o.data.t;
   a = sqrt(o.data.ax.^2+o.data.ay.^2+o.data.az.^2);
   
   if any(size(t)~=size(a))
      error('sizes of a and t do not match!');
   end

   f = abs(a);
   fsort = sort(f);
   
   fdx = floor(length(fsort)*0.9);
   fm = fsort(fdx);
   jdx = find(f>=fm);

   Show1(o);
   
      % calculate diff function d
   
   d = diff(jdx);
   Show2(o);
   
   cdx = find(d > max(d)/10);   % cluster indices
   cdx = [cdx; (cdx+1)];
   cdx = [1, cdx(:)', length(jdx)];
   kdx = jdx(cdx);
   
   Show3(o);
   
   for (i=1:length(kdx)/2)      
      bmin = kdx(2*i-1);
      bmax = kdx(2*i);
      db = floor((bmax-bmin)*0.5);

      bmin = max(bmin-db,1);
      bmax = min(bmax+db,length(a));
      
      itab(i,:) = [bmin, bmax];
      
      bdx = itab(i,1):itab(i,2);
      if (show)
%        plot(t(bdx),a(bdx),'r', t(bdx),0*a(bdx),'go');
         plot(corazon(o),t(bdx),a(bdx),'r1');
      end
   end
   
   oo = var(o,'itab',itab);
   
   function Show1(o)                   % Show - Part 1                 
      if (show)
         subplot(311);
         plot(corazon(o),1:length(t),fsort,'r1');
         hold on;
         plot(fdx,fm,'go');
         plot([fdx, fdx],get(gca,'Ylim'),'g-.');
         title('Level Cluster Algorithm (start with sorted acceleration values)');
      end
   end
   function Show2(o)                   % Show - Part 2                 
      if (show)
         subplot(312);
         plot(corazon(o),1:length(jdx),jdx,'g1');
         hold on
         plot(corazon(o),1:length(d),d,'yyr3');
         title('Levels: sjdx = find(f>f0) & Difference of Indices');
         ylabel('jdx');
      end
   end
   function Show3(o)                   % Show - Part 3                 
      if (show)
         subplot(313);
         plot(corazon(o),t,f,'c1');
         hold on
      end
   end
end
function [oo,itab] = Sigma(o)          % Sigma Cluster Algorithm       
   show = opt(o,{'show',0});
   n = opt(o,{'cluster.segments',100});
   thresh = opt(o,{'cluster.threshold',3});
   
      % first get radial acceleration (sensor data(
      
   [t,ax,ay,az] = data(o,'t,ax,ay,az');
   a = sqrt(ax.*ax + ay.*ay + az.*az); % radial acceleration
   
   if (show)
      subplot(211);
      plot(corazon(o),t,a,'r');
      title('Sigma Cluster Algorithm');
      subplot(212);
   end

      % calculate standard deviations of segments. To do so find the
      % mxn segment index matrix as a reshape of the row vector 1:m*n
      % where m = floor(length(a)/n) 
      
   m = floor(length(a)/n);
   S = reshape(1:m*n,m,n);             % segment index matrix
   
      % for each segment (columns of S) build the standard deviation
      % and store standard deviations (sigmas) in the n-row vector sig
      
   sig = std(a(S));                    % easy!
      
      % next we have to find the noise threshold (given by signoise)
      % This is accomplished by taking the maximum of the 10% smallest
      % sigmas
      
   sortsig = sort(sig);
   k = ceil(0.1*n);                    % index of the max smallest 10%
   signoise = thresh*sortsig(k);       % so we got the noise threshold :-)
   
      % calculate a binary vector which tells us which segment belongs
      % to noise and which not
      
   noisy = (sig < signoise);
   
      % show noisy sigmas in the diagram
      
   if (show)
      for (i=1:n)
         idx = S(:,i)';
         if (noisy(i))
            plot(t(idx),sig(i)*ones(size(idx)),'co');
         else
            plot(t(idx),sig(i)*ones(size(idx)),'ro');
         end
         hold on
      end
   end
   
      % build the clusters
      
   weight = 0;
   direction = sign(0.5-noisy(1));
   ttab = [1 NaN];         % init track table
   itab = [S(1,1) NaN];
   i = 1;                  % init row index
   
   for (k=1:length(noisy))
      if (direction > 0)   % upward counting (since not noisy)
         if ~noisy(k)
            weight(end) = weight(end) + 1;
         else
            weight(end+1) = -1;
            direction = -1;
            
            itab(i,2) = S(end,k-1);
            ttab(i,2) = k-1;           % refresh track table
            i = i+1;
            ttab(i,1:2) = [k NaN];     % extend track table
            itab(i,1:2) = [S(1,k) NaN];
         end
      else                 % downward counting (since noisy)
         if noisy(k)
            weight(end) = weight(end) - 1;
         else
            weight(end+1) = +1;
            direction = +1;
            
            itab(i,2) = S(end,k-1);
            ttab(i,2) = k-1;           % refresh track table
            i = i+1;
            ttab(i,1:2) = [k NaN];     % extend track table
            itab(i,1:2) = [S(1,k) NaN];
         end
      end
   end
   ttab(end) = k;
   itab(end,2) = length(a);
   
      % append weight as kast column and sort
      
   index = (1:length(weight));
   itab = [itab,weight(:),index'];
   [weight,idx] = sort(-weight);
   
   weight = -weight;
   Itab = itab(idx,:);
   index = index(idx);
   
      % determine clusters
      
   jdx = index(1);
   wref = weight(1);                  % init reference weight
   
   threshold = 0.5;
   for (i=2:length(weight))
      if (weight(i) > threshold*wref)
         jdx(end+1) = index(i);
         wref = mean(weight(1:i));
      else
         break
      end
   end
   
      % get final itab
      
   jdx = sort(jdx);
   itab = itab(jdx,1:4);
   
      % calculate total indices
   
   index = [];
   for (i=1:size(itab,1))
      index = [index,itab(i,1):itab(i,2)];
   end
   
   if (show)
      grid(o);
      subplot(211);
      hold on
      plot(t(index),0*t(index),'go');
      grid(o);
   end

   itab = itab(:,1:2);
   %oo = var(o,'itab,index',itab,index);
   oo = var(o,'itab',itab);
end
