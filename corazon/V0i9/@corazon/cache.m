function varargout = cache(o,varargin) % Cache Method                  
%
% CACHE Get or set cached variable settings & cache management. Cache can
%       be refreshed hard or soft. For soft refresh only the cache of the
%       local object is affected while current object in shell is left
%       unaffected. In contrast with hard refresh the object is stored back
%       to the shell (always as current object!).
%
%       Remark: The use of hard operations can be dangerous because a store
%       back of the object to the shell (overwriting the current object)
%       can happen in a non-deterministic way. Thus the syntax for hard 
%       operations requires double-passing the object (both as arg1 and
%       arg2) to clearly visualize a hard operation!
%
%         [oo,bag] = cache(oo,oo,'polar')   % cache segment refresh (hard)
%         oo = cache(oo,oo,[])              % clear object cache (hard)
%         oo = cache(oo,oo,{})              % clear all caches (hard)
%         oo = cache(oo,'polar',[])         % clear 'polar' cache segment
%
%         [oo,bag] = cache(o,'polar')       % soft refresh & get bag
%         [oo,bag] = cache(o,[])            % clear cache (soft)
%
%         oo = cache(oo,'polar.r',r)        % set cached value (soft)
%         r = cache(oo,'polar.r')           % get cached value (soft)
%  
%         bag = cache(oo,{'polar'})         % cache dirty if bag is empty
%
%      Cache can be stored back to shell, unless prohibited by option
%      oo = opt(oo,'cache.hard',0)
%    
%         cache(oo,oo)                      % cache storeback to shell
%
%
%      Comprehensive description of calling syntax
%
%      1) Set cached values
%
%         oo = cache(oo,{'polar','Polar'},'r',r) % store radius in cache
%         oo = cache(oo,{'polar','Polar'},'p',p) % store phi in cache
%
%         oo = cache(oo,'polar.r',r)             % syntactic sugar
%         oo = cache(oo,'polar.p',p)             % syntactic sugar
%
%         bag = struct('r',r,'p',p);             % bag of cached variables
%         oo = cache(oo,{'polar','Polar'},bag)   % store bag in cache
%         oo = cache(oo,'polar',bag)             % syntactic sugar
%
%      2) Get cached values
%
%         r = cache(oo,{'polar','Polar'},'r')    % get radius from cache
%         p = cache(oo,{'polar','Polar'},'p')    % get phi from cache
%
%         r = cache(oo,'polar.r')           % get radius from cache
%         p = cache(oo,'polar.p')           % get phi from cache
%
%         oo = cache(oo,'polar')            % refresh cache segment
%         [oo,ref] = cache(oo,'polar')      % refresh & refreshed?
%         cache(oo,'polar')                 % conditional refresh cuo
%
%      3) Show cache contents or test for empty cache
%
%         cach = cache(oo)                  % get cache data
%         cache(oo)                         % show cache contents
%
%         bag = cache(oo,{'polar'})         % cache dirty if bag is empty
%
%      Cached variable setting are stored in object's work properties. 
%      Caching is only alowed for non-container objects. Cached variables
%      are always related to a cache segment, where each segment comprises
%      the following components:
%
%         a) the name of the segment which has to match the name of the
%            option settings controlling the segment
%         b) a local brew function name (for the brew method)
%         d) one or more cached variable tags
%
%      Example 1: In the following example
%
%         oo = cache(oo,{'polar','Polar'},'r',r) % store radius in cache
%         p = cache(oo,{'polar','Polar'},'p')    % get phi from cache
%
%      the segment name is 'polar', the local brew function name is 'Polar'
%      and the cached variable tags are 'r' and 'p'. 
%
%      The internal storage of a cache segment according to above examples
%      is as follows:
%
%         oo.work.cache.polar.cache.brewer = 'Polar'     % control info
%         oo.work.cache.polar.cache.opt = opt(o,'polar') % control info
%         oo.work.cache.polar.r = r                      % cached radius
%         oo.work.cache.polar.p = p                      % cached phi
%      
%      It is not allowed to provide different brew function names for the 
%      same cache segment, i.e. the following two statements result in an
%      error
%
%         oo = cache(oo,{'polar','Polar1'},'r',r)    % brew with 'Polar1'
%         oo = cache(oo,{'polar','Polar2'},'p',p)    % error ('Polar2')
%
%      while different brew functions for different cache segments are
%      allowed:
%
%         oo = cache(oo,{'pol1','Pol1'},'r',r)       % cache segment 'pol1'
%         oo = cache(oo,{'pol2','Pol2'},'p',p)       % cache segment 'pol2'
%
%      Example 2: typical access sequence
%
%         oo = current(o);
%         oo = cache(oo,'polar');      % refresh & store back to cuo
%         r = cache(oo,'polar.r');     % access cache variable r
%         p = cache(oo,'polar.p');     % access cache variable p
%
%      Example 3: test if cache is up-to-date
%
%         bag = cache(oo,{'polar'});
%         if isempty(bag)                     
%            fprintf('polar cache segment is dirty!\n');
%         end
%
%      Example 4: clear specific cache segment and store back to shell
%
%         oo = cache(oo,'polar',[]);   % clear polar cache segment
%         cache(oo,oo);                % cache store back to shell
%
%      Options:
%
%         cache.hard:     support/prohibits hard refresh 'cache(oo,oo)'
%                         (default: 1, hard refresh supported)
%
%      Copyright(c): Bluenetics 2020 
%
%      See also: CORAZON, BREW, VAR
%

