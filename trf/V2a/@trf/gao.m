function out = gao(varargin)
%
% GAO   Get (or set) current axis object (this is a CORE object).
%
%    If userdata is empty then a new generic CORE object is being 
%    created. You can use then CORE get/set methods to set user
%    defined parameters. Don't use parameters beginning with
%    'core.' as these are reserved for CORE methods.
%
%       gao           % display user parameters of axis
%       smo = gao;    % get current axis object
%
%       smo = set(gao,'mydata',pi);
%       gao(smo);     % set current axis object (store user data)
%             
%    In addition GAO can be used to retrieve user defined data or
%    set user defined data directly
%
%       mydata = gao('mydata');   % get a parameter
%       gao('mydata',mydata);
%       gao('red',[1 0 0],'green',[0 1 0],...);
%                            
%    See also: CORE, GFO, CMAP, CINDEX
%
   if (nargin == 0)
      ud = get(gca,'userdata');
      if (isempty(ud))
         smo = corazon;      % new CORAZON object
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
         set(gca,'userdata',{arg});
      elseif (ischar(arg))           % get user parameter
         obj = trf.gao;              % get user data object
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
   
   smo = trf.gao;                    % fetch user object
   for (i=1:2:len)
      name = varargin{i};
      value = varargin{i+1};
      if (~ischar(name))
         error(sprintf('arg%g: string expected!',i));
      end
      smo = set(smo,name,value);
   end
   trf.gao(smo);
   
   return
end         
