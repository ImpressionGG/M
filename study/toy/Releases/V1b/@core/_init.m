function obj = init(obj,varargin)
%
% INIT     short hand for better readability; Clear args of an object to
%          force initialization of the subsequent operation
%
%             obj = init(obj);          % same as: obj = arg(obj,[]);
%             obj = init(obj,arg1,...); % same as: obj = arg(obj,{[],arg1,...});
%
%          Example
%             menu(init(obj));          % forces to setup the MAIN menu
%             cbanalyze(init(obj));     % forces to setup the ANALYZE menu
%             view(init(obj));          % assigns view to caller
%             view(init(obj,'Mplot'));  % assigns view to Mplot
%
%          See also: SHELL, ARG, ARGS
%
   if (nargin == 1)
      obj = arg(obj,[]);                  % clear args
   else
      list = cons([],varargin);
      obj = arg(obj,list);
   end
   return
   
%eof   