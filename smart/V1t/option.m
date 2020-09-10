function value = option(obj,name,value,varargin)
%
% OPTION    Get or set figure/menu options of current figure. While these
%           options are stored in the figure's user data, a copy of the 
%           options is pushed into the SMART object's parameters and is
%           permanent accesible during the life time of a figure/menu
%           callback.
%         
%              value = option(obj,'flag')  % get option named 'flag' 
%              options = option(obj)       % get all options (struct)
%
%              obj = option(obj,'flag',0)  % change value of 'flag' => 0
%              obj = option(obj,options)   % refresh all options (struct)
%
%           Here are some alternative calling conventions for multiple
%           option settings which may also be used by convenience. All of
%           the following lines have identical effect:
%
%              obj = option(obj,'opt1',v1);  obj = option(obj,'opt2',v2);
%              obj = option(option(obj,'opt1',v1),'opt2',v2);
%              obj = option(obj,'opt1',v1,'opt2',v2);
%              obj = option(obj,{'opt1',v1,'opt2',v2});
%
%           Although options can be defined on a free choice there are 
%           some conventions for frequently used options. See DEFAULT for
%           a listing of frequently used standard options.
%           
%           See also: SMART DEFAULT ADDON SETTING

   if (nargin == 0)
       
      error('option(): at leat one argument expected!');

   elseif (nargin == 1)      % retrieve all options (retrieve gcf's user data)
      
      if (nargout > 0)
         value = get(obj,'options');
      else
         disp(get(obj,'options'));
      end
      
   elseif (nargin == 2)             % two possibilities a) and b)! 
      options = name;               % arg2 has dual meaning
      
      if (iscell(name))  % list of option settings
          
         arglist = name;
         n = length(arglist);
         if (rem(n,2) ~= 0)
            error('bad number of args for multiple option setting!');
         end
   
         for (i=1:2:n-1)
            name = arglist{i};  value = arglist{i+1};
            if (~isstr(name))
               fprintf('arg2{%g} = ',i);  disp(name)
               error('string argument required for option name!');
            end
            obj = option(obj,name,value);
         end
         value = obj;  % return updated object
          
      elseif (isstruct(options) | isempty(options))   % a) refresh all options!
          
         obj = set(obj,'options',options);
         value = obj;
         
      elseif (isstr(name))          % b) retrieve specified option by name
          
         options = get(obj,'options');
         try
            value = eval(['options.',name]);
         catch
            try
               value = default(name);
            catch
               value = [];
            end
         end
         
      else
         error('smart::option(): arg2 - struct or character string expected!');   
      end
      
   elseif (nargin == 3)
       
      if (~isstr(name))
         eval('arg2 = name');
         error('string argument required for option name!');
      end
      
      par = get(obj);               % get parameters
      eval(['par.options.',name,'=value;']);
      value = set(obj,par);
      
   else % handle the varargin syntax
       
      obj = option(obj,name,value);
      
      n = length(varargin);
      if (rem(n,2) ~= 0)
         error('bad number of args for multiple option setting!');
      end
   
      for (i=1:2:n-1)
         name = varargin{i};  value = varargin{i+1};
         if (~isstr(name))
            eval(sprintf('arg%g = name',i+3));
            error('string argument required for option name!');
         end
         obj = option(obj,name,value);
      end
      value = obj;  % return updated object
      
   end
   return

%eof   