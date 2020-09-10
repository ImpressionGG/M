function out = gso(varargin)
%
% GSO   Get/set current screen object (this is a CORE object).
%
%    If userdata is empty then a new generic core object is being 
%    created. You can use then CORE get/set methods to set user
%    defined parameters. Don't use parameters beginning with
%   'core.' as these are reserved for CORE methods.
%
%       gso(core);       % initialize/reset current screen object
%       gso              % display user parameters of screen object
%       smo = gso;       % get current screen object
%
%       smo = set(gso,'mydata',pi);
%       gso(smo);        % set current screen object (store user data)
%             
%    In addition GSO can be used to retrieve user defined data or
%    set user defined data directly
%
%       mydata = gso('mydata');   % get a parameter
%       gso('mydata',mydata);
%       gso('red',[1 0 0],'green',[0 1 0],...);
%                            
%    See also: CORE, GFO, GAO
%
   gcs = 0;          % this is the handle to the screen object

      % we need to initialize
      
   ud = get(gcs,'userdata');
   
   if (isempty(ud))
      ud = {core};
      set(gcs,'userdata',ud);     % init
   end
   
   if (nargin == 0)
      ud = get(gcs,'userdata');
      if (isempty(ud))
         smo = core;        % new CORE object
      else
         smo = ud{1};
      end
      if (nargout == 0)
         disp(get(smo))      % display user parameters
      else
         out = smo;
      end
      return
   end

      % otherwise we handle 1 argument
      
   if (length(varargin) == 1)
      arg = varargin{1};
      if (isobject(arg))             % set the object
         set(gcs,'userdata',{arg});
      elseif (ischar(arg))           % get user parameter
         obj = gso;                  % get user data object
         out = get(obj,arg);
      else
         error('bad type for arg1 (needs to be char or object)!');
      end
      return
   end
   
      % now we handle multiple arguments
      
   len = length(varargin);
   if (rem(len,2) ~= 0)
      error('even number of input args expected');
   end
   
   smo = gso;                       % fetch user object
   for (i=1:2:len)
      name = varargin{i};
      value = varargin{i+1};
      if (~ischar(name))
         error(sprintf('arg%g: string expected!',i));
      end
      smo = set(smo,name,value);
   end
   gso(smo);
   
   return
         
% eof   