%
% One input arg
% 1) cache(oo) % show cache contents
%
   while (nargin == 1)                 % 1 input arg                   
      if (nargout > 0)
         if container(o)
            error('caching not supported for container objects!');
         end
         varargout{1} = work(o,'cache');
      else
         Show(o);                      % show cache contents
      end
      return
   end
%
% Two input args
% 1) [oo,ref] = cache(oo,'polar')      % refresh cache segm. & update cuo
% 2) [oo,ref,~] = cache(oo,'polar')    % refresh without updating cuo
% 3) cache(oo,'polar')                 % soft refresh polar segment
% 4) bag = cache(o,{'polar'})          % empty if not refreshed (obsolete!)
% 5) r = cache(oo,'polar.r')           % syntactic sugar: get value
% 6) oo = cache(oo,[])                 % soft clear cache
% 7) cache(oo,oo)                      % unconditionally store to cuo
%
   if container(o)                     % error, except cache(o,o,{})
      if (nargin ~= 3) || ~isobject(varargin{1}) || ~isequal(varargin{2},{})
         error('caching not supported for container objects!');
      end
   end
   while (nargin == 2)                 % 2 input args                  
      if iscell(varargin{1})           % 4) bag = cache(o,{'polar'})
         list = varargin{1};
         if length(list) ~= 1 || ~ischar(list{1})
            error('arg2 must be 1-list containing character tag');
         end
         seg = list{1};
         varargout{1} = Segment(o,seg);
         return
      elseif (isobject(varargin{1}) && nargout == 0) % 7) cache(oo,oo)
         if opt(o,{'cache.hard',1})    % unless prohibited by option
            Hard(o,varargin{1});       % hard store back of obj to shell
         end
         return
      elseif isempty(varargin{1})      % 6) oo = cache(oo,[]) 
         [varargout{1},varargout{2},varargout{3}] = SoftRefresh(o,[]);
         return;
      end
      
         % process arg2 being a character tag
      
      [seg,brewer,tag] = Split(varargin{1});
      
      if isempty(tag)                  % 1) & 2) & 3)
         if (nargout == 0)             % 3) cache(oo,'polar')
            segment = Segment(o,seg);
            if isempty(segment)        % then cache segment is dirty
               fprintf('*** warning: soft refreshing ''%s'' cache\n',seg);
               fprintf('*** possible indication of missing hard refresh!\n');
               varargout = SoftRefresh(o,seg,brewer);
            end
         elseif (nargout <= 2)         % 1) [oo,bag] = cache(oo,'polar') 
            varargout{1} = o;          % in case we need no refresh
            segment = Segment(o,seg);
            if isempty(segment)        % then cache segment is dirty
               fprintf('*** warning: soft refreshing ''%s'' cache\n',seg);
               fprintf('*** possible indication of missing hard refresh!\n');
               [oo,bag,rfr] = SoftRefresh(o,seg,brewer);
               varargout{1} = oo;
               varargout{2} = bag;
               varargout{3} = rfr;
            else
               varargout{2} = Bag(o,segment);
               varargout{3} = false;   % no refresh was necessary
            end
         else                          % 2) [oo,bag,~] = cache(oo,'polar')
            [varargout{1},varargout{2},varargout{3}] = ...
               SoftRefresh(o,seg,brewer);
         end
         return
      else                             % 5) r = cache(oo,'polar.r') 
         varargout{1} = Get(o,{seg,brewer},tag);
      end
      return
   end
