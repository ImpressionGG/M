function obj = filter(obj,varargin)
%
% FILTER   Option based filter application to SMART #DATA object.
%          Filter operation depends on selected options.
%
%             smo = smart({1:50,randn(1,50)});     % create SMART data obj.
%
%             sfo = filter(smo);          % filter controlled by smo's opts
%             sfo = filter(smo,'window',8,'filtmode','noise'); 
%
%          Alternative for odd length of varargin:
%
%             yf = filter(smo,y);
%             yf = filter(smo,y,'window',8,'filtmode','noise');
%
%          Example 1:
%
%             smo = smart({1:50,randn(1,50)});     % create SMART data obj.
%             sfo = filter(smo);                   % filter using defaults
%             plot(sfo);
%
%          Example 2:
%
%             smo = smart({1:50,randn(1,50)});     % create SMART data obj.
%             smo = option(smo,'filtmode','noise');
%             smo = option(smo,'filter',6);        % filter type: 2nd o-fit
%             smo = option(smo,'window',20);       % filter window: 20
%             plot(filter(smo));
%
%          Example 3:
%
%             smo = smart({1:50,randn(1,50)});     % create SMART data obj.
%             sfo = filter(smo,'filter',7,'window',20);
%             
%          Description of some option settings:
%
%          1) Filter MODE
%          ==============
%             filtmode = 'raw'       % default: data, no filtering
%             filtmode = 'filter'    % default: filtered data
%             filtmode = 'noise'     % data noise (raw data minus filtered)
%             filtmode = 'rawfilter' % both raw & filtered data
%
%          2) Filter Type
%          ==============
%             filter = 0             % no filter (same as raw)
%             filter = 1             % mean of 3x3 - once
%             filter = 2             % mean of 3x3 - twice
%             filter = 3             % mean of 3x3 - triple
%             filter = 6             % 2nd order fit - once
%             filter = 7             % 2nd order fit - twice
%             filter = 8             % 2nd order fit - triple
%
%          See also: SMART FILTER1D DRIFT
%

   if (~strcmp(kind(obj),'DATA'))
      error('filter(): only applicable to SMART objects of kind DATA');
   end
   
   knd = obj.data.kind;
   switch knd 
       case 'double'
          % that's OK!
       otherwise
          error(['filter(): data kind "',knd,'" not supported!"']);
   end
   
      % check if odd length varargin. In this case we ave to return a 
      % vector set instead of an object
      
   n = length(varargin);
   if (rem(n,2) ~= 0)          % then odd length
       y = varargin{1};

       obj = option(obj,varargin(2:n));
       filtype = option(obj,'filter');
       wfilt = option(obj,'window');
       if (wfilt > length(val)) wfilt = length(val); end
       
       yf = filter1d(y',[filtype wfilt])';
       obj = yf;                           % out arg is vector set (no obj)
       return;
   end
      
      % set options specified by varargin
      
   obj = option(obj,varargin);
       
      % now take care about default options. In the special case we have to
      % take filtmode = 'filter' as a default. This is a little bit tricky,
      % because option(obj,'filtmode') provides an intrinsic default, if 
      % no special option setting provided
   
   
   opt = get(obj,'options');  % this statement does not provide defaults
   opt.filtmode = eval('opt.filtmode','''filter''');
   obj = option(obj,opt);     % refresh options

      % now get data to be filtered. This is only y-data!
      
   val = obj.data.y;   % y values
   
   mode = option(obj,'filtmode');
   switch mode
      case {'raw','r'}
         % ok - done!
         
      case {'filter','f','rawfilter'}
         filtype = option(obj,'filter');
         wfilt = option(obj,'window');
         if (wfilt > length(val)) wfilt = length(val); end
         yf = filter1d(val',[filtype wfilt])';
         if (strcmp(mode,'rawfilter'))
            obj.data.yf = yf;  % add extra data yf!
         else
            obj.data.y = yf;   % overwrite y values
         end
         
      case {'noise','n'}
         filtype = option(obj,'filter');
         wfilt = option(obj,'window');
         if (wfilt > length(val)) wfilt = length(val); end
         noise = val - filter1d(val',[filtype wfilt])';
         obj.data.y = noise;   % overwrite y values
               
      case {'residual','r'}
         res = residual(obj,val);
         obj.data.y = res;     % overwrite y values

      otherwise
         error(['Bad mode: ',mode,'!']);
   end
   return
