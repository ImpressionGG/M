function [obj,cob] = derive(cob,classname)
%
% DERIVE   Auxillary function for easy construction of derived CORE class.
%
%    The derived class provides tutorial functionality
%
%       [obj,cob] = derive(core,mfilename);      % simple derivation
%       obj = class(obj,obj.tag,cob);            % make a class object
%
%    If required format, parameters and data can be provided in
%    the CORE constructor:
%
%       obj.<...> = ...                       % setup obj structure 
%       cob = shell(format,par,data);         % parent class object
%       [obj,cob] = derive(cob,mfilename);    % parent class
%       obj = class(obj,obj.tag,cob);         % make a class object
%
%    Example: A most likely example of a constructor for derived
%    CORE object would look like:
%
%       function out = myclass(varargin)
%       %
%       % MYCLASS   Constructor for MYCLASS (derived CORE)
%       %
%          [obj,cob] = derive(core(varargin),mfilename);
%          obj = class(obj,obj.tag,cob);     
%          if (nargout==0) tutorial(obj); else out = obj; end
%          return           
%       end
%
%    See also: CORE
%
   obj.tag = lower(classname);

   par = get(cob);
   par.class = classname;                 % set parameters
   par = parinit(format(cob,[],[]),par,classname);
   cob = set(cob,par);

   return
end

%==========================================================================

function parameter = parinit(format,parameter,classname)
%
% PARINIT    init parameters with defaults
%
   if (nargin == 0)
      parameter = [];
   end

% do some format specific special treatments

   name = upper(classname);
   switch format
      case {'#TEST','test'}
         list = {{'test'},'file','test','info'};  title = 'Test Shell';
      case {'#TOOLBOX','toolbox'}
         title = [name,' Toolbox'];  list = {'file','tools','info'}; 
      case {'#TUTORIAL','tutorial'}
         list = {{'tutorial'},'file'};  title = [name,' Tutorial'];
      case {'#DEMO','demo'}
         list = {{'demo'},'file','info'};  title = [name,' Demo'];
      otherwise
         title = '';    % earlier: title = [name,' Shell']; 
         list = {'file'}; 
   end
   
   eval('parameter.title;','parameter.title = title;');
   eval('parameter.comment;','parameter.comment = {};');
   eval('parameter.menu;','parameter.menu = list;');

   if isempty(parameter.menu)
      parameter.menu = list;
   end
   return
   
end