%
% Three input args
% 1) oo = cache(oo,'polar',bag)        % syntactic sugar: set bag
% 2) oo = cache(oo,'polar.r',r)        % syntactic sugar: set value
% 3) r = cache(oo,{'pol','Pol'},'r')   % get cached value
% 4) oo = cache(oo,{'pol','Pol'},bag)  % store cache segment's bag
% 5) [oo,bag] = cache(oo,oo,'polar')   % hard refresh of cache segment 
% 6) [oo,bag] = cache(oo,oo,[])        % clear object cache (hard) 
% 7) [oo,bag] = cache(oo,oo,{})        % clear all caches (hard) 
%
   while (nargin == 3)                 % 3 input args                  
      if isobject(varargin{1})         % 5) [oo,bag,rfr] = cache(oo,oo,'polar')                                        
         if isempty(varargin{2})       % 6) [oo,bag,rfr] = cache(oo,oo,[])
            if iscell(varargin{2})
               o = pull(o);            % fetch shell object
               for (i=1:length(o.data))
                  oo = o.data{i};
                  cache(oo,oo,[]);     % clear object cache
               end
               oo = [];
            else
               oo = cache(o,[]);       % clear cache
               cache(oo,oo);           % hard cache refresh
            end
            bag = [];  rfr = 0;
         else
            [oo,bag,rfr] = HardRefresh(o,varargin{2});
         end
         varargout{1} = oo; 
         varargout{2} = bag;
         varargout{3} = rfr;
         return
      end
      
         % otherwise 
      
      if iscell(varargin{1})           
         if isstruct(varargin{2})      % 4) oo=cache(oo,{'pol','Pol'},bag)
            varargout{1} = Set(o,varargin{1},varargin{2});
         else                          % 3) r = cache(oo,{'pol','Pol'},'r')
            varargout{1} = Get(o,varargin{1},varargin{2});
         end
      else                             % 1) or 2) oo = cache(oo,'p...',...)
         [seg,brewer,tag] = Split(varargin{1});
         if isempty(tag)               % 1) oo = cache(oo,'polar',bag) 
            varargout{1} = Set(o,{seg,brewer},varargin{2});
         else                          % 2) oo = cache(oo,'polar.r',r)
            varargout{1} = Set(o,{seg,brewer},tag,varargin{2});
         end
      end
      return
   end
%
% Four input args
% 1) oo = cache(oo,{'pol','Pol'},'r',r)% store radius in cache
%
   while (nargin == 4)                 % 4 input args                  
      varargout{1} = Set(o,varargin{1},varargin{2},varargin{3});
      return
   end
%   
% we should never come here!
%
   error('bad arg list');
end

%==========================================================================
% Refresh
%==========================================================================

function varargout = SoftRefresh(o,seg,brewer)                         
%
% SOFTREFRESH Refresh cache segment (soft) if not up to date
%
%        [oo,bag,rfr] = SoftRefresh(o,seg)          % refresh cache (soft)
%        [oo,bag,rfr] = SoftRefresh(o,seg,brewer)   % refresh cache (soft)
%        [oo,bag,rfr] = SoftRefresh(o,[])           % clear cache (soft)
%
%
%   oo is the refreshed object, bag is the cache segment's bag, while 
%   rfr (refreshed) is a boolean indicator whether a refresh has happened
%   or not
%       
   if isempty(seg)
      o = work(o,'cache',[]);         % clear cache
      bag = [];
      rfr = true;
   else
      if ~ischar(seg) || ~isempty(find(seg=='.'))
         error('cache segment tag must be character and not contain a dot');
      end
      if (nargin < 3)
         brewer = [upper(seg(1)),lower(seg(2:end))];
      end
   
      segment = Segment(o,seg);        % fetch cache segment
      rfr = isempty(segment);          % refresh yes/no ?

      if (rfr)                         % in case of empty segment ...
         args = arg(o);                % save args
         o = brew(o,brewer);           % ... brew actual data
         o = arg(o,args);              % restore args
         segment  = Segment(o,seg);    % fetch cache segment again
      end

      bag = Bag(o,segment);            % extract bag from segment
   end
   
   varargout{1} = o;                   % updated object
   varargout{2} = bag;                 % cache segment's bag
   varargout{3} = rfr;                 % refresh happened?
