function obj = set(obj,varargin)
% 
% SET      Set user defined parameter of a SMART object
%      
%             obj = smart                          % create SMART object
%             obj = set(obj,parameter,value)       % set parameter value
%             obj = set(obj,parameter)             % replace parameter list
%             obj = set(obj,'p1',6,'p2',8,'p3',5)  % multiple parameter set
%             obj = set(obj,{'p1',6,'p2',8})       % varargin support
%
%          Example:
%
%             obj = smart;
%             obj = set(obj,'pi',3.14);
%             pi = get(obj,'pi')
%
%          See also SMART GET
   
   if (length(varargin) == 1)                    % refresh all parameters
      parname = varargin{1};
      if (isempty(parname))
         obj.parameter = [];
      elseif iscell(parname)
         plist = parname;
         for i = 1:2:length(plist)-1
            obj = set(obj,plist{i},plist{i+1});
         end
      elseif (isstruct(parname))
         obj.parameter = parname;                % refresh parameter struct
      else
         error('set(): arg2 must be empty or struct!');
      end
      return
   elseif (rem(length(varargin),2) || isempty(varargin))
      error('set(): missing input arg!'); 
   end
   
   i = 1;
   while (i < length(varargin))
      parname = varargin{i};
      value = varargin{i+1};
      i = i + 2;
%       eval(['obj.parameter.',parname,'=value;']);
      obj.parameter.(parname)=value;
   end
   return

% end