end
function varargout = HardRefresh(o,seg,brewer)                         
%
% HARDREFRESH 
%     Refresh cache segment (hard) if not up to date, which means in case
%     of a refresh to store object back to shell as current object
%
%        [oo,bag,rfr] = HardRefresh(o,seg)
%        [oo,bag,rfr] = HardRefresh(o,seg,brewer)
%        [oo,bag,rfr] = hardRefresh(o,[])      % clear cache (soft)
%
   if (nargin < 3)
      [oo,bag,rfr] = SoftRefresh(o,seg);
   else
      [oo,bag,rfr] = SoftRefresh(o,seg,brewer);
   end
   
   if (rfr && opt(o,{'cache.hard',1})) % prohibited by option 'cache.hard'?
      Hard(o,oo);                      % hard store back of obj to shell
   end

   varargout{1} = oo;                  % updated object
   varargout{2} = bag;                 % cache segment's bag
   varargout{3} = rfr;                 % refresh happened?
end

%==========================================================================
% Get/Set and Refresh
%==========================================================================

function oo = Set(o,list,tag,value)    % Set Cache Variable            
%
% SET  Set cache variable
%
%         oo = Set(oo,{'pol','Pol'},bag)     % set cache segment's bag
%         oo = Set(oo,{'pol','Pol'},'r',r)   % set radius in cache
%
%      Clear cache segment
%
%         oo = Set(oo,{'pol','Pol'},[])
%
   if ~iscell(list) || length(list) ~= 2
      error('2-list expected (arg2)');
   end

   seg = list{1};  brewer = list{2};
   if ~ischar(seg) || ~ischar(brewer)
      error('char expected for list items (arg2)')
   end
   
      % all checks passed so far - get cache segment provided with
      % valid cache segment control data (VCSCD)
      
   segment = Provide(o,seg,brewer);    % get segment provided with VCSCD
      
      % dispatch on input arg number
      
   if (nargin == 3 && isempty(tag))    % means: clear cache segment
      oo = o;                          % copy to output
      oo.work.cache.(seg) = [];         % make sure field exists
      oo.work.cache = rmfield(oo.work.cache,seg);
      return
   elseif (nargin == 3)
      bag = tag;                       % rename arg3
      bag.cache = segment.cache;       % copy cache control part
      segment = bag;                   % store back to segment
   elseif (nargin == 4)
      segment.(tag) = value;
   else
      error('bad arg list');
   end
   
      % store back cache segment
      
   oo = o;
   oo.work.cache.(seg) = segment;
end
function value = Get(o,list,tag)       % Get Cache Variable            
%
% GET  Get cache variable
%
%         bag = Get(oo,{'pol','Pol'})         % get cache segment's bag
%         value = Get(oo,{'pol','Pol'},'r')   % get radius from cache
%
   if ~iscell(list) || length(list) ~= 2
      error('2-list expected (arg2)');
   end

   seg = list{1};  brewer = list{2};
   if ~ischar(seg) || ~ischar(brewer)
      error('char expected for list items (arg2)')
   end
   
      % if cache segment is not available we return empty value
      
   %if isempty(work(o,['cache.',seg]))
   %   value = [];
   %   return
   %end
   
      % all checks passed so far - fetch cache segment (if necessary then
      % brew() has to be consulted for cache segment refresh
      
   segment = Fetch(o,seg,brewer);      % fetch cache segment's data
   
      % dispatch on input arg number
      
   if (nargin == 2)
      value = rmfield(segment,'cache');
   else
      if isfield(segment,tag)
         value = segment.(tag);
      else
         value = [];
      end
   end
end

%==========================================================================
% Segment, Provide and Fetch
%==========================================================================

function segment = Segment(o,seg)      % Get Consistent Segment        
%
% SEGMENT  Retrieve consistent cache segment. Non-empty return value if
%          consistent, otherwise empty
%
   segment = work(o,['cache.',seg]);
   consistent = ~isempty(segment) && isfield(segment,'cache');
   
      % if the segment is consistent, i.e. has a 'cache' field, then we
      % may assume that fields <seg>.cache.brewer and <seg>.cache.opt exist 
   
   if consistent                       % then continue checking
      opts = opt(o,seg);
      copy = segment.cache.opt;        % a copy of the options
      if isequal(opts,copy)            % mismatch of control data?
         return                        % no mismatch - bye!
      end
   end
   
      % inconsistent! return empty value
      
   segment = [];
end
function bag = Bag(o,segment)          % Extract Bag from Segment      
   if isempty(segment)
      bag = [];
   else
      bag = rmfield(segment,'cache');
   end
end
function segment = Provide(o,seg,brwr) % Provide Segment Control Data  
   segment = Segment(o,seg);
   if isempty(segment)
      cache.brewer = brwr;             % provide brewer
      cache.opt = opt(o,seg);          % provide a copy of option settings
      segment.cache = cache;           % provide cache control data
   end
end
function segment = Fetch(o,seg,brewer) % Fetch Brewed Cache Segment    
%
% FETCH   Check if cache segment is up to date! If not then consult brewer
%         to brewup data and refresh cache segment with additional refresh
%         of current object. After updating return cache segment
%
%
   segment = Segment(o,seg);
   if ~isempty(segment)
      return
   end
     
      % Otherwise cache is not up-to-date and we have to brew actual data
      % to be cached, while we have to refresh current object subsequently.
      % Make sure that your brew method supports the local brewer function
   
   oo = brew(o,brewer);                % brew actual data      
   segment = work(oo,['cache.',seg]);
end

%==========================================================================
% Helper
%==========================================================================

function Hard(o,oo)                    % Hard Store Object to Shell    
%
% HARD   Hard store updated object to shell (hard operation)
%
%  if ~type(current(o),{'shell'})
   if ~type(oo,{'shell'})
      o = pull(o);                     % fetch shell object
      id = objid(oo);
      for (i=1:length(o.data))
         oi = o.data{i};
         if isequal(objid(oi),id)      % matching object IDs?
            o.data{i} = oo;
            push(o);
            return                     % and we are done
         end
      end
      
         % if we come beyond this point then something suspicious
         
      fprintf('*** warning: cold refresh of cache not possible!\n');
   end
end
function [seg,brewer,tag] = Split(tag) % Split Tag into Ingredients    
   idx = find(tag=='.');
   if isempty(idx)
      seg = tag;
      brewer = [upper(seg(1)),lower(seg(2:end))];
      tag = [];
   else
      seg = tag(1:idx(1)-1);
      brewer = [upper(seg(1)),lower(seg(2:end))];
      tag = tag(idx(1)+1:end);
   end
end
function Show(o)                       % Show Cace Contents            
   if (container(o))
      error('cache not supported for container objects!');
   end
   ShowObject(o);
   
   function ShowObject(o)
      cach = work(o,'cache');             % get all cache data
      if isempty(cach)
         fprintf('cache is empty!\n');
         return
      end

      segs = fields(cach);                % list of cache segment tags

      for (i=1:length(segs))
         seg = segs{i};
         segment = cach.(seg);            % access cache segment

         brewer = segment.cache.brewer;
         opts  = segment.cache.opt;
         segment = rmfield(segment,'cache');

         fprintf('cache segment: %s\n',seg);
         fprintf('  control:\n');
         fprintf('     brewer: %s\n',brewer);
         fprintf('     status: ');
         if isequal(opt(o,seg),opts)
            fprintf('up to date\n');
         else
            fprintf('*** dirty ***\n');
         end
         fprintf('\n  opt:\n');
         disp(opts);
         fprintf('  cached data:\n');
         disp(segment);
      end
   end
end